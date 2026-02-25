"""AI Tutor request/response models."""

from pydantic import BaseModel, Field


class TutorRequest(BaseModel):
    """Student message to AI tutor."""

    message: str = Field(max_length=2000)
    exercise_id: str | None = None
    code: str | None = Field(default=None, max_length=10000)


class TutorResponse(BaseModel):
    """AI tutor response."""

    reply: str
    tokens_used: int | None = None
