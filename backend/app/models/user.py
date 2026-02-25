"""User profile model for Firestore."""

from datetime import datetime, timezone

from pydantic import Field

from app.models import CamelModel


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


class UserProfile(CamelModel):
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
    created_at: datetime = Field(default_factory=_utcnow)
    updated_at: datetime = Field(default_factory=_utcnow)


class UserProfileUpdate(CamelModel):
    """Partial update for user profile."""

    display_name: str | None = None
    mood_today: str | None = None
    pause_mode: bool | None = None
