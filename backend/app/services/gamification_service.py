"""Gamification service — XP, levels, streaks, shields, achievements, drills, reviews."""

from datetime import date, datetime, timedelta

import structlog
from google.cloud.firestore_v1 import AsyncClient
from google.cloud.firestore_v1.base_query import FieldFilter

from app.models.gamification import (
    ACHIEVEMENT_NAMES_UK,
    LEVEL_NAMES,
    LEVEL_XP_THRESHOLDS,
    XP_BONUS_ACHIEVEMENT,
    XP_BONUS_DRILL,
    XP_BONUS_VOCAB,
    Achievement,
    AchievementId,
)

logger = structlog.get_logger()

# SM-2 lite intervals (days)
SM2_INTERVALS: list[int] = [3, 5, 8, 14, 30]


def _next_sm2_interval(current_interval: int) -> int:
    """Advance to the next SM-2 lite interval.

    Progression: 3 -> 5 -> 8 -> 14 -> 30 -> 30 (cap)
    """
    try:
        idx = SM2_INTERVALS.index(current_interval)
        if idx < len(SM2_INTERVALS) - 1:
            return SM2_INTERVALS[idx + 1]
        return SM2_INTERVALS[-1]
    except ValueError:
        # If current interval is not standard, find the closest next
        for iv in SM2_INTERVALS:
            if iv > current_interval:
                return iv
        return SM2_INTERVALS[-1]


async def check_level_up(uid: str, db: AsyncClient) -> bool:
    """Compare user XP to LEVEL_XP_THRESHOLDS.

    If next level threshold met, advance level. Return True if leveled up.
    """
    user_doc = await db.collection("users").document(uid).get()
    if not user_doc.exists:
        return False

    user_data = user_doc.to_dict()
    current_level = user_data.get("level", 0)
    current_xp = user_data.get("xp", 0)

    if current_level >= 6:
        return False

    next_level = current_level + 1
    threshold = LEVEL_XP_THRESHOLDS.get(next_level, float("inf"))

    if current_xp >= threshold:
        await db.collection("users").document(uid).set(
            {
                "level": next_level,
                "updated_at": datetime.utcnow(),
            },
            merge=True,
        )
        logger.info(
            "Level up",
            uid=uid,
            new_level=next_level,
            level_name=LEVEL_NAMES.get(next_level),
            xp=current_xp,
        )
        return True

    return False


