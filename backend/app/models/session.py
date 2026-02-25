"""Daily session model for Firestore."""

import re
from datetime import datetime

from pydantic import Field, field_validator

from app.models import CamelModel, utcnow


class Session(CamelModel):
    """Daily training session. Firestore: sessions/{uid}_{date}"""

    uid: str
    date: str  # YYYY-MM-DD
    mood_start: str | None = None
    mood_end: str | None = None
    exercises_completed: list[str] = Field(default_factory=list)
    xp_earned: int = Field(default=0, ge=0)
    drill_completed: bool = False
    review_completed: bool = False
    vocab_completed: bool = False
    duration_minutes: int = Field(default=0, ge=0)
    started_at: datetime | None = None
    finished_at: datetime | None = None
    created_at: datetime = Field(default_factory=utcnow)

    @field_validator("date")
    @classmethod
    def validate_date_format(cls, v: str) -> str:
        if not re.match(r"^\d{4}-\d{2}-\d{2}$", v):
            raise ValueError("date must be YYYY-MM-DD format")
        return v


class SessionStart(CamelModel):
    """Request to start a new session."""

    mood: str


class SessionEnd(CamelModel):
    """Request to end current session."""

    mood: str
    duration_minutes: int = Field(default=0, ge=0)
