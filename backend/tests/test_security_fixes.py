"""Tests for P0/P1 security fixes — anti-farming, access control, cooldown computation."""

from datetime import date, datetime, timedelta, timezone

import pytest

from app.models.exercise import ExerciseStatus
from app.models.gamification import XP_BONUS_DRILL, XP_BONUS_VOCAB
from app.services.exercise_service import submit_exercise
from app.services.exam_service import check_cooldown
from app.services.gamification_service import (
    check_achievements,
    process_drill,
    process_review,
)
from app.models.exercise import ExerciseSubmission
from tests.conftest import TEST_UID, MockFirestoreDB


# --- P1-4: Exercise Re-submit XP Farming ---


class TestExerciseResubmitPrevention:
    """P1-4: Re-submitting a completed exercise should not grant XP."""

    @pytest.mark.asyncio
    async def test_resubmit_completed_returns_zero_xp(self):
        """Already completed exercise returns xp_earned=0, already_completed=True."""
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 100, "level": 0})
        db.seed("exercises", "c00_ex00", {
            "id": "c00_ex00",
            "module": "c00",
            "phase": "phase2",
            "title": "ft_putchar",
            "difficulty": 1,
            "xp": 20,
            "estimated_minutes": 15,
        })
        # Exercise already completed
        db.seed("exercise_progress", f"{TEST_UID}_c00_ex00", {
            "uid": TEST_UID,
            "exercise_id": "c00_ex00",
            "status": ExerciseStatus.COMPLETED.value,
            "attempts": 1,
            "hints_used": 0,
            "xp_earned": 35,
            "hash_code": "abcd1234",
            "first_attempt_pass": True,
            "started_at": datetime(2026, 2, 26, 10, 0),
            "completed_at": datetime(2026, 2, 26, 10, 15),
            "updated_at": datetime(2026, 2, 26, 10, 15),
        })

        submission = ExerciseSubmission(hash_code="abcd1234", hints_used=0)
        result = await submit_exercise(TEST_UID, "c00_ex00", submission, db)

        assert result["xp_earned"] == 0
        assert result["already_completed"] is True
        assert result["level_up"] is False
        assert result["achievements_unlocked"] == []
        # User XP should NOT have changed
        assert db._collections["users"][TEST_UID]["xp"] == 100

    @pytest.mark.asyncio
    async def test_first_submit_grants_xp(self):
        """First submission of an exercise should grant XP normally."""
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 100, "level": 0})
        db.seed("exercises", "c00_ex00", {
            "id": "c00_ex00",
            "module": "c00",
            "phase": "phase2",
            "title": "ft_putchar",
            "difficulty": 1,
            "xp": 20,
            "estimated_minutes": 15,
        })

        submission = ExerciseSubmission(hash_code="abcd1234", hints_used=0)
        result = await submit_exercise(TEST_UID, "c00_ex00", submission, db)

        assert result["xp_earned"] > 0
        assert "already_completed" not in result

    @pytest.mark.asyncio
    async def test_submit_without_session_auto_creates_session(self):
        """Submitting exercise before starting session should auto-create session."""
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 100, "level": 0})
        db.seed("exercises", "c00_ex00", {
            "id": "c00_ex00",
            "module": "c00",
            "phase": "phase2",
            "title": "ft_putchar",
            "difficulty": 1,
            "xp": 20,
            "estimated_minutes": 15,
        })
        # No session seeded — simulates submit before start_session

        submission = ExerciseSubmission(hash_code="abcd1234", hints_used=0)
        result = await submit_exercise(TEST_UID, "c00_ex00", submission, db)

        assert result["xp_earned"] > 0

        # Session should have been auto-created with exercise data
        today_str = date.today().isoformat()
        session_doc_id = f"{TEST_UID}_{today_str}"
        session_data = db._collections["sessions"][session_doc_id]
        assert "c00_ex00" in session_data["exercises_completed"]
        assert session_data["xp_earned"] == result["xp_earned"]
        assert session_data["uid"] == TEST_UID
        assert session_data["date"] == today_str


# --- P1-5: Drill XP Farming Prevention ---


