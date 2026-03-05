"""Tests for integrity_service — timing anomaly detection + tutor usage."""

from datetime import date, datetime, timedelta, timezone

import pytest

from app.services.integrity_service import (
    BULK_EXERCISE_COUNT,
    SPEED_ANOMALY_RATIO,
    analyze_weekly_integrity,
    get_weekly_tutor_usage,
)
from tests.conftest import TEST_UID

# Fixed dates for deterministic tests (CET winter, UTC+1)
MONDAY = date(2026, 1, 5)
FRIDAY = date(2026, 1, 9)


@pytest.fixture
def integrity_db(mock_db, mock_exercise):
    """DB seeded with user + exercise for integrity tests."""
    mock_db.seed("users", TEST_UID, {
        "uid": TEST_UID,
        "level": 1,
        "xp": 100,
        "phase": "phase2",
        "created_at": datetime(2026, 2, 26, tzinfo=timezone.utc),
    })
    mock_db.seed("exercises", "c02_ex00_ft_strcpy", {
        "id": "c02_ex00_ft_strcpy",
        "module": "c02",
        "phase": "phase2",
        "title": "ft_strcpy",
        "difficulty": 2,
        "xp": 25,
        "estimated_minutes": 20,
    })
    mock_db.seed("exercises", "c02_ex01_ft_strncpy", {
        "id": "c02_ex01_ft_strncpy",
        "module": "c02",
        "phase": "phase2",
        "title": "ft_strncpy",
        "difficulty": 2,
        "xp": 25,
        "estimated_minutes": 25,
    })
    mock_db.seed("exercises", "c00_ex00_ft_putchar", mock_exercise)
    return mock_db


# --- Speed anomaly tests ---

@pytest.mark.asyncio
async def test_speed_anomaly_flagged(integrity_db):
    """Exercise completed in <20% of estimated time is flagged."""
    # ft_strcpy (20 min estimate) completed in 2 min = 10%
    base = datetime(2026, 1, 5, 10, 0, tzinfo=timezone.utc)
    integrity_db.seed(
        "exercise_progress",
        f"{TEST_UID}_c02_ex00_ft_strcpy",
        {
            "uid": TEST_UID,
            "exercise_id": "c02_ex00_ft_strcpy",
            "status": "completed",
            "started_at": base,
            "completed_at": base + timedelta(minutes=2),
        },
    )

    result = await analyze_weekly_integrity(
        TEST_UID, integrity_db, week_start=MONDAY, reference_date=FRIDAY,
    )
    assert len(result["speed_anomalies"]) == 1
    assert result["speed_anomalies"][0]["exercise_id"] == "c02_ex00_ft_strcpy"
    assert result["speed_anomalies"][0]["ratio_pct"] == 10


@pytest.mark.asyncio
async def test_normal_speed_not_flagged(integrity_db):
    """Exercise completed in normal time is not flagged."""
    base = datetime(2026, 1, 5, 10, 0, tzinfo=timezone.utc)
    integrity_db.seed(
        "exercise_progress",
        f"{TEST_UID}_c02_ex00_ft_strcpy",
        {
            "uid": TEST_UID,
            "exercise_id": "c02_ex00_ft_strcpy",
            "status": "completed",
            "started_at": base,
            "completed_at": base + timedelta(minutes=15),
        },
    )

    result = await analyze_weekly_integrity(
        TEST_UID, integrity_db, week_start=MONDAY, reference_date=FRIDAY,
    )
    assert len(result["speed_anomalies"]) == 0


# --- Unusual hours tests ---

@pytest.mark.asyncio
async def test_unusual_hours_flagged(integrity_db):
    """Submissions at 3 AM (France time) are flagged."""
    # CET (UTC+1): 2 AM UTC = 3 AM France
    night_time = datetime(2026, 1, 5, 2, 0, tzinfo=timezone.utc)
    integrity_db.seed(
        "exercise_progress",
        f"{TEST_UID}_c02_ex00_ft_strcpy",
        {
            "uid": TEST_UID,
            "exercise_id": "c02_ex00_ft_strcpy",
            "status": "completed",
            "started_at": night_time - timedelta(minutes=15),
            "completed_at": night_time,
        },
    )

    result = await analyze_weekly_integrity(
        TEST_UID, integrity_db, week_start=MONDAY, reference_date=FRIDAY,
    )
    assert len(result["unusual_hours"]) == 1
    assert result["unusual_hours"][0]["hour"] == 3


@pytest.mark.asyncio
async def test_daytime_not_flagged(integrity_db):
    """Submissions at 3 PM are not flagged as unusual."""
    # CET (UTC+1): 14 UTC = 15 France
    day_time = datetime(2026, 1, 5, 14, 0, tzinfo=timezone.utc)
    integrity_db.seed(
        "exercise_progress",
        f"{TEST_UID}_c02_ex00_ft_strcpy",
        {
            "uid": TEST_UID,
            "exercise_id": "c02_ex00_ft_strcpy",
            "status": "completed",
            "started_at": day_time - timedelta(minutes=15),
            "completed_at": day_time,
        },
    )

    result = await analyze_weekly_integrity(
        TEST_UID, integrity_db, week_start=MONDAY, reference_date=FRIDAY,
    )
    assert len(result["unusual_hours"]) == 0


