"""Tests for gamification service — XP, levels, streaks, shields, SM-2, achievements."""

from datetime import date, datetime, timedelta
from unittest.mock import AsyncMock, patch

import pytest

from app.models.exercise import Exercise, ExerciseProgress, ExerciseStatus
from app.models.gamification import (
    LEVEL_XP_THRESHOLDS,
    XP_BONUS_DRILL,
    XP_BONUS_FIRST_ATTEMPT,
    XP_BONUS_NO_HINTS,
    XP_BONUS_VOCAB,
    AchievementId,
)
from app.services.gamification_service import (
    SM2_INTERVALS,
    _next_sm2_interval,
    check_level_up,
    get_gamification_profile,
    process_drill,
    process_review,
    update_streak,
)
from tests.conftest import TEST_UID, MockFirestoreDB


# --- SM-2 Lite Interval Tests ---


class TestSM2Intervals:
    """SM-2 lite interval progression tests."""

    def test_interval_3_to_5(self):
        assert _next_sm2_interval(3) == 5

    def test_interval_5_to_8(self):
        assert _next_sm2_interval(5) == 8

    def test_interval_8_to_14(self):
        assert _next_sm2_interval(8) == 14

    def test_interval_14_to_30(self):
        assert _next_sm2_interval(14) == 30

    def test_interval_30_stays_30(self):
        assert _next_sm2_interval(30) == 30

    def test_interval_non_standard_rounds_up(self):
        assert _next_sm2_interval(4) == 5
        assert _next_sm2_interval(1) == 3
        assert _next_sm2_interval(10) == 14

    def test_interval_above_max(self):
        assert _next_sm2_interval(60) == 30

    def test_full_progression(self):
        interval = SM2_INTERVALS[0]  # Start at 3
        for expected in SM2_INTERVALS[1:]:
            interval = _next_sm2_interval(interval)
            assert interval == expected


# --- Level Up Tests ---


class TestLevelUp:
    """Level up logic tests."""

    @pytest.mark.asyncio
    async def test_level_up_when_threshold_met(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {
            "level": 0,
            "xp": 200,  # Threshold for level 1
        })

        result = await check_level_up(TEST_UID, db)
        assert result is True

    @pytest.mark.asyncio
    async def test_no_level_up_below_threshold(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {
            "level": 0,
            "xp": 199,  # Below threshold for level 1
        })

        result = await check_level_up(TEST_UID, db)
        assert result is False

    @pytest.mark.asyncio
    async def test_no_level_up_at_max(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {
            "level": 6,
            "xp": 99999,
        })

        result = await check_level_up(TEST_UID, db)
        assert result is False

    @pytest.mark.asyncio
    async def test_level_up_updates_user(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {
            "level": 1,
            "xp": 600,  # Threshold for level 2
        })

        result = await check_level_up(TEST_UID, db)
        assert result is True

        # Verify level was updated
        user_data = db._collections["users"][TEST_UID]
        assert user_data["level"] == 2

    @pytest.mark.asyncio
    async def test_no_user_returns_false(self):
        db = MockFirestoreDB()
        result = await check_level_up("nonexistent", db)
        assert result is False

    @pytest.mark.asyncio
    async def test_all_thresholds(self):
        """Verify each level threshold triggers level up."""
        for level in range(6):
            db = MockFirestoreDB()
            threshold = LEVEL_XP_THRESHOLDS[level + 1]
            db.seed("users", TEST_UID, {
                "level": level,
                "xp": threshold,
            })
            result = await check_level_up(TEST_UID, db)
            assert result is True, f"Level {level} -> {level+1} failed at {threshold} XP"


# --- Streak Tests ---


class TestStreak:
    """Streak and shield logic tests."""

    @pytest.mark.asyncio
    async def test_streak_adds_today(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {
            "weekly_completed_days": [],
            "streak_days": 0,
            "shields": 0,
        })

        result = await update_streak(TEST_UID, db)
        today_str = date.today().isoformat()
        assert today_str in db._collections["users"][TEST_UID]["weekly_completed_days"]

    @pytest.mark.asyncio
    async def test_streak_no_duplicate(self):
        today_str = date.today().isoformat()
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {
            "weekly_completed_days": [today_str],
            "streak_days": 1,
            "shields": 0,
        })

        await update_streak(TEST_UID, db)
        days = db._collections["users"][TEST_UID]["weekly_completed_days"]
        assert days.count(today_str) == 1

    @pytest.mark.asyncio
    async def test_streak_consecutive_days(self):
        today = date.today()
        yesterday = today - timedelta(days=1)
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {
            "weekly_completed_days": [yesterday.isoformat()],
            "streak_days": 1,
            "shields": 0,
        })

        result = await update_streak(TEST_UID, db)
        assert result["streak_days"] == 2

    @pytest.mark.asyncio
    async def test_shield_earned_at_7_days(self):
        today = date.today()
        days = [(today - timedelta(days=i)).isoformat() for i in range(6, -1, -1)]
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {
            "weekly_completed_days": days[:-1],  # 6 previous days
            "streak_days": 6,
            "shields": 0,
        })

        result = await update_streak(TEST_UID, db)
        assert result["shields"] == 1

    @pytest.mark.asyncio
    async def test_shields_max_3(self):
        today = date.today()
        # 21+ consecutive days
        days = [(today - timedelta(days=i)).isoformat() for i in range(20, -1, -1)]
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {
            "weekly_completed_days": days[:-1],  # 20 previous days
            "streak_days": 20,
            "shields": 2,
        })

        result = await update_streak(TEST_UID, db)
        assert result["shields"] == 3  # max is 3

    @pytest.mark.asyncio
    async def test_no_user_returns_empty(self):
        db = MockFirestoreDB()
        result = await update_streak("nonexistent", db)
        assert result["streak_days"] == 0


