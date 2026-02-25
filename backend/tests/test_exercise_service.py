"""Tests for exercise service — hash verification, XP calculation, progress."""

import pytest
from datetime import datetime

from app.models.exercise import Exercise, ExerciseProgress, ExerciseStatus
from app.models.gamification import XP_BONUS_FIRST_ATTEMPT, XP_BONUS_NO_HINTS
from app.services.exercise_service import (
    calculate_xp,
    get_exercise_progress,
    verify_hash,
)
from tests.conftest import TEST_UID, MockFirestoreDB


# --- Hash Verification Tests ---


class TestHashVerification:
    """Hash format validation tests."""

    @pytest.mark.asyncio
    async def test_valid_hash_lowercase(self):
        assert await verify_hash("abcd1234", TEST_UID, "ex1") is True

    @pytest.mark.asyncio
    async def test_valid_hash_digits_only(self):
        assert await verify_hash("12345678", TEST_UID, "ex1") is True

    @pytest.mark.asyncio
    async def test_valid_hash_mixed(self):
        assert await verify_hash("a1b2c3d4", TEST_UID, "ex1") is True

    @pytest.mark.asyncio
    async def test_valid_hash_uppercase_normalized(self):
        # verify_hash lowercases input
        assert await verify_hash("ABCD1234", TEST_UID, "ex1") is True

    @pytest.mark.asyncio
    async def test_invalid_hash_too_short(self):
        assert await verify_hash("abcd123", TEST_UID, "ex1") is False

    @pytest.mark.asyncio
    async def test_invalid_hash_too_long(self):
        assert await verify_hash("abcd12345", TEST_UID, "ex1") is False

    @pytest.mark.asyncio
    async def test_invalid_hash_non_hex(self):
        assert await verify_hash("abcdxyz1", TEST_UID, "ex1") is False

    @pytest.mark.asyncio
    async def test_invalid_hash_empty(self):
        assert await verify_hash("", TEST_UID, "ex1") is False

    @pytest.mark.asyncio
    async def test_invalid_hash_spaces(self):
        assert await verify_hash("abcd 234", TEST_UID, "ex1") is False


# --- XP Calculation Tests ---


class TestXPCalculation:
    """XP calculation with bonus tests."""

    def _make_exercise(self, xp: int = 20) -> Exercise:
        return Exercise(
            id="test",
            module="c00",
            phase="phase2",
            title="test",
            difficulty=1,
            xp=xp,
        )

    @pytest.mark.asyncio
    async def test_base_xp_only(self):
        """No bonuses: existing progress with previous attempts and hints used."""
        ex = self._make_exercise(xp=20)
        progress = ExerciseProgress(
            uid=TEST_UID,
            exercise_id="test",
            attempts=2,
            hints_used=1,
        )
        xp, bonuses = await calculate_xp(ex, progress, hints_used=1)
        assert xp == 20
        assert bonuses == []

    @pytest.mark.asyncio
    async def test_first_attempt_bonus(self):
        """First attempt: progress is None (new exercise)."""
        ex = self._make_exercise(xp=20)
        xp, bonuses = await calculate_xp(ex, None, hints_used=1)
        assert xp == 20 + XP_BONUS_FIRST_ATTEMPT
        assert "first_attempt" in bonuses

    @pytest.mark.asyncio
    async def test_no_hints_bonus(self):
        """No hints used."""
        ex = self._make_exercise(xp=20)
        progress = ExerciseProgress(
            uid=TEST_UID,
            exercise_id="test",
            attempts=1,
        )
        xp, bonuses = await calculate_xp(ex, progress, hints_used=0)
        assert xp == 20 + XP_BONUS_NO_HINTS
        assert "no_hints" in bonuses

    @pytest.mark.asyncio
    async def test_both_bonuses(self):
        """First attempt + no hints = maximum bonus."""
        ex = self._make_exercise(xp=20)
        xp, bonuses = await calculate_xp(ex, None, hints_used=0)
        expected = 20 + XP_BONUS_FIRST_ATTEMPT + XP_BONUS_NO_HINTS
        assert xp == expected
        assert "first_attempt" in bonuses
        assert "no_hints" in bonuses

    @pytest.mark.asyncio
    async def test_first_attempt_with_zero_attempts_progress(self):
        """Progress exists but with 0 attempts (edge case)."""
        ex = self._make_exercise(xp=25)
        progress = ExerciseProgress(
            uid=TEST_UID,
            exercise_id="test",
            attempts=0,
        )
        xp, bonuses = await calculate_xp(ex, progress, hints_used=0)
        assert "first_attempt" in bonuses

    @pytest.mark.asyncio
    async def test_high_difficulty_xp(self):
        """High difficulty exercise XP."""
        ex = self._make_exercise(xp=80)
        xp, bonuses = await calculate_xp(ex, None, hints_used=0)
        assert xp == 80 + XP_BONUS_FIRST_ATTEMPT + XP_BONUS_NO_HINTS


# --- Exercise Progress Tests ---


class TestExerciseProgress:
    """Exercise progress retrieval tests."""

    @pytest.mark.asyncio
    async def test_existing_progress(self):
        db = MockFirestoreDB()
        db.seed("exercise_progress", f"{TEST_UID}_c00_ex00", {
            "uid": TEST_UID,
            "exercise_id": "c00_ex00",
            "status": "completed",
            "attempts": 1,
            "hints_used": 0,
            "xp_earned": 35,
            "hash_code": "abcd1234",
            "first_attempt_pass": True,
            "started_at": datetime(2026, 2, 26, 10, 0),
            "completed_at": datetime(2026, 2, 26, 10, 15),
            "updated_at": datetime(2026, 2, 26, 10, 15),
        })

        progress = await get_exercise_progress(TEST_UID, "c00_ex00", db)
        assert progress is not None
        assert progress.status == ExerciseStatus.COMPLETED
        assert progress.xp_earned == 35

    @pytest.mark.asyncio
    async def test_no_progress(self):
        db = MockFirestoreDB()
        progress = await get_exercise_progress(TEST_UID, "nonexistent", db)
        assert progress is None