# --- Bulk completion tests ---

@pytest.mark.asyncio
async def test_bulk_completion_flagged(integrity_db):
    """5+ exercises in 1 hour triggers bulk flag."""
    base = datetime(2026, 1, 5, 10, 0, tzinfo=timezone.utc)

    for i in range(5):
        ex_id = f"bulk_ex_{i}"
        integrity_db.seed("exercises", ex_id, {
            "id": ex_id, "module": "c00", "phase": "phase0",
            "title": f"Bulk {i}", "difficulty": 1, "xp": 10,
            "estimated_minutes": 15,
        })
        integrity_db.seed(
            "exercise_progress",
            f"{TEST_UID}_{ex_id}",
            {
                "uid": TEST_UID,
                "exercise_id": ex_id,
                "status": "completed",
                "started_at": base + timedelta(minutes=i * 10),
                "completed_at": base + timedelta(minutes=i * 10 + 3),
            },
        )

    result = await analyze_weekly_integrity(
        TEST_UID, integrity_db, week_start=MONDAY, reference_date=FRIDAY,
    )
    assert len(result["bulk_completions"]) == 1
    assert result["bulk_completions"][0]["count"] >= BULK_EXERCISE_COUNT


@pytest.mark.asyncio
async def test_no_bulk_with_spread_exercises(integrity_db):
    """4 exercises spread over 3 hours is not flagged."""
    base = datetime(2026, 1, 5, 10, 0, tzinfo=timezone.utc)

    for i in range(4):
        ex_id = f"spread_ex_{i}"
        integrity_db.seed("exercises", ex_id, {
            "id": ex_id, "module": "c00", "phase": "phase0",
            "title": f"Spread {i}", "difficulty": 1, "xp": 10,
            "estimated_minutes": 15,
        })
        integrity_db.seed(
            "exercise_progress",
            f"{TEST_UID}_{ex_id}",
            {
                "uid": TEST_UID,
                "exercise_id": ex_id,
                "status": "completed",
                "started_at": base + timedelta(hours=i),
                "completed_at": base + timedelta(hours=i, minutes=12),
            },
        )

    result = await analyze_weekly_integrity(
        TEST_UID, integrity_db, week_start=MONDAY, reference_date=FRIDAY,
    )
    assert len(result["bulk_completions"]) == 0


# --- Consistently fast tests ---

@pytest.mark.asyncio
async def test_consistently_fast_flagged(integrity_db):
    """Average <30% time across 3+ exercises is flagged."""
    base = datetime(2026, 1, 5, 10, 0, tzinfo=timezone.utc)

    exercises = [
        ("c02_ex00_ft_strcpy", 20),
        ("c02_ex01_ft_strncpy", 25),
        ("c00_ex00_ft_putchar", 15),
    ]
    for j, (ex_id, est_min) in enumerate(exercises):
        actual_min = est_min * 0.2  # 20% of estimated
        integrity_db.seed(
            "exercise_progress",
            f"{TEST_UID}_{ex_id}",
            {
                "uid": TEST_UID,
                "exercise_id": ex_id,
                "status": "completed",
                "started_at": base + timedelta(hours=j),
                "completed_at": base + timedelta(hours=j, minutes=actual_min),
            },
        )

    result = await analyze_weekly_integrity(
        TEST_UID, integrity_db, week_start=MONDAY, reference_date=FRIDAY,
    )
    assert result["consistently_fast"] is True
    assert result["avg_time_ratio_pct"] == 20


@pytest.mark.asyncio
async def test_not_consistently_fast_with_normal_times(integrity_db):
    """Average >30% time is not flagged."""
    base = datetime(2026, 1, 5, 10, 0, tzinfo=timezone.utc)

    exercises = [
        ("c02_ex00_ft_strcpy", 20),
        ("c02_ex01_ft_strncpy", 25),
        ("c00_ex00_ft_putchar", 15),
    ]
    for j, (ex_id, est_min) in enumerate(exercises):
        actual_min = est_min * 0.7  # 70% of estimated
        integrity_db.seed(
            "exercise_progress",
            f"{TEST_UID}_{ex_id}",
            {
                "uid": TEST_UID,
                "exercise_id": ex_id,
                "status": "completed",
                "started_at": base + timedelta(hours=j),
                "completed_at": base + timedelta(hours=j, minutes=actual_min),
            },
        )

    result = await analyze_weekly_integrity(
        TEST_UID, integrity_db, week_start=MONDAY, reference_date=FRIDAY,
    )
    assert result["consistently_fast"] is False


# --- Empty week tests ---