class TestDrillAntifarming:
    """P1-5: Drills already done today should not grant XP."""

    @pytest.mark.asyncio
    async def test_drill_already_done_today_returns_zero(self):
        """Same function drilled again same day gets 0 XP."""
        today_str = date.today().isoformat()
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 100})
        db.seed("exercises", "ft_strlen", {"estimated_minutes": 15})
        db.seed("drill_pool", TEST_UID, {
            "uid": TEST_UID,
            "function_queue": ["ft_strlen", "ft_putchar"],
            "last_drilled": {"ft_strlen": today_str},
        })

        result = await process_drill(TEST_UID, "ft_strlen", 600, db)

        assert result["xp_earned"] == 0
        assert result["already_drilled"] is True
        # User XP unchanged
        assert db._collections["users"][TEST_UID]["xp"] == 100

    @pytest.mark.asyncio
    async def test_drill_different_function_today_gets_xp(self):
        """Different function on same day should still earn XP."""
        today_str = date.today().isoformat()
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 100})
        db.seed("exercises", "ft_putchar", {"estimated_minutes": 15})
        db.seed("drill_pool", TEST_UID, {
            "uid": TEST_UID,
            "function_queue": ["ft_strlen", "ft_putchar"],
            "last_drilled": {"ft_strlen": today_str},
        })

        result = await process_drill(TEST_UID, "ft_putchar", 600, db)

        assert result["xp_earned"] > 0
        assert "already_drilled" not in result

    @pytest.mark.asyncio
    async def test_drill_yesterday_function_today_gets_xp(self):
        """Function drilled yesterday can earn XP today."""
        yesterday_str = (date.today() - timedelta(days=1)).isoformat()
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 100})
        db.seed("exercises", "ft_strlen", {"estimated_minutes": 15})
        db.seed("drill_pool", TEST_UID, {
            "uid": TEST_UID,
            "function_queue": ["ft_strlen"],
            "last_drilled": {"ft_strlen": yesterday_str},
        })

        result = await process_drill(TEST_UID, "ft_strlen", 600, db)

        assert result["xp_earned"] > 0
        assert "already_drilled" not in result


# --- P1-5: Review XP Farming Prevention ---


class TestReviewAntifarming:
    """P1-5: Review cards not yet due should not grant XP."""

    @pytest.mark.asyncio
    async def test_review_not_due_returns_zero(self):
        """Card with next_review in the future returns 0 XP."""
        future = datetime.now(timezone.utc) + timedelta(days=3)
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 100})
        db.seed("review_cards", "card1", {
            "interval_days": 5,
            "review_count": 2,
            "correct_count": 2,
            "next_review": future,
        })

        result = await process_review(TEST_UID, "card1", True, db)

        assert result["xp_earned"] == 0
        assert result["already_reviewed"] is True

    @pytest.mark.asyncio
    async def test_review_due_grants_xp(self):
        """Card with next_review in the past should grant XP."""
        past = datetime.now(timezone.utc) - timedelta(hours=1)
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 100})
        db.seed("review_cards", "card1", {
            "interval_days": 3,
            "review_count": 1,
            "correct_count": 1,
            "next_review": past,
        })

        result = await process_review(TEST_UID, "card1", True, db)

        assert result["xp_earned"] == XP_BONUS_VOCAB
        assert "already_reviewed" not in result

    @pytest.mark.asyncio
    async def test_review_no_next_review_grants_xp(self):
        """Card with no next_review (new card) should grant XP."""
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {"xp": 100})
        db.seed("review_cards", "card1", {
            "interval_days": 3,
            "review_count": 0,
            "correct_count": 0,
        })

        result = await process_review(TEST_UID, "card1", True, db)

        assert result["xp_earned"] == XP_BONUS_VOCAB


# --- P3-1: Exam next_available Computation ---


