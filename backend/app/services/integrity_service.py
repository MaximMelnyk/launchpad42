"""Integrity monitoring — timing anomaly detection + tutor usage for weekly reports."""

from datetime import date, datetime, timedelta, timezone
from zoneinfo import ZoneInfo

import structlog
from google.cloud.firestore_v1 import AsyncClient
from google.cloud.firestore_v1.base_query import FieldFilter

logger = structlog.get_logger()

# Thresholds
SPEED_ANOMALY_RATIO = 0.20  # < 20% of estimated = anomaly
BULK_EXERCISE_COUNT = 5  # 5+ exercises in 1 hour
UNUSUAL_HOUR_START = 0  # midnight
UNUSUAL_HOUR_END = 6  # 6 AM
FRANCE_TZ = ZoneInfo("Europe/Paris")  # CET/CEST auto-handled
CONSISTENT_FAST_RATIO = 0.30  # average < 30% = red flag
CONSISTENT_FAST_MIN_EXERCISES = 3  # need at least 3 to flag


def _ensure_aware(dt: datetime | str | None) -> datetime | None:
    """Parse and ensure datetime is timezone-aware (UTC)."""
    if dt is None:
        return None
    if isinstance(dt, str):
        dt = datetime.fromisoformat(dt)
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt


async def analyze_weekly_integrity(
    uid: str,
    db: AsyncClient,
    week_start: date | None = None,
    reference_date: date | None = None,
) -> dict:
    """Analyze exercise completions for timing anomalies.

    Args:
        reference_date: override for date.today() (for testing DST/future weeks).

    Returns dict with speed_anomalies, unusual_hours, bulk_completions,
    consistently_fast flag, avg_time_ratio_pct, exercises_analyzed.
    """
    today = reference_date or datetime.now(FRANCE_TZ).date()
    monday = week_start or (today - timedelta(days=today.weekday()))

    # Fetch all completed exercises for this user
    progress_query = db.collection("exercise_progress").where(
        filter=FieldFilter("uid", "==", uid)
    ).where(
        filter=FieldFilter("status", "==", "completed")
    )

    completions: list[dict] = []
    async for doc in progress_query.stream():
        data = doc.to_dict()
        completed_at = _ensure_aware(data.get("completed_at"))
        if not completed_at:
            continue
        # Only this week's completions (France timezone for consistency)
        france_date = completed_at.astimezone(FRANCE_TZ).date()
        if france_date < monday or france_date > today:
            continue
        completions.append({
            "exercise_id": data.get("exercise_id"),
            "started_at": _ensure_aware(data.get("started_at")),
            "completed_at": completed_at,
        })

    speed_anomalies: list[dict] = []
    unusual_hours: list[dict] = []
    time_ratios: list[float] = []

    for comp in completions:
        ex_id = comp["exercise_id"]
        started_at = comp["started_at"]
        completed_at = comp["completed_at"]

        # Unusual hours check (France timezone, DST-aware)
        france_hour = completed_at.astimezone(FRANCE_TZ).hour
        if UNUSUAL_HOUR_START <= france_hour < UNUSUAL_HOUR_END:
            unusual_hours.append({
                "exercise_id": ex_id,
                "hour": france_hour,
            })

        if not started_at:
            continue

        # Fetch exercise estimated_minutes
        ex_doc = await db.collection("exercises").document(ex_id).get()
        if not ex_doc.exists:
            continue
        estimated_minutes = ex_doc.to_dict().get("estimated_minutes", 15)

        actual_seconds = (completed_at - started_at).total_seconds()
        if actual_seconds <= 0:
            continue
        expected_seconds = estimated_minutes * 60
        if expected_seconds <= 0:
            continue

        ratio = actual_seconds / expected_seconds
        time_ratios.append(ratio)

        # Speed anomaly
        if ratio < SPEED_ANOMALY_RATIO:
            actual_min = round(actual_seconds / 60, 1)
            speed_anomalies.append({
                "exercise_id": ex_id,
                "actual_minutes": actual_min,
                "expected_minutes": estimated_minutes,
                "ratio_pct": round(ratio * 100),
            })

    # Bulk completion: 5+ exercises in any 1-hour window
    bulk_completions: list[dict] = []
    sorted_comps = sorted(completions, key=lambda c: c["completed_at"])
    for i, comp in enumerate(sorted_comps):
        window_end = comp["completed_at"] + timedelta(hours=1)
        in_window = [c for c in sorted_comps[i:] if c["completed_at"] <= window_end]
        if len(in_window) >= BULK_EXERCISE_COUNT:
            bulk_completions.append({
                "count": len(in_window),
                "window_start": comp["completed_at"].strftime("%d.%m %H:%M"),
            })
            break  # one flag is enough

    # Consistent speed check
    avg_ratio = sum(time_ratios) / len(time_ratios) if time_ratios else 1.0
    consistently_fast = (
        avg_ratio < CONSISTENT_FAST_RATIO
        and len(time_ratios) >= CONSISTENT_FAST_MIN_EXERCISES
    )

    return {
        "speed_anomalies": speed_anomalies,
        "unusual_hours": unusual_hours,
        "bulk_completions": bulk_completions,
        "consistently_fast": consistently_fast,
        "avg_time_ratio_pct": round(avg_ratio * 100) if time_ratios else None,
        "exercises_analyzed": len(completions),
    }


async def get_weekly_tutor_usage(
    uid: str, db: AsyncClient, week_start: date | None = None
) -> dict:
    """Query tutor_usage collection for the week.

    Returns {total_questions, days_used}.
    """
    today = datetime.now(FRANCE_TZ).date()
    monday = week_start or (today - timedelta(days=today.weekday()))

    total_questions = 0
    days_used = 0

    for i in range(7):
        d = monday + timedelta(days=i)
        if d > today:
            break
        doc_id = f"{uid}_{d.isoformat()}"
        doc = await db.collection("tutor_usage").document(doc_id).get()
        if doc.exists:
            count = doc.to_dict().get("count", 0)
            total_questions += count
            if count > 0:
                days_used += 1

    return {
        "total_questions": total_questions,
        "days_used": days_used,
    }
