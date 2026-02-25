"""Tests for session service — session lifecycle, day calculation, date validation."""

from datetime import date, datetime, timedelta
from unittest.mock import patch

import pytest

from app.services.session_service import (
    get_current_day,
    get_current_session,
    start_session,
    validate_date_string,
)
from tests.conftest import TEST_UID, MockFirestoreDB


# --- get_current_day Tests ---


class TestGetCurrentDay:
    """Day calculation from day1_date."""

    def test_day1_is_today(self):
        today_str = date.today().isoformat()
        result = get_current_day(today_str)
        assert result == 1

    def test_day2_is_tomorrow(self):
        yesterday = (date.today() - timedelta(days=1)).isoformat()
        result = get_current_day(yesterday)
        assert result == 2

    def test_day_10(self):
        day1 = date.today() - timedelta(days=9)
        result = get_current_day(day1.isoformat())
        assert result == 10

    def test_future_day1_returns_1(self):
        """If day1 is in the future, return 1 (not negative)."""
        future = (date.today() + timedelta(days=5)).isoformat()
        result = get_current_day(future)
        assert result == 1

    def test_specific_date(self):
        """Test with a known date pair."""
        with patch("app.services.session_service.date") as mock_date:
            mock_date.today.return_value = date(2026, 3, 7)
            mock_date.fromisoformat = date.fromisoformat
            result = get_current_day("2026-02-26")
            assert result == 10  # Feb 26 to Mar 7 = 9 days + 1

    def test_invalid_date_format(self):
        """Invalid date format raises ValueError."""
        with pytest.raises(ValueError):
            get_current_day("26-02-2026")

    def test_invalid_date_value(self):
        """Invalid calendar date raises ValueError."""
        with pytest.raises(ValueError):
            get_current_day("2026-02-30")  # Feb 30 does not exist


# --- validate_date_string Tests ---


class TestValidateDateString:
    """Date string validation with calendar check."""

    def test_valid_date(self):
        result = validate_date_string("2026-03-15")
        assert result == date(2026, 3, 15)

    def test_valid_leap_year(self):
        result = validate_date_string("2028-02-29")
        assert result.month == 2
        assert result.day == 29

    def test_invalid_feb_30(self):
        with pytest.raises(ValueError):
            validate_date_string("2026-02-30")

    def test_invalid_feb_29_non_leap(self):
        with pytest.raises(ValueError):
            validate_date_string("2026-02-29")

    def test_invalid_format(self):
        with pytest.raises(ValueError):
            validate_date_string("2026/03/15")

    def test_invalid_month_13(self):
        with pytest.raises(ValueError):
            validate_date_string("2026-13-01")

    def test_invalid_day_32(self):
        with pytest.raises(ValueError):
            validate_date_string("2026-01-32")


# --- Session Start Tests ---


class TestStartSession:
    """Session creation tests."""

    @pytest.mark.asyncio
    async def test_start_new_session(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"mood_today": None})

        session = await start_session(TEST_UID, "3", db)

        assert session.uid == TEST_UID
        assert session.date == date.today().isoformat()
        assert session.mood_start == "3"
        assert session.started_at is not None

    @pytest.mark.asyncio
    async def test_start_existing_session_returns_it(self):
        """If session already exists for today, return it."""
        today_str = date.today().isoformat()
        doc_id = f"{TEST_UID}_{today_str}"

        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"mood_today": "2"})
        db.seed("sessions", doc_id, {
            "uid": TEST_UID,
            "date": today_str,
            "mood_start": "2",
            "started_at": datetime(2026, 2, 26, 10, 0),
            "created_at": datetime(2026, 2, 26, 10, 0),
            "exercises_completed": [],
            "xp_earned": 0,
            "drill_completed": False,
            "review_completed": False,
            "vocab_completed": False,
            "duration_minutes": 0,
        })

        session = await start_session(TEST_UID, "5", db)
        assert session.mood_start == "2"  # Original mood preserved

    @pytest.mark.asyncio
    async def test_start_session_updates_mood(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"mood_today": None})

        await start_session(TEST_UID, "4", db)

        user_data = db._collections["users"][TEST_UID]
        assert user_data["mood_today"] == "4"


# --- Current Session Tests ---


class TestGetCurrentSession:
    """Current session retrieval tests."""

    @pytest.mark.asyncio
    async def test_no_session_returns_none(self):
        db = MockFirestoreDB()
        result = await get_current_session(TEST_UID, db)
        assert result is None

    @pytest.mark.asyncio
    async def test_existing_session_returned(self):
        today_str = date.today().isoformat()
        doc_id = f"{TEST_UID}_{today_str}"

        db = MockFirestoreDB()
        db.seed("sessions", doc_id, {
            "uid": TEST_UID,
            "date": today_str,
            "mood_start": "3",
            "started_at": datetime(2026, 2, 26, 10, 0),
            "created_at": datetime(2026, 2, 26, 10, 0),
            "exercises_completed": ["c00_ex00"],
            "xp_earned": 35,
            "drill_completed": False,
            "review_completed": False,
            "vocab_completed": False,
            "duration_minutes": 60,
        })

        session = await get_current_session(TEST_UID, db)
        assert session is not None
        assert session.mood_start == "3"
        assert session.xp_earned == 35


# --- Weekly Completed Days Tests ---


class TestWeeklyCompletedDays:
    """Weekly tracking tests."""

    @pytest.mark.asyncio
    async def test_session_with_exercises_adds_to_weekly(self):
        """end_session should add today to weekly_completed_days when exercises are done."""
        today_str = date.today().isoformat()
        doc_id = f"{TEST_UID}_{today_str}"

        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {
            "weekly_completed_days": [],
            "streak_days": 0,
            "shields": 0,
        })
        db.seed("sessions", doc_id, {
            "uid": TEST_UID,
            "date": today_str,
            "mood_start": "3",
            "exercises_completed": ["c00_ex00"],
            "xp_earned": 35,
            "started_at": datetime.utcnow(),
            "created_at": datetime.utcnow(),
            "drill_completed": False,
            "review_completed": False,
            "vocab_completed": False,
            "duration_minutes": 0,
        })

        from app.services.session_service import end_session

        session = await end_session(TEST_UID, "4", 120, db)

        # Check user weekly days updated
        user_data = db._collections["users"][TEST_UID]
        assert today_str in user_data.get("weekly_completed_days", [])