class TestExamCooldownComputation:
    """P3-1: next_available should be meaningful, not 'now'."""

    @pytest.mark.asyncio
    async def test_next_available_after_max_attempts(self):
        """When 3 attempts are used, next_available = oldest_attempt + 14 days."""
        now = datetime.now(timezone.utc)
        db = MockFirestoreDB()

        # Seed 3 attempts within 14 days
        attempt_times = [
            now - timedelta(days=10),
            now - timedelta(days=5),
            now - timedelta(days=1),
        ]
        for i, t in enumerate(attempt_times):
            doc_id = f"{TEST_UID}_exam{i}"
            db.seed("exams", doc_id, {
                "uid": TEST_UID,
                "exam_type": "gate",
                "status": "passed",
                "started_at": t,
                "finished_at": t + timedelta(hours=2),
            })

        result = await check_cooldown(TEST_UID, "gate", db)

        assert result["can_start"] is False
        # next_available should be oldest_attempt + 14 days, not "now"
        expected = attempt_times[0] + timedelta(days=14)
        actual = datetime.fromisoformat(result["next_available"])
        # Compare with tolerance of 1 second
        assert abs((actual - expected).total_seconds()) < 1

    @pytest.mark.asyncio
    async def test_cooldown_after_failed_attempt(self):
        """48h cooldown after failed attempt has correct next_available."""
        now = datetime.now(timezone.utc)
        finished = now - timedelta(hours=24)  # Failed 24h ago
        db = MockFirestoreDB()
        db.seed("exams", f"{TEST_UID}_exam0", {
            "uid": TEST_UID,
            "exam_type": "gate",
            "status": "failed",
            "started_at": finished - timedelta(hours=2),
            "finished_at": finished,
        })

        result = await check_cooldown(TEST_UID, "gate", db)

        assert result["can_start"] is False
        expected_end = finished + timedelta(hours=48)
        actual = datetime.fromisoformat(result["next_available"])
        assert abs((actual - expected_end).total_seconds()) < 1

    @pytest.mark.asyncio
    async def test_no_cooldown_when_no_attempts(self):
        """No previous attempts means can_start=True."""
        db = MockFirestoreDB()
        result = await check_cooldown(TEST_UID, "gate", db)
        assert result["can_start"] is True


# --- P3-2: SPEED_DEMON Achievement ---


class TestSpeedDemonAchievement:
    """P3-2: SPEED_DEMON should be achievable when completing in <50% estimated time."""

    @pytest.mark.asyncio
    async def test_speed_demon_unlocked(self):
        """Exercise completed in <50% estimated time triggers SPEED_DEMON."""
        now = datetime.now(timezone.utc)
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {
            "level": 0,
            "xp": 100,
            "weekly_completed_days": [],
            "streak_days": 0,
            "shields": 0,
        })
        # Exercise with 30 min estimate
        db.seed("exercises", "c00_ex05", {
            "id": "c00_ex05",
            "module": "c00",
            "phase": "phase2",
            "title": "ft_atoi",
            "difficulty": 3,
            "xp": 40,
            "estimated_minutes": 30,
        })
        # Completed in 10 minutes (<50% of 30 = 15 min)
        db.seed("exercise_progress", f"{TEST_UID}_c00_ex05", {
            "uid": TEST_UID,
            "exercise_id": "c00_ex05",
            "status": "completed",
            "attempts": 1,
            "started_at": now - timedelta(minutes=10),
            "completed_at": now,
            "first_attempt_pass": True,
        })

        achievements = await check_achievements(TEST_UID, db)

        assert "speed_demon" in achievements

    @pytest.mark.asyncio
    async def test_speed_demon_not_unlocked_when_slow(self):
        """Exercise completed in >50% estimated time does NOT trigger SPEED_DEMON."""
        now = datetime.now(timezone.utc)
        db = MockFirestoreDB()
        db.seed("users", TEST_UID, {
            "level": 0,
            "xp": 100,
            "weekly_completed_days": [],
            "streak_days": 0,
            "shields": 0,
        })
        db.seed("exercises", "c00_ex05", {
            "id": "c00_ex05",
            "module": "c00",
            "phase": "phase2",
            "title": "ft_atoi",
            "difficulty": 3,
            "xp": 40,
            "estimated_minutes": 30,
        })
        # Completed in 20 minutes (>50% of 30 = 15 min)
        db.seed("exercise_progress", f"{TEST_UID}_c00_ex05", {
            "uid": TEST_UID,
            "exercise_id": "c00_ex05",
            "status": "completed",
            "attempts": 1,
            "started_at": now - timedelta(minutes=20),
            "completed_at": now,
            "first_attempt_pass": True,
        })

        achievements = await check_achievements(TEST_UID, db)

        assert "speed_demon" not in achievements
