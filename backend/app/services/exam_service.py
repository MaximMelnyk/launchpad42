"""Exam service — gate exams, final simulations, cooldowns, scoring."""

import uuid
from datetime import datetime, timedelta

import structlog
from google.cloud.firestore_v1 import AsyncClient
from google.cloud.firestore_v1.base_query import FieldFilter

from app.models.gamification import (
    Exam,
    ExamStatus,
    ExamType,
    XP_BONUS_EXAM_PASS,
)

logger = structlog.get_logger()

# Cooldown and attempt limits
COOLDOWN_HOURS = 48
MAX_ATTEMPTS_PER_PERIOD = 3
ATTEMPT_PERIOD_DAYS = 14

# Score thresholds
PASS_THRESHOLD = 0.80
PARTIAL_THRESHOLD = 0.60

# Time limits (minutes)
GATE_TIME_LIMIT = 240   # 4 hours
FINAL_TIME_LIMIT = 480  # 8 hours

# Exercises per exam level (gate exams)
GATE_EXERCISES_PER_LEVEL: dict[int, list[str]] = {
    0: [],  # No gate exam for level 0
    1: ["shell00_ex00", "shell00_ex01", "shell00_ex02", "shell00_ex03", "shell00_ex04"],
    2: ["c00_ex00", "c00_ex01", "c00_ex02", "c00_ex03", "c00_ex04",
        "c01_ex00", "c01_ex01", "c01_ex02", "c01_ex03"],
    3: ["c02_ex00", "c02_ex01", "c02_ex02", "c03_ex00", "c03_ex01",
        "c04_ex00", "c04_ex01", "c05_ex00"],
    4: ["c06_ex00", "c06_ex01", "c07_ex00", "c07_ex01", "c08_ex00"],
    5: ["exam_final_01", "exam_final_02", "exam_final_03",
        "exam_final_04", "exam_final_05"],
}


async def check_cooldown(
    uid: str, exam_type: str, db: AsyncClient
) -> dict:
    """Check 48h cooldown and 3 attempts per 14 days.

    Return {can_start, reason, next_available}
    """
    now = datetime.utcnow()
    cutoff_14d = now - timedelta(days=ATTEMPT_PERIOD_DAYS)

    # Query recent exams
    query = db.collection("exams").where(
        filter=FieldFilter("uid", "==", uid)
    ).where(
        filter=FieldFilter("exam_type", "==", exam_type)
    )

    recent_exams: list[dict] = []
    async for doc in query.stream():
        exam_data = doc.to_dict()
        recent_exams.append(exam_data)

    # Check 48h cooldown from last failed attempt
    for exam_data in recent_exams:
        if exam_data.get("status") in (
            ExamStatus.FAILED.value,
            ExamStatus.PARTIAL.value,
        ):
            finished_at = exam_data.get("finished_at")
            if finished_at:
                if isinstance(finished_at, str):
                    finished_at = datetime.fromisoformat(finished_at)
                cooldown_end = finished_at + timedelta(hours=COOLDOWN_HOURS)
                if now < cooldown_end:
                    return {
                        "can_start": False,
                        "reason": f"Cooldown active. Wait until {cooldown_end.isoformat()}",
                        "next_available": cooldown_end.isoformat(),
                    }

    # Check attempt limit (3 per 14 days)
    recent_count = 0
    for exam_data in recent_exams:
        started = exam_data.get("started_at")
        if started:
            if isinstance(started, str):
                started = datetime.fromisoformat(started)
            if started > cutoff_14d:
                recent_count += 1

    if recent_count >= MAX_ATTEMPTS_PER_PERIOD:
        return {
            "can_start": False,
            "reason": f"Maximum {MAX_ATTEMPTS_PER_PERIOD} attempts per {ATTEMPT_PERIOD_DAYS} days reached",
            "next_available": (cutoff_14d + timedelta(days=ATTEMPT_PERIOD_DAYS)).isoformat(),
        }

    return {"can_start": True, "reason": None, "next_available": None}


async def start_exam(
    uid: str, exam_type: str, level: int, db: AsyncClient
) -> Exam:
    """Create exam doc. Set timer (240 min gate / 480 min final).

    Check cooldown first (48h since last failed attempt).
    Select exercises for exam based on level.
    """
    # Validate exam type
    try:
        et = ExamType(exam_type)
    except ValueError:
        raise ValueError(f"Invalid exam type: {exam_type}. Use 'gate' or 'final'.")

    # Check cooldown
    cooldown = await check_cooldown(uid, exam_type, db)
    if not cooldown["can_start"]:
        raise ValueError(cooldown["reason"])

    # Set time limit
    time_limit = GATE_TIME_LIMIT if et == ExamType.GATE else FINAL_TIME_LIMIT

    # Select exercises
    if et == ExamType.GATE:
        exercises = GATE_EXERCISES_PER_LEVEL.get(level, [])
        if not exercises:
            raise ValueError(f"No exercises defined for gate exam level {level}")
    else:
        # Final exam: combine exercises from multiple levels
        exercises = []
        for lvl in range(1, min(level + 1, 6)):
            exercises.extend(GATE_EXERCISES_PER_LEVEL.get(lvl, []))

    # Count attempt number
    attempt_number = 1
    query = db.collection("exams").where(
        filter=FieldFilter("uid", "==", uid)
    ).where(
        filter=FieldFilter("exam_type", "==", exam_type)
    ).where(
        filter=FieldFilter("level", "==", level)
    )
    async for _ in query.stream():
        attempt_number += 1

    # Create exam
    exam_id = str(uuid.uuid4())[:12]
    now = datetime.utcnow()

    exam = Exam(
        uid=uid,
        exam_id=exam_id,
        exam_type=et,
        level=level,
        exercises=exercises,
        time_limit_minutes=time_limit,
        started_at=now,
        attempt_number=attempt_number,
    )

    doc_id = f"{uid}_{exam_id}"
    await db.collection("exams").document(doc_id).set(exam.model_dump())

    logger.info(
        "Exam started",
        uid=uid,
        exam_id=exam_id,
        exam_type=exam_type,
        level=level,
        exercises=len(exercises),
    )

    return exam