@pytest.mark.asyncio
async def test_empty_week_no_anomalies(integrity_db):
    """No completions = no anomalies."""
    result = await analyze_weekly_integrity(
        TEST_UID, integrity_db, week_start=MONDAY, reference_date=FRIDAY,
    )
    assert result["speed_anomalies"] == []
    assert result["unusual_hours"] == []
    assert result["bulk_completions"] == []
    assert result["consistently_fast"] is False
    assert result["exercises_analyzed"] == 0


# --- Tutor usage tests ---

@pytest.mark.asyncio
async def test_tutor_usage_counted(integrity_db):
    """Tutor usage correctly sums daily question counts."""
    for i in range(3):
        d = MONDAY + timedelta(days=i)
        integrity_db.seed(
            "tutor_usage",
            f"{TEST_UID}_{d.isoformat()}",
            {"uid": TEST_UID, "date": d.isoformat(), "count": 5},
        )

    result = await get_weekly_tutor_usage(
        TEST_UID, integrity_db, week_start=MONDAY, reference_date=FRIDAY,
    )
    assert result["total_questions"] == 15
    assert result["days_used"] == 3


@pytest.mark.asyncio
async def test_tutor_not_used(integrity_db):
    """No tutor usage returns zeros."""
    result = await get_weekly_tutor_usage(
        TEST_UID, integrity_db, week_start=MONDAY, reference_date=FRIDAY,
    )
    assert result["total_questions"] == 0
    assert result["days_used"] == 0


# --- Previous week exclusion ---

@pytest.mark.asyncio
async def test_previous_week_excluded(integrity_db):
    """Completions from previous week are not included."""
    last_week = datetime(2025, 12, 29, 10, 0, tzinfo=timezone.utc)  # week before MONDAY

    integrity_db.seed(
        "exercise_progress",
        f"{TEST_UID}_c02_ex00_ft_strcpy",
        {
            "uid": TEST_UID,
            "exercise_id": "c02_ex00_ft_strcpy",
            "status": "completed",
            "started_at": last_week,
            "completed_at": last_week + timedelta(minutes=1),
        },
    )

    result = await analyze_weekly_integrity(
        TEST_UID, integrity_db, week_start=MONDAY, reference_date=FRIDAY,
    )
    assert result["exercises_analyzed"] == 0


# --- P1 edge cases (Codex review cycle 1) ---

@pytest.mark.asyncio
async def test_negative_duration_skipped(integrity_db):
    """Reversed timestamps (started_at > completed_at) are skipped, not flagged."""
    base = datetime(2026, 1, 5, 10, 0, tzinfo=timezone.utc)

    # started_at AFTER completed_at = negative duration
    integrity_db.seed(
        "exercise_progress",
        f"{TEST_UID}_c02_ex00_ft_strcpy",
        {
            "uid": TEST_UID,
            "exercise_id": "c02_ex00_ft_strcpy",
            "status": "completed",
            "started_at": base + timedelta(minutes=20),
            "completed_at": base,
        },
    )

    result = await analyze_weekly_integrity(
        TEST_UID, integrity_db, week_start=MONDAY, reference_date=FRIDAY,
    )
    assert len(result["speed_anomalies"]) == 0
    assert result["avg_time_ratio_pct"] is None  # no valid ratios


@pytest.mark.asyncio
async def test_dst_unusual_hours_cest(integrity_db):
    """During CEST (UTC+2), 3 AM UTC = 5 AM France = still unusual."""
    summer_monday = date(2026, 7, 6)
    night_utc = datetime(2026, 7, 6, 3, 0, tzinfo=timezone.utc)

    integrity_db.seed(
        "exercise_progress",
        f"{TEST_UID}_c02_ex00_ft_strcpy",
        {
            "uid": TEST_UID,
            "exercise_id": "c02_ex00_ft_strcpy",
            "status": "completed",
            "started_at": night_utc - timedelta(minutes=10),
            "completed_at": night_utc,
        },
    )

    result = await analyze_weekly_integrity(
        TEST_UID, integrity_db,
        week_start=summer_monday,
        reference_date=date(2026, 7, 10),
    )
    assert len(result["unusual_hours"]) == 1
    assert result["unusual_hours"][0]["hour"] == 5  # CEST, not CET


@pytest.mark.asyncio
async def test_dst_daytime_not_flagged_cest(integrity_db):
    """During CEST (UTC+2), 8 AM UTC = 10 AM France = normal."""
    summer_monday = date(2026, 7, 6)
    day_utc = datetime(2026, 7, 6, 8, 0, tzinfo=timezone.utc)

    integrity_db.seed(
        "exercise_progress",
        f"{TEST_UID}_c02_ex00_ft_strcpy",
        {
            "uid": TEST_UID,
            "exercise_id": "c02_ex00_ft_strcpy",
            "status": "completed",
            "started_at": day_utc - timedelta(minutes=15),
            "completed_at": day_utc,
        },
    )

    result = await analyze_weekly_integrity(
        TEST_UID, integrity_db,
        week_start=summer_monday,
        reference_date=date(2026, 7, 10),
    )
    assert len(result["unusual_hours"]) == 0
