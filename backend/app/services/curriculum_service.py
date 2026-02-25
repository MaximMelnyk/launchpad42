"""Curriculum service — exercise listing, today's plan, prerequisites."""

from datetime import date, datetime, timezone

import structlog
from google.cloud.firestore_v1 import AsyncClient
from google.cloud.firestore_v1.base_query import FieldFilter

from app.core.config import settings
from app.models.exercise import Exercise, ExerciseProgress, ExerciseStatus

logger = structlog.get_logger()

# Phase-to-day mapping (inclusive ranges)
PHASE_DAY_RANGES: dict[str, tuple[int, int]] = {
    "phase0": (1, 13),
    "phase1": (11, 30),
    "phase2": (31, 70),
    "phase3": (71, 105),
    "phase4": (106, 118),
    "phase5": (119, 125),
}


def get_current_day(day1_date: str | None = None) -> int:
    """Calculate current training day from day1_date config.

    Returns 1-based day number. Day 1 = day1_date itself.
    """
    d1_str = day1_date or settings.day1_date
    d1 = datetime.strptime(d1_str, "%Y-%m-%d").date()
    today = date.today()
    delta = (today - d1).days
    return max(1, delta + 1)


def get_phase_for_day(day: int) -> str:
    """Determine which phase a given day belongs to."""
    for phase, (start, end) in PHASE_DAY_RANGES.items():
        if start <= day <= end:
            return phase
    return "phase5"


async def get_today_exercises(uid: str, db: AsyncClient) -> dict:
    """Get today's exercises, review cards, and drill pool.

    Calculate current day from settings.day1_date.
    Query exercises where phase matches user's phase and order corresponds to current day.
    Check prerequisites via exercise_progress collection.
    """
    current_day = get_current_day()
    phase = get_phase_for_day(current_day)

    # Fetch exercises for current phase, ordered by 'order'
    exercises_ref = db.collection("exercises")
    query = exercises_ref.where(filter=FieldFilter("phase", "==", phase))
    exercises: list[dict] = []

    async for doc in query.stream():
        ex_data = doc.to_dict()
        ex_data["id"] = doc.id
        exercises.append(ex_data)

    # Sort by order field
    exercises.sort(key=lambda e: e.get("order", 0))

    # Filter to exercises appropriate for today
    today_exercises: list[dict] = []
    for ex in exercises:
        ex_order = ex.get("order", 0)
        # Each exercise is assigned to a specific day within the phase
        phase_start = PHASE_DAY_RANGES.get(phase, (1, 125))[0]
        ex_day = phase_start + ex_order - 1
        if ex_day == current_day:
            # Check prerequisites
            prereqs_met = await check_prerequisites(uid, ex["id"], db)
            ex["prereqs_met"] = prereqs_met
            today_exercises.append(ex)

    # Fetch review cards due today
    review_cards: list[dict] = []
    now = datetime.now(timezone.utc)
    review_ref = db.collection("review_cards")
    review_query = review_ref.where(
        filter=FieldFilter("next_review", "<=", now)
    )
    async for doc in review_query.stream():
        card_data = doc.to_dict()
        card_data["id"] = doc.id
        review_cards.append(card_data)

    # Fetch drill pool
    drill_data: dict | None = None
    drill_doc = await db.collection("drill_pool").document(uid).get()
    if drill_doc.exists:
        drill_data = drill_doc.to_dict()

    return {
        "current_day": current_day,
        "phase": phase,
        "exercises": today_exercises,
        "review_cards": review_cards,
        "drill": drill_data,
    }


async def get_exercise_detail(exercise_id: str, db: AsyncClient) -> Exercise:
    """Fetch single exercise with content_md."""
    doc = await db.collection("exercises").document(exercise_id).get()
    if not doc.exists:
        raise ValueError(f"Exercise not found: {exercise_id}")
    data = doc.to_dict()
    data["id"] = doc.id
    return Exercise(**data)


async def get_phase_exercises(phase: str, db: AsyncClient) -> list[Exercise]:
    """All exercises for a phase, ordered by 'order' field."""
    query = db.collection("exercises").where(
        filter=FieldFilter("phase", "==", phase)
    )
    exercises: list[Exercise] = []
    async for doc in query.stream():
        data = doc.to_dict()
        data["id"] = doc.id
        exercises.append(Exercise(**data))

    exercises.sort(key=lambda e: e.order)
    return exercises


async def check_prerequisites(
    uid: str, exercise_id: str, db: AsyncClient
) -> bool:
    """Check if all prerequisite exercises are completed."""
    # Fetch the exercise to get prerequisites
    ex_doc = await db.collection("exercises").document(exercise_id).get()
    if not ex_doc.exists:
        return False

    ex_data = ex_doc.to_dict()
    prerequisites = ex_data.get("prerequisites", [])

    if not prerequisites:
        return True

    # Check each prerequisite
    for prereq_id in prerequisites:
        doc_id = f"{uid}_{prereq_id}"
        progress_doc = await db.collection("exercise_progress").document(doc_id).get()
        if not progress_doc.exists:
            return False
        progress_data = progress_doc.to_dict()
        if progress_data.get("status") != ExerciseStatus.COMPLETED.value:
            return False

    return True
