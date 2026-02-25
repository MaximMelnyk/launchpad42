"""Session service — daily session lifecycle: start, end, current day calculation."""

from datetime import date, datetime, timezone

import structlog
from google.cloud.firestore_v1 import AsyncClient

from app.core.config import settings
from app.models.session import Session

logger = structlog.get_logger()


def get_current_day(day1_date: str | None = None) -> int:
    """Calculate current training day from day1_date config.

    Returns 1-based day number. Day 1 = day1_date itself.
    Uses datetime.strptime for validation (fixes deferred P2 issue).
    """
    d1_str = day1_date or settings.day1_date
    # Validate with strptime (not just regex)
    d1 = datetime.strptime(d1_str, "%Y-%m-%d").date()
    today = date.today()
    delta = (today - d1).days
    return max(1, delta + 1)


def validate_date_string(date_str: str) -> date:
    """Validate date string with both regex format and calendar validity.

    Fixes deferred issue from Phase 0: regex-only validation.
    """
    # strptime handles both format and calendar validation
    return datetime.strptime(date_str, "%Y-%m-%d").date()


async def start_session(
    uid: str, mood: str, db: AsyncClient
) -> Session:
    """Create session doc for today. Update user mood_today.

    Doc ID: {uid}_{date} where date=today YYYY-MM-DD.
    """
    today_str = date.today().isoformat()
    doc_id = f"{uid}_{today_str}"
    now = datetime.now(timezone.utc)

    # Check if session already exists
    existing = await db.collection("sessions").document(doc_id).get()
    if existing.exists:
        existing_data = existing.to_dict()
        existing_data["uid"] = uid
        existing_data["date"] = today_str
        logger.info("Session already exists for today", uid=uid, date=today_str)
        return Session(**existing_data)

    session = Session(
        uid=uid,
        date=today_str,
        mood_start=mood,
        started_at=now,
        created_at=now,
    )

    await db.collection("sessions").document(doc_id).set(
        session.model_dump()
    )

    # Update user mood
    await db.collection("users").document(uid).set(
        {"mood_today": mood, "updated_at": now},
        merge=True,
    )

    logger.info("Session started", uid=uid, date=today_str, mood=mood)
    return session


async def end_session(
    uid: str, mood_end: str, duration_minutes: int, db: AsyncClient
) -> Session:
    """End today's session. Calculate total XP earned during session.

    Update weekly_completed_days if exercises were completed.
    """
    today_str = date.today().isoformat()
    doc_id = f"{uid}_{today_str}"
    now = datetime.now(timezone.utc)

    session_doc = await db.collection("sessions").document(doc_id).get()
    if not session_doc.exists:
        raise ValueError("No active session found for today")

    session_data = session_doc.to_dict()
    session_data["uid"] = uid
    session_data["date"] = today_str

    # Update session end fields
    session_data["mood_end"] = mood_end
    session_data["duration_minutes"] = duration_minutes
    session_data["finished_at"] = now

    await db.collection("sessions").document(doc_id).set(
        {
            "mood_end": mood_end,
            "duration_minutes": duration_minutes,
            "finished_at": now,
        },
        merge=True,
    )

    # Update weekly_completed_days if exercises were completed
    exercises_completed = session_data.get("exercises_completed", [])
    if exercises_completed:
        user_doc = await db.collection("users").document(uid).get()
        if user_doc.exists:
            user_data = user_doc.to_dict()
            weekly_days: list[str] = user_data.get("weekly_completed_days", [])
            if today_str not in weekly_days:
                weekly_days.append(today_str)
                await db.collection("users").document(uid).set(
                    {"weekly_completed_days": weekly_days, "updated_at": now},
                    merge=True,
                )

        # Update streak
        from app.services.gamification_service import update_streak
        await update_streak(uid, db)

    logger.info(
        "Session ended",
        uid=uid,
        date=today_str,
        duration=duration_minutes,
        exercises=len(exercises_completed),
    )

    return Session(**session_data)


async def get_current_session(uid: str, db: AsyncClient) -> Session | None:
    """Get today's session or None."""
    today_str = date.today().isoformat()
    doc_id = f"{uid}_{today_str}"

    doc = await db.collection("sessions").document(doc_id).get()
    if not doc.exists:
        return None

    data = doc.to_dict()
    data["uid"] = uid
    data["date"] = today_str
    return Session(**data)
