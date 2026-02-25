"""User profile model for Firestore."""

from datetime import datetime
from pydantic import BaseModel, Field


class UserProfile(BaseModel):
    """Single user profile. Firestore: users/{uid}"""

    uid: str
    display_name: str = ""
    email: str = ""
    level: int = Field(default=0, ge=0, le=6)
    xp: int = Field(default=0, ge=0)
    phase: str = "phase0"
    current_day: int = Field(default=1, ge=1)
    streak_days: int = Field(default=0, ge=0)
    shields: int = Field(default=0, ge=0, le=3)
    weekly_completed_days: list[str] = Field(default_factory=list)
    pause_mode: bool = False
    pause_started_at: datetime | None = None
    telegram_chat_id: int | None = None
    mood_today: str | None = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


class UserProfileUpdate(BaseModel):
    """Partial update for user profile."""

    display_name: str | None = None
    mood_today: str | None = None
    pause_mode: bool | None = None