async def submit_exam_exercise(
    uid: str,
    exam_id: str,
    exercise_id: str,
    hash_code: str,
    db: AsyncClient,
) -> dict:
    """Score individual exercise in exam. Update completed_exercises and score.

    If all exercises done, finalize: pass (>=80%), partial (60-79%), fail (<60%).
    Return {correct, score, completed}
    """
    doc_id = f"{uid}_{exam_id}"
    exam_doc = await db.collection("exams").document(doc_id).get()

    if not exam_doc.exists:
        raise ValueError(f"Exam not found: {exam_id}")

    exam_data = exam_doc.to_dict()

    # Check exam is still in progress
    if exam_data.get("status") != ExamStatus.IN_PROGRESS.value:
        raise ValueError("Exam is no longer in progress")

    # Check time limit
    started_at = exam_data.get("started_at")
    if started_at:
        if isinstance(started_at, str):
            started_at = datetime.fromisoformat(started_at)
        time_limit = timedelta(minutes=exam_data.get("time_limit_minutes", 240))
        if datetime.utcnow() > started_at + time_limit:
            # Time expired — auto-fail
            await _finalize_exam(doc_id, exam_data, db)
            raise ValueError("Exam time has expired")

    # Verify exercise is part of this exam
    exercises = exam_data.get("exercises", [])
    if exercise_id not in exercises:
        raise ValueError(f"Exercise {exercise_id} is not part of this exam")

    # Mark exercise as completed (hash accepted — format validation only)
    from app.services.exercise_service import verify_hash
    if not await verify_hash(hash_code, uid, exercise_id):
        return {"correct": False, "score": exam_data.get("score", 0.0), "completed": False}

    completed = exam_data.get("completed_exercises", [])
    if exercise_id not in completed:
        completed.append(exercise_id)

    # Calculate score
    total = len(exercises)
    score = len(completed) / total if total > 0 else 0.0

    update_data: dict = {
        "completed_exercises": completed,
        "score": score,
    }

    # Check if all exercises are done
    exam_completed = len(completed) >= total
    if exam_completed:
        now = datetime.utcnow()
        if score >= PASS_THRESHOLD:
            update_data["status"] = ExamStatus.PASSED.value
            # Award bonus XP
            user_doc = await db.collection("users").document(uid).get()
            if user_doc.exists:
                user_data = user_doc.to_dict()
                new_xp = user_data.get("xp", 0) + XP_BONUS_EXAM_PASS
                await db.collection("users").document(uid).set(
                    {"xp": new_xp, "updated_at": now}, merge=True
                )
        elif score >= PARTIAL_THRESHOLD:
            update_data["status"] = ExamStatus.PARTIAL.value
        else:
            update_data["status"] = ExamStatus.FAILED.value
        update_data["finished_at"] = now

    await db.collection("exams").document(doc_id).set(update_data, merge=True)

    logger.info(
        "Exam exercise submitted",
        uid=uid,
        exam_id=exam_id,
        exercise_id=exercise_id,
        score=score,
        completed=exam_completed,
    )

    return {
        "correct": True,
        "score": score,
        "completed": exam_completed,
    }


async def _finalize_exam(
    doc_id: str, exam_data: dict, db: AsyncClient
) -> None:
    """Finalize an expired exam."""
    exercises = exam_data.get("exercises", [])
    completed = exam_data.get("completed_exercises", [])
    total = len(exercises)
    score = len(completed) / total if total > 0 else 0.0
    now = datetime.utcnow()

    if score >= PASS_THRESHOLD:
        status = ExamStatus.PASSED.value
    elif score >= PARTIAL_THRESHOLD:
        status = ExamStatus.PARTIAL.value
    else:
        status = ExamStatus.FAILED.value

    await db.collection("exams").document(doc_id).set(
        {
            "status": status,
            "score": score,
            "finished_at": now,
        },
        merge=True,
    )


async def get_exam_status(
    uid: str, exam_id: str, db: AsyncClient
) -> dict:
    """Get exam with time_remaining calculated from started_at + time_limit.

    Return Exam data + time_remaining_minutes.
    """
    doc_id = f"{uid}_{exam_id}"
    exam_doc = await db.collection("exams").document(doc_id).get()

    if not exam_doc.exists:
        raise ValueError(f"Exam not found: {exam_id}")

    exam_data = exam_doc.to_dict()

    # Calculate time remaining
    time_remaining_minutes = 0
    started_at = exam_data.get("started_at")
    if started_at and exam_data.get("status") == ExamStatus.IN_PROGRESS.value:
        if isinstance(started_at, str):
            started_at = datetime.fromisoformat(started_at)
        time_limit = timedelta(minutes=exam_data.get("time_limit_minutes", 240))
        end_time = started_at + time_limit
        remaining = end_time - datetime.utcnow()
        time_remaining_minutes = max(0, int(remaining.total_seconds() / 60))

        # Auto-finalize if time expired
        if time_remaining_minutes <= 0:
            await _finalize_exam(doc_id, exam_data, db)
            # Re-read updated data
            exam_doc = await db.collection("exams").document(doc_id).get()
            exam_data = exam_doc.to_dict()

    result = dict(exam_data)
    result["time_remaining_minutes"] = time_remaining_minutes
    return result