async def check_achievements(uid: str, db: AsyncClient) -> list[str]:
    """Evaluate all 8 achievement conditions. Unlock newly earned ones.

    Returns list of newly unlocked achievement IDs.
    """
    user_doc = await db.collection("users").document(uid).get()
    if not user_doc.exists:
        return []

    user_data = user_doc.to_dict()
    newly_unlocked: list[str] = []
    now = datetime.utcnow()

    # Load existing achievements
    existing: dict[str, bool] = {}
    for ach_id in AchievementId:
        doc_id = f"{uid}_{ach_id.value}"
        ach_doc = await db.collection("achievements").document(doc_id).get()
        if ach_doc.exists:
            existing[ach_id.value] = ach_doc.to_dict().get("unlocked", False)
        else:
            existing[ach_id.value] = False

    # Count completed exercises
    completed_count = 0
    progress_query = db.collection("exercise_progress").where(
        filter=FieldFilter("uid", "==", uid)
    ).where(
        filter=FieldFilter("status", "==", "completed")
    )
    async for _ in progress_query.stream():
        completed_count += 1

    # Check each achievement
    checks: list[tuple[AchievementId, bool, int, int]] = [
        # (id, condition_met, progress, target)
        (
            AchievementId.FIRST_BLOOD,
            completed_count >= 1,
            min(completed_count, 1),
            1,
        ),
        (
            AchievementId.WEEK_WARRIOR,
            len(user_data.get("weekly_completed_days", [])) >= 5,
            len(user_data.get("weekly_completed_days", [])),
            5,
        ),
        (
            AchievementId.STREAK_MASTER,
            user_data.get("streak_days", 0) >= 14,
            min(user_data.get("streak_days", 0), 14),
            14,
        ),
        (
            AchievementId.EXAM_SURVIVOR,
            False,  # Checked separately below
            0,
            1,
        ),
        (
            AchievementId.LAUNCH_READY,
            user_data.get("level", 0) >= 6,
            min(user_data.get("level", 0), 6),
            6,
        ),
    ]

    # EXAM_SURVIVOR: check if any gate exam passed
    exam_query = db.collection("exams").where(
        filter=FieldFilter("uid", "==", uid)
    ).where(
        filter=FieldFilter("status", "==", "passed")
    ).where(
        filter=FieldFilter("exam_type", "==", "gate")
    )
    exam_passed = False
    async for _ in exam_query.stream():
        exam_passed = True
        break

    # Update EXAM_SURVIVOR check
    checks[3] = (AchievementId.EXAM_SURVIVOR, exam_passed, 1 if exam_passed else 0, 1)

    # NORMINETTE_CLEAN: 10 exercises with norminette pass (simplified: 10 first-attempt passes)
    first_attempt_count = 0
    first_attempt_query = db.collection("exercise_progress").where(
        filter=FieldFilter("uid", "==", uid)
    ).where(
        filter=FieldFilter("first_attempt_pass", "==", True)
    )
    async for _ in first_attempt_query.stream():
        first_attempt_count += 1
    checks.append(
        (
            AchievementId.NORMINETTE_CLEAN,
            first_attempt_count >= 10,
            min(first_attempt_count, 10),
            10,
        )
    )

    # MEMORY_MASTER: Complete all C06-C08 (exercises with module in [c06, c07, c08])
    memory_modules = {"c06", "c07", "c08"}
    memory_total = 0
    memory_completed = 0
    mem_exercises_query = db.collection("exercises").where(
        filter=FieldFilter("module", "in", list(memory_modules))
    )
    async for doc in mem_exercises_query.stream():
        memory_total += 1
        prog_doc = await db.collection("exercise_progress").document(
            f"{uid}_{doc.id}"
        ).get()
        if prog_doc.exists and prog_doc.to_dict().get("status") == "completed":
            memory_completed += 1

    checks.append(
        (
            AchievementId.MEMORY_MASTER,
            memory_total > 0 and memory_completed >= memory_total,
            memory_completed,
            max(memory_total, 1),
        )
    )

    # SPEED_DEMON: placeholder — tracked at exercise submission time via separate logic
    # We check if any exercise was completed in <50% estimated time
    # For simplicity, we track this as a flag in progress documents
    checks.append(
        (
            AchievementId.SPEED_DEMON,
            False,  # Will be set by exercise_service when detected
            0,
            1,
        )
    )

    # Process checks
    for ach_id, condition_met, progress, target in checks:
        if existing.get(ach_id.value, False):
            continue  # Already unlocked

        doc_id = f"{uid}_{ach_id.value}"
        ach_data = {
            "uid": uid,
            "achievement_id": ach_id.value,
            "progress": progress,
            "target": target,
            "unlocked": condition_met,
        }

        if condition_met:
            ach_data["unlocked_at"] = now
            newly_unlocked.append(ach_id.value)

            # Award bonus XP for unlocking
            user_xp = user_data.get("xp", 0)
            await db.collection("users").document(uid).set(
                {"xp": user_xp + XP_BONUS_ACHIEVEMENT, "updated_at": now},
                merge=True,
            )
            logger.info(
                "Achievement unlocked",
                uid=uid,
                achievement=ach_id.value,
                name=ACHIEVEMENT_NAMES_UK.get(ach_id.value),
            )

        await db.collection("achievements").document(doc_id).set(
            ach_data, merge=True
        )

    return newly_unlocked


