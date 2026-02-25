"""Gamification router — XP, levels, streaks, drills, reviews, achievements."""

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from google.cloud.firestore_v1 import AsyncClient
from pydantic import BaseModel, Field

from app.core.auth import get_uid
from app.core.firebase import get_db
from app.services import gamification_service

logger = structlog.get_logger()
router = APIRouter()


class DrillVerifyRequest(BaseModel):
    """Drill verification request."""

    function_name: str
    time_seconds: int = Field(ge=0)


class ReviewSubmitRequest(BaseModel):
    """Review card submission."""

    card_id: str
    correct: bool


@router.get("/profile")
async def gamification_profile(
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Get gamification profile: level, XP, streak, shields, phase."""
    try:
        return await gamification_service.get_gamification_profile(uid, db)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.get("/achievements")
async def achievements(
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> list[dict]:
    """Get all achievements with unlock status."""
    return await gamification_service.get_achievements(uid, db)


@router.post("/drill/verify")
async def verify_drill(
    data: DrillVerifyRequest,
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Verify drill attempt. Returns {correct, xp_earned}."""
    return await gamification_service.process_drill(
        uid, data.function_name, data.time_seconds, db
    )


@router.post("/review")
async def submit_review(
    data: ReviewSubmitRequest,
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Submit review card answer. Returns {next_review, interval_days, xp_earned}."""
    try:
        return await gamification_service.process_review(
            uid, data.card_id, data.correct, db
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.post("/streak")
async def update_streak_route(
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Update and return streak info."""
    return await gamification_service.update_streak(uid, db)
