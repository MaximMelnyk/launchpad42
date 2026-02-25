"""Exercise service — submission, XP calculation, hash verification, progress."""

import re
from datetime import datetime, timezone

import structlog
from google.cloud.firestore_v1 import AsyncClient

from app.models.exercise import (
    Exercise,
    ExerciseProgress,
    ExerciseStatus,
    ExerciseSubmission,
)
from app.models.gamification import (
    XP_BONUS_FIRST_ATTEMPT,
    XP_BONUS_NO_HINTS,
)

logger = structlog.get_logger()

# Valid hash pattern: exactly 8 hexadecimal characters
HASH_PATTERN = re.compile(r"^[0-9a-f]{8}$")


async def verify_hash(hash_code: str, uid: str, exercise_id: str) -> bool:
    """SHA256 format validation: 8 hex chars.

    We validate format only; the actual hash is computed client-side
    from the local test runner output. Server stores and trusts it.
    """
    return bool(HASH_PATTERN.match(hash_code.lower()))


async def get_exercise_progress(
    uid: str, exercise_id: str, db: AsyncClient
) -> ExerciseProgress | None:
    """Fetch exercise_progress doc or None."""
    doc_id = f"{uid}_{exercise_id}"
    doc = await db.collection("exercise_progress").document(doc_id).get()
    if not doc.exists:
        return None
    data = doc.to_dict()
    data["uid"] = uid
    data["exercise_id"] = exercise_id
    return ExerciseProgress(**data)


async def calculate_xp(
    exercise: Exercise,
    progress: ExerciseProgress | None,
    hints_used: int,
) -> tuple[int, list[str]]:
    """Base XP from exercise.xp + bonuses.

    Bonuses:
    - first_attempt (+XP_BONUS_FIRST_ATTEMPT if no previous attempts)
    - no_hints (+XP_BONUS_NO_HINTS if hints_used==0)
    Returns (total_xp, bonus_names)
    """
    base_xp = exercise.xp
    bonuses: list[str] = []

    attempts = progress.attempts if progress else 0

    if attempts == 0:
        base_xp += XP_BONUS_FIRST_ATTEMPT
        bonuses.append("first_attempt")

    if hints_used == 0:
        base_xp += XP_BONUS_NO_HINTS
        bonuses.append("no_hints")

    return base_xp, bonuses


async def submit_exercise(
    uid: str,
    exercise_id: str,
    submission: ExerciseSubmission,
    db: AsyncClient,
) -> dict:
    """Verify hash, calculate XP with bonuses, update exercise_progress, update user XP.

    Returns {xp_earned, bonuses, level_up, achievements_unlocked}
    """
    # Validate hash format
    if not await verify_hash(submission.hash_code, uid, exercise_id):
        raise ValueError("Invalid hash format. Expected 8 hex characters.")

    # Fetch exercise definition
    ex_doc = await db.collection("exercises").document(exercise_id).get()
    if not ex_doc.exists:
        raise ValueError(f"Exercise not found: {exercise_id}")
    ex_data = ex_doc.to_dict()
    ex_data["id"] = exercise_id
    exercise = Exercise(**ex_data)

    # Fetch existing progress
    progress = await get_exercise_progress(uid, exercise_id, db)

    # P1-4: Prevent XP farming on re-submission of completed exercises
    if progress and progress.status == ExerciseStatus.COMPLETED:
        logger.info(
            "Exercise already completed, no XP awarded",
            uid=uid,
            exercise_id=exercise_id,
        )
        return {
            "xp_earned": 0,
            "bonuses": [],
            "level_up": False,
            "achievements_unlocked": [],
            "already_completed": True,
        }

    # Calculate XP
    xp_earned, bonuses = await calculate_xp(
        exercise, progress, submission.hints_used
    )

    now = datetime.now(timezone.utc)
    doc_id = f"{uid}_{exercise_id}"

    # Update or create exercise_progress
    progress_data = {
        "uid": uid,
        "exercise_id": exercise_id,
        "status": ExerciseStatus.COMPLETED.value,
        "attempts": (progress.attempts + 1) if progress else 1,
        "hints_used": submission.hints_used,
        "xp_earned": xp_earned,
        "hash_code": submission.hash_code.lower(),
        "first_attempt_pass": progress is None or progress.attempts == 0,
        "completed_at": now,
        "updated_at": now,
    }
    if progress is None:
        progress_data["started_at"] = now

    await db.collection("exercise_progress").document(doc_id).set(
        progress_data, merge=True
    )

    # Update user XP
    user_doc = await db.collection("users").document(uid).get()
    if user_doc.exists:
        user_data = user_doc.to_dict()
        current_xp = user_data.get("xp", 0)
        new_xp = current_xp + xp_earned
        await db.collection("users").document(uid).set(
            {"xp": new_xp, "updated_at": now}, merge=True
        )
    else:
        raise ValueError(f"User not found: {uid}")

    # Check level up (import here to avoid circular imports)
    from app.services.gamification_service import check_achievements, check_level_up

    level_up = await check_level_up(uid, db)
    achievements_unlocked = await check_achievements(uid, db)

    logger.info(
        "Exercise submitted",
        uid=uid,
        exercise_id=exercise_id,
        xp_earned=xp_earned,
        bonuses=bonuses,
        level_up=level_up,
    )

    return {
        "xp_earned": xp_earned,
        "bonuses": bonuses,
        "level_up": level_up,
        "achievements_unlocked": achievements_unlocked,
    }
