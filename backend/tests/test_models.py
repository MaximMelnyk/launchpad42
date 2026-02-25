"""Tests for Pydantic model validation boundaries."""

import pytest
from datetime import datetime

from app.models.exercise import Exercise, ExerciseProgress, ExerciseSubmission, ExerciseStatus
from app.models.session import Session, SessionStart, SessionEnd
from app.models.user import UserProfile, UserProfileUpdate
from app.models.gamification import (
    Achievement,
    AchievementId,
    DrillPool,
    Exam,
    ExamStatus,
    ExamType,
    ReviewCard,
    TelegramLink,
    TelegramRole,
    Vocab,
    LEVEL_NAMES,
    LEVEL_XP_THRESHOLDS,
    XP_TIERS,
)
from app.models.tutor import TutorRequest, TutorResponse


# --- Exercise Models ---


class TestExercise:
    """Exercise model validation."""

    def test_valid_exercise(self):
        ex = Exercise(
            id="c00_ex00",
            module="c00",
            phase="phase2",
            title="ft_putchar",
            difficulty=1,
            xp=20,
        )
        assert ex.id == "c00_ex00"
        assert ex.difficulty == 1

    def test_difficulty_min(self):
        with pytest.raises(ValueError):
            Exercise(
                id="test",
                module="c00",
                phase="phase2",
                title="test",
                difficulty=0,
                xp=20,
            )

    def test_difficulty_max(self):
        with pytest.raises(ValueError):
            Exercise(
                id="test",
                module="c00",
                phase="phase2",
                title="test",
                difficulty=6,
                xp=20,
            )

    def test_difficulty_range_valid(self):
        for d in range(1, 6):
            ex = Exercise(
                id="test",
                module="c00",
                phase="phase2",
                title="test",
                difficulty=d,
                xp=XP_TIERS[d],
            )
            assert ex.difficulty == d

    def test_xp_non_negative(self):
        with pytest.raises(ValueError):
            Exercise(
                id="test",
                module="c00",
                phase="phase2",
                title="test",
                difficulty=1,
                xp=-1,
            )

    def test_defaults(self):
        ex = Exercise(
            id="test",
            module="c00",
            phase="phase2",
            title="test",
            difficulty=1,
            xp=20,
        )
        assert ex.estimated_minutes == 15
        assert ex.prerequisites == []
        assert ex.tags == []
        assert ex.norminette is True
        assert ex.multi_day is False
        assert ex.order == 0


class TestExerciseSubmission:
    """ExerciseSubmission validation."""

    def test_valid_submission(self):
        sub = ExerciseSubmission(hash_code="abcd1234", hints_used=0)
        assert sub.hash_code == "abcd1234"
        assert sub.hints_used == 0

    def test_hints_non_negative(self):
        with pytest.raises(ValueError):
            ExerciseSubmission(hash_code="abcd1234", hints_used=-1)

    def test_defaults(self):
        sub = ExerciseSubmission(hash_code="abcd1234")
        assert sub.hints_used == 0


class TestExerciseProgress:
    """ExerciseProgress validation."""

    def test_default_status(self):
        ep = ExerciseProgress(uid="test", exercise_id="test")
        assert ep.status == ExerciseStatus.LOCKED
        assert ep.attempts == 0
        assert ep.xp_earned == 0

    def test_completed_status(self):
        ep = ExerciseProgress(
            uid="test",
            exercise_id="test",
            status=ExerciseStatus.COMPLETED,
            attempts=1,
            xp_earned=35,
        )
        assert ep.status == ExerciseStatus.COMPLETED


# --- Session Models ---


class TestSession:
    """Session model validation."""

    def test_valid_date_format(self):
        s = Session(uid="test", date="2026-03-15")
        assert s.date == "2026-03-15"

    def test_invalid_date_format_no_dashes(self):
        with pytest.raises(ValueError):
            Session(uid="test", date="20260315")

    def test_invalid_date_format_slash(self):
        with pytest.raises(ValueError):
            Session(uid="test", date="2026/03/15")

    def test_invalid_date_format_short(self):
        with pytest.raises(ValueError):
            Session(uid="test", date="26-03-15")

    def test_session_defaults(self):
        s = Session(uid="test", date="2026-03-15")
        assert s.mood_start is None
        assert s.mood_end is None
        assert s.exercises_completed == []
        assert s.xp_earned == 0
        assert s.drill_completed is False
        assert s.duration_minutes == 0

    def test_xp_non_negative(self):
        with pytest.raises(ValueError):
            Session(uid="test", date="2026-03-15", xp_earned=-1)


