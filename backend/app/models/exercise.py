"""Exercise and progress models for Firestore."""

from datetime import datetime
from enum import Enum

from pydantic import Field

from app.models import CamelModel, utcnow


class ExerciseStatus(str, Enum):
    LOCKED = "locked"
    AVAILABLE = "available"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    SKIPPED = "skipped"


class Exercise(CamelModel):
    """Exercise definition seeded from content/. Firestore: exercises/{exercise_id}"""

    id: str
    module: str
    phase: str
    title: str
    difficulty: int = Field(ge=1, le=5)
    xp: int = Field(ge=0)
    estimated_minutes: int = 15
    prerequisites: list[str] = Field(default_factory=list)
    tags: list[str] = Field(default_factory=list)
    norminette: bool = True
    man_pages: list[str] = Field(default_factory=list)
    multi_day: bool = False
    content_md: str = ""
    order: int = 0


class ExerciseProgress(CamelModel):
    """Per-user exercise progress. Firestore: exercise_progress/{uid}_{exercise_id}"""

    uid: str
    exercise_id: str
    status: ExerciseStatus = ExerciseStatus.LOCKED
    attempts: int = 0
    hints_used: int = Field(default=0, ge=0)
    xp_earned: int = 0
    hash_code: str | None = None
    first_attempt_pass: bool = False
    started_at: datetime | None = None
    completed_at: datetime | None = None
    updated_at: datetime = Field(default_factory=utcnow)


class ExerciseSubmission(CamelModel):
    """Exercise completion submission from student."""

    hash_code: str
    hints_used: int = Field(default=0, ge=0)