# --- Gamification Profile Tests ---


class TestGamificationProfile:
    """Gamification profile aggregation tests."""

    @pytest.mark.asyncio
    async def test_basic_profile(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {
            "level": 0,
            "xp": 50,
            "phase": "phase0",
            "streak_days": 3,
            "shields": 0,
            "weekly_completed_days": [],
        })

        result = await get_gamification_profile(TEST_UID, db)
        assert result["level"] == 0
        assert result["level_name"] == "Init"
        assert result["xp"] == 50
        assert result["next_level_xp"] == 200
        assert result["xp_to_next"] == 150
        assert result["streak_days"] == 3

    @pytest.mark.asyncio
    async def test_max_level_profile(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {
            "level": 6,
            "xp": 6000,
            "phase": "phase5",
            "streak_days": 50,
            "shields": 3,
            "weekly_completed_days": [],
        })

        result = await get_gamification_profile(TEST_UID, db)
        assert result["level_name"] == "Ready"
        assert result["next_level_xp"] == LEVEL_XP_THRESHOLDS[6]

    @pytest.mark.asyncio
    async def test_missing_user_raises(self):
        db = MockFirestoreDB()
        with pytest.raises(ValueError, match="User not found"):
            await get_gamification_profile("nonexistent", db)


# --- Drill Tests ---


class TestDrill:
    """Drill processing tests."""

    @pytest.mark.asyncio
    async def test_fast_drill_earns_more_xp(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 100})
        db.seed("exercises", "ft_strlen", {"estimated_minutes": 15})

        result = await process_drill(TEST_UID, "ft_strlen", 600, db)  # 10 min < 15 min
        assert result["correct"] is True
        assert result["xp_earned"] == XP_BONUS_DRILL * 2  # 20

    @pytest.mark.asyncio
    async def test_slow_drill_earns_base_xp(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 100})
        db.seed("exercises", "ft_strlen", {"estimated_minutes": 15})

        result = await process_drill(TEST_UID, "ft_strlen", 1200, db)  # 20 min > 15 min
        assert result["xp_earned"] == XP_BONUS_DRILL  # 10

    @pytest.mark.asyncio
    async def test_drill_updates_pool(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 0})
        db.seed("drill_pool", TEST_UID, {
            "uid": TEST_UID,
            "function_queue": ["ft_strlen", "ft_putchar"],
            "last_drilled": {},
        })

        await process_drill(TEST_UID, "ft_strlen", 600, db)

        pool = db._collections["drill_pool"][TEST_UID]
        assert pool["function_queue"] == ["ft_putchar", "ft_strlen"]

    @pytest.mark.asyncio
    async def test_drill_creates_pool_if_missing(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 0})

        await process_drill(TEST_UID, "ft_strlen", 600, db)

        assert TEST_UID in db._collections.get("drill_pool", {})


# --- Review Tests ---


class TestReview:
    """Review card (SM-2 lite) processing tests."""

    @pytest.mark.asyncio
    async def test_correct_advances_interval(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 0})
        db.seed("review_cards", "card1", {
            "interval_days": 3,
            "review_count": 1,
            "correct_count": 1,
        })

        result = await process_review(TEST_UID, "card1", True, db)
        assert result["interval_days"] == 5  # 3 -> 5
        assert result["xp_earned"] == XP_BONUS_VOCAB

    @pytest.mark.asyncio
    async def test_incorrect_resets_interval(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 0})
        db.seed("review_cards", "card1", {
            "interval_days": 14,
            "review_count": 5,
            "correct_count": 4,
        })

        result = await process_review(TEST_UID, "card1", False, db)
        assert result["interval_days"] == 3  # Reset
        assert result["xp_earned"] == 0

    @pytest.mark.asyncio
    async def test_max_interval_stays(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 0})
        db.seed("review_cards", "card1", {
            "interval_days": 30,
            "review_count": 10,
            "correct_count": 10,
        })

        result = await process_review(TEST_UID, "card1", True, db)
        assert result["interval_days"] == 30  # Cap

    @pytest.mark.asyncio
    async def test_missing_card_raises(self):
        db = MockFirestoreDB()
        with pytest.raises(ValueError, match="Review card not found"):
            await process_review(TEST_UID, "nonexistent", True, db)

    @pytest.mark.asyncio
    async def test_correct_awards_xp(self):
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 100})
        db.seed("review_cards", "card1", {
            "interval_days": 3,
            "review_count": 0,
            "correct_count": 0,
        })

        await process_review(TEST_UID, "card1", True, db)
        assert db._collections["users"][TEST_UID]["xp"] == 100 + XP_BONUS_VOCAB
