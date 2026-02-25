"""Gamification models: levels, achievements, XP, streaks, SRS, exams."""

from datetime import datetime, timezone
from enum import Enum

from pydantic import Field

from app.models import CamelModel


# --- Level System ---

LEVEL_NAMES: dict[int, str] = {
    0: "Init",
    1: "Shell",
    2: "Core",
    3: "Memory",
    4: "Exam",
    5: "Launch",
    6: "Ready",
}

LEVEL_XP_THRESHOLDS: dict[int, int] = {
    0: 0,
    1: 200,
    2: 600,
    3: 1400,
    4: 2600,
    5: 4000,
    6: 5500,
}

# XP per difficulty tier
XP_TIERS: dict[int, int] = {
    1: 15,
    2: 25,
    3: 40,
    4: 60,
    5: 80,
}

# Bonus XP types
XP_BONUS_STREAK = 5        # per day in active streak
XP_BONUS_FIRST_ATTEMPT = 10
XP_BONUS_NO_HINTS = 5
XP_BONUS_DRILL = 10
XP_BONUS_VOCAB = 5
XP_BONUS_EXAM_PASS = 50
XP_BONUS_ACHIEVEMENT = 25
XP_BONUS_LIGHT_DAY = 10    # completing light day exercises


# --- Achievements ---

class AchievementId(str, Enum):
    FIRST_BLOOD = "first_blood"          # Complete first exercise
    WEEK_WARRIOR = "week_warrior"        # 5/7 days in a week
    STREAK_MASTER = "streak_master"      # 14-day streak
    NORMINETTE_CLEAN = "norminette_clean" # 10 exercises with 0 norm errors
    EXAM_SURVIVOR = "exam_survivor"      # Pass first gate exam
    MEMORY_MASTER = "memory_master"      # Complete all C06-C08
    SPEED_DEMON = "speed_demon"          # Complete exercise in <50% estimated time
    LAUNCH_READY = "launch_ready"        # Reach level 6


ACHIEVEMENT_NAMES_UK: dict[str, str] = {
    "first_blood": "Перший крок",
    "week_warrior": "Тижневий воїн",
    "streak_master": "Майстер серій",
    "norminette_clean": "Чистий код",
    "exam_survivor": "Вижив на екзамені",
    "memory_master": "Володар пам'яті",
    "speed_demon": "Блискавка",
    "launch_ready": "Готовий до старту",
}


class Achievement(CamelModel):
    """Achievement state. Firestore: achievements/{uid}_{achievement_id}"""

    uid: str
    achievement_id: AchievementId
    unlocked: bool = False
    unlocked_at: datetime | None = None
    progress: int = 0  # For progressive achievements
    target: int = 1


# --- Drill & Review ---

def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


class DrillPool(CamelModel):
    """Drill rotation pool. Firestore: drill_pool/{uid}"""

    uid: str
    function_queue: list[str] = Field(default_factory=list)  # exercise IDs to drill
    last_drilled: dict[str, str] = Field(default_factory=dict)  # exercise_id -> date
    updated_at: datetime = Field(default_factory=_utcnow)


class ReviewCard(CamelModel):
    """SRS flashcard (SM-2 lite). Firestore: review_cards/{card_id}"""

    id: str
    category: str  # "concept", "function", "syscall"
    front: str
    back: str
    phase: str
    interval_days: int = 3  # SM-2 lite: 3, 5, 8, 14, 30
    ease_factor: float = 2.5
    next_review: datetime | None = None
    review_count: int = 0
    correct_count: int = 0


class Vocab(CamelModel):
    """French tech vocabulary. Firestore: vocab/{term_id}"""

    id: str
    term_fr: str
    term_uk: str
    term_en: str
    context: str = ""
    phase: str = "phase0"
    interval_days: int = 3
    next_review: datetime | None = None
    review_count: int = 0
    correct_count: int = 0


# --- Exams ---

class ExamType(str, Enum):
    GATE = "gate"      # Per-level gate exam, 4h
    FINAL = "final"    # Full exam simulation, 8h


class ExamStatus(str, Enum):
    IN_PROGRESS = "in_progress"
    PASSED = "passed"
    FAILED = "failed"
    PARTIAL = "partial"  # 60-79% score


class Exam(CamelModel):
    """Exam attempt. Firestore: exams/{uid}_{exam_id}"""

    uid: str
    exam_id: str
    exam_type: ExamType
    level: int = 0
    exercises: list[str] = Field(default_factory=list)
    completed_exercises: list[str] = Field(default_factory=list)
    score: float = 0.0
    status: ExamStatus = ExamStatus.IN_PROGRESS
    time_limit_minutes: int = 240  # 4h for gate, 480 for final
    started_at: datetime | None = None
    finished_at: datetime | None = None
    attempt_number: int = 1


# --- Telegram ---

class TelegramRole(str, Enum):
    STUDENT = "student"
    MOTHER = "mother"


class TelegramLink(CamelModel):
    """Telegram chat link. Firestore: telegram_links/{chat_id}"""

    chat_id: int
    role: TelegramRole
    display_name: str = ""
    linked_at: datetime = Field(default_factory=_utcnow)