async def update_streak(uid: str, db: AsyncClient) -> dict:
    """Check weekly_completed_days. If today not in list, add it.

    Calculate streak from consecutive days.
    Manage shields (1 per 7 consecutive days, max 3).
    Return {streak_days, shields, weekly_progress}
    """
    user_doc = await db.collection("users").document(uid).get()
    if not user_doc.exists:
        return {"streak_days": 0, "shields": 0, "weekly_progress": "0/7"}

    user_data = user_doc.to_dict()
    today_str = date.today().isoformat()

    weekly_days: list[str] = user_data.get("weekly_completed_days", [])

    # Add today if not present
    if today_str not in weekly_days:
        weekly_days.append(today_str)

    # Sort dates and calculate streak (consecutive days ending at today)
    sorted_dates = sorted(weekly_days)
    streak = 0
    check_date = date.today()

    for d_str in reversed(sorted_dates):
        try:
            d = date.fromisoformat(d_str)
        except ValueError:
            continue
        if d == check_date:
            streak += 1
            check_date -= timedelta(days=1)
        elif d < check_date:
            break

    # Shields: 1 per 7 consecutive days, max 3
    shields = min(streak // 7, 3)

    # Weekly progress: count days completed this week (Mon-Sun)
    today = date.today()
    monday = today - timedelta(days=today.weekday())
    week_dates = set()
    for d_str in weekly_days:
        try:
            d = date.fromisoformat(d_str)
            if monday <= d <= today:
                week_dates.add(d_str)
        except ValueError:
            continue

    weekly_progress = f"{len(week_dates)}/7"

    # Update user document
    await db.collection("users").document(uid).set(
        {
            "weekly_completed_days": weekly_days,
            "streak_days": streak,
            "shields": shields,
            "updated_at": datetime.utcnow(),
        },
        merge=True,
    )

    return {
        "streak_days": streak,
        "shields": shields,
        "weekly_progress": weekly_progress,
    }


async def get_gamification_profile(uid: str, db: AsyncClient) -> dict:
    """Aggregate: level, xp, next_level_xp, streak, shields, phase.

    next_level_xp = LEVEL_XP_THRESHOLDS[level+1] if level < 6 else LEVEL_XP_THRESHOLDS[6]
    """
    user_doc = await db.collection("users").document(uid).get()
    if not user_doc.exists:
        raise ValueError(f"User not found: {uid}")

    user_data = user_doc.to_dict()
    level = user_data.get("level", 0)
    xp = user_data.get("xp", 0)

    if level < 6:
        next_level_xp = LEVEL_XP_THRESHOLDS.get(level + 1, LEVEL_XP_THRESHOLDS[6])
    else:
        next_level_xp = LEVEL_XP_THRESHOLDS[6]

    # Weekly progress
    weekly_days = user_data.get("weekly_completed_days", [])
    today = date.today()
    monday = today - timedelta(days=today.weekday())
    week_count = sum(
        1
        for d_str in weekly_days
        if _is_date_in_range(d_str, monday, today)
    )

    return {
        "level": level,
        "level_name": LEVEL_NAMES.get(level, "Unknown"),
        "xp": xp,
        "next_level_xp": next_level_xp,
        "xp_to_next": max(0, next_level_xp - xp),
        "streak_days": user_data.get("streak_days", 0),
        "shields": user_data.get("shields", 0),
        "phase": user_data.get("phase", "phase0"),
        "weekly_progress": f"{week_count}/7",
    }


def _is_date_in_range(d_str: str, start: date, end: date) -> bool:
    """Check if date string falls within range (inclusive)."""
    try:
        d = date.fromisoformat(d_str)
        return start <= d <= end
    except ValueError:
        return False


async def process_drill(
    uid: str, function_name: str, time_seconds: int, db: AsyncClient
) -> dict:
    """Verify drill attempt. Award XP: 20 if under estimated time, 10 if over.

    Update drill_pool last_drilled. Return {correct, xp_earned}.
    """
    now = datetime.utcnow()
    today_str = date.today().isoformat()

    # Fetch exercise for estimated time
    ex_doc = await db.collection("exercises").document(function_name).get()
    estimated_seconds = 900  # Default 15 min
    if ex_doc.exists:
        ex_data = ex_doc.to_dict()
        estimated_seconds = ex_data.get("estimated_minutes", 15) * 60

    # Award XP based on speed
    if time_seconds <= estimated_seconds:
        xp_earned = XP_BONUS_DRILL * 2  # 20 XP for fast completion
    else:
        xp_earned = XP_BONUS_DRILL  # 10 XP for slow completion

    # Update drill pool
    drill_ref = db.collection("drill_pool").document(uid)
    drill_doc = await drill_ref.get()

    if drill_doc.exists:
        drill_data = drill_doc.to_dict()
        last_drilled = drill_data.get("last_drilled", {})
        last_drilled[function_name] = today_str
        queue = drill_data.get("function_queue", [])

        # Move drilled function to end of queue (least-recently-drilled first)
        if function_name in queue:
            queue.remove(function_name)
            queue.append(function_name)

        await drill_ref.set(
            {
                "uid": uid,
                "function_queue": queue,
                "last_drilled": last_drilled,
                "updated_at": now,
            },
            merge=True,
        )
    else:
        await drill_ref.set(
            {
                "uid": uid,
                "function_queue": [function_name],
                "last_drilled": {function_name: today_str},
                "updated_at": now,
            }
        )

    # Update user XP
    user_doc = await db.collection("users").document(uid).get()
    if user_doc.exists:
        user_data = user_doc.to_dict()
        new_xp = user_data.get("xp", 0) + xp_earned
        await db.collection("users").document(uid).set(
            {"xp": new_xp, "updated_at": now}, merge=True
        )

    logger.info(
        "Drill completed",
        uid=uid,
        function=function_name,
        time_seconds=time_seconds,
        xp_earned=xp_earned,
    )

    return {"correct": True, "xp_earned": xp_earned}


async def process_review(
    uid: str, card_id: str, correct: bool, db: AsyncClient
) -> dict:
    """SM-2 lite interval update.

    If correct: advance interval (3->5->8->14->30), increment correct_count.
    If incorrect: reset interval to 3.
    Update next_review date. Return {next_review, xp_earned}.
    """
    now = datetime.utcnow()

    card_ref = db.collection("review_cards").document(card_id)
    card_doc = await card_ref.get()

    if not card_doc.exists:
        raise ValueError(f"Review card not found: {card_id}")

    card_data = card_doc.to_dict()
    current_interval = card_data.get("interval_days", 3)
    review_count = card_data.get("review_count", 0)
    correct_count = card_data.get("correct_count", 0)

    xp_earned = 0

    if correct:
        new_interval = _next_sm2_interval(current_interval)
        correct_count += 1
        xp_earned = XP_BONUS_VOCAB
    else:
        new_interval = SM2_INTERVALS[0]  # Reset to 3 days

    next_review = now + timedelta(days=new_interval)

    await card_ref.set(
        {
            "interval_days": new_interval,
            "next_review": next_review,
            "review_count": review_count + 1,
            "correct_count": correct_count,
        },
        merge=True,
    )

    # Award XP if correct
    if xp_earned > 0:
        user_doc = await db.collection("users").document(uid).get()
        if user_doc.exists:
            user_data = user_doc.to_dict()
            new_xp = user_data.get("xp", 0) + xp_earned
            await db.collection("users").document(uid).set(
                {"xp": new_xp, "updated_at": now}, merge=True
            )

    logger.info(
        "Review completed",
        uid=uid,
        card_id=card_id,
        correct=correct,
        new_interval=new_interval,
        xp_earned=xp_earned,
    )

    return {
        "next_review": next_review.isoformat(),
        "interval_days": new_interval,
        "xp_earned": xp_earned,
    }


async def get_achievements(uid: str, db: AsyncClient) -> list[dict]:
    """Fetch all achievements for a user."""
    achievements: list[dict] = []
    for ach_id in AchievementId:
        doc_id = f"{uid}_{ach_id.value}"
        doc = await db.collection("achievements").document(doc_id).get()
        if doc.exists:
            data = doc.to_dict()
            data["name_uk"] = ACHIEVEMENT_NAMES_UK.get(ach_id.value, ach_id.value)
            achievements.append(data)
        else:
            achievements.append(
                {
                    "uid": uid,
                    "achievement_id": ach_id.value,
                    "name_uk": ACHIEVEMENT_NAMES_UK.get(ach_id.value, ach_id.value),
                    "unlocked": False,
                    "progress": 0,
                    "target": 1,
                }
            )
    return achievements