class TestSessionStart:
    """SessionStart validation."""

    def test_valid(self):
        ss = SessionStart(mood="3")
        assert ss.mood == "3"


class TestSessionEnd:
    """SessionEnd validation."""

    def test_valid(self):
        se = SessionEnd(mood="4", duration_minutes=120)
        assert se.duration_minutes == 120

    def test_duration_non_negative(self):
        with pytest.raises(ValueError):
            SessionEnd(mood="4", duration_minutes=-10)


# --- User Models ---


class TestUserProfile:
    """UserProfile validation."""

    def test_valid_profile(self):
        u = UserProfile(uid="test-123")
        assert u.uid == "test-123"
        assert u.level == 0
        assert u.xp == 0

    def test_level_range_min(self):
        with pytest.raises(ValueError):
            UserProfile(uid="test", level=-1)

    def test_level_range_max(self):
        with pytest.raises(ValueError):
            UserProfile(uid="test", level=7)

    def test_level_valid_range(self):
        for lv in range(7):
            u = UserProfile(uid="test", level=lv)
            assert u.level == lv

    def test_xp_non_negative(self):
        with pytest.raises(ValueError):
            UserProfile(uid="test", xp=-1)

    def test_shields_max(self):
        with pytest.raises(ValueError):
            UserProfile(uid="test", shields=4)

    def test_defaults(self):
        u = UserProfile(uid="test")
        assert u.display_name == ""
        assert u.phase == "phase0"
        assert u.current_day == 1
        assert u.streak_days == 0
        assert u.shields == 0
        assert u.weekly_completed_days == []
        assert u.pause_mode is False


class TestUserProfileUpdate:
    """UserProfileUpdate validation."""

    def test_all_none(self):
        up = UserProfileUpdate()
        assert up.display_name is None
        assert up.mood_today is None
        assert up.pause_mode is None

    def test_partial_update(self):
        up = UserProfileUpdate(display_name="New Name")
        assert up.display_name == "New Name"
        assert up.mood_today is None


# --- Gamification Models ---


class TestGamificationModels:
    """Gamification model validation."""

    def test_level_names_complete(self):
        assert len(LEVEL_NAMES) == 7
        for i in range(7):
            assert i in LEVEL_NAMES

    def test_level_thresholds_monotonic(self):
        thresholds = [LEVEL_XP_THRESHOLDS[i] for i in range(7)]
        for i in range(1, len(thresholds)):
            assert thresholds[i] > thresholds[i - 1]

    def test_xp_tiers_complete(self):
        assert len(XP_TIERS) == 5
        for d in range(1, 6):
            assert d in XP_TIERS

    def test_achievement_model(self):
        a = Achievement(uid="test", achievement_id=AchievementId.FIRST_BLOOD)
        assert a.unlocked is False
        assert a.progress == 0
        assert a.target == 1

    def test_drill_pool_defaults(self):
        dp = DrillPool(uid="test")
        assert dp.function_queue == []
        assert dp.last_drilled == {}

    def test_review_card_defaults(self):
        rc = ReviewCard(
            id="card1",
            category="concept",
            front="What is write()?",
            back="System call for writing.",
            phase="phase0",
        )
        assert rc.interval_days == 3
        assert rc.review_count == 0

    def test_exam_model(self):
        e = Exam(uid="test", exam_id="exam1", exam_type=ExamType.GATE)
        assert e.status == ExamStatus.IN_PROGRESS
        assert e.time_limit_minutes == 240
        assert e.score == 0.0

    def test_exam_final_time(self):
        e = Exam(
            uid="test",
            exam_id="exam2",
            exam_type=ExamType.FINAL,
            time_limit_minutes=480,
        )
        assert e.time_limit_minutes == 480

    def test_telegram_link(self):
        tl = TelegramLink(chat_id=12345, role=TelegramRole.STUDENT)
        assert tl.chat_id == 12345
        assert tl.role == TelegramRole.STUDENT


# --- Tutor Models ---


class TestTutorModels:
    """Tutor model validation."""

    def test_tutor_request_valid(self):
        tr = TutorRequest(message="How does write() work?")
        assert tr.exercise_id is None
        assert tr.code is None

    def test_tutor_request_with_context(self):
        tr = TutorRequest(
            message="Help me",
            exercise_id="c00_ex00",
            code="void ft_putchar(char c) {}",
        )
        assert tr.exercise_id == "c00_ex00"

    def test_tutor_request_max_length(self):
        with pytest.raises(ValueError):
            TutorRequest(message="x" * 2001)

    def test_tutor_response(self):
        resp = TutorResponse(reply="Hello!", tokens_used=42)
        assert resp.reply == "Hello!"
        assert resp.tokens_used == 42
