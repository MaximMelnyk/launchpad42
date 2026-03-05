"""Gamification router — XP, levels, streaks, drills, reviews, achievements."""

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from google.cloud.firestore_v1 import AsyncClient
from pydantic import Field

from app.core.auth import require_registered_user
from app.core.firebase import get_db
from app.core.utils import camel_dict
from app.models import CamelModel
from app.services import gamification_service

logger = structlog.get_logger()
router = APIRouter()


class DrillVerifyRequest(CamelModel):
    """Drill verification request."""

    function_name: str
    time_seconds: int = Field(ge=0)


class ReviewSubmitRequest(CamelModel):
    """Review card submission."""

    card_id: str
    correct: bool


@router.get("/profile")
async def gamification_profile(
    uid: str = Depends(require_registered_user),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Get gamification profile: level, XP, streak, shields, phase."""
    try:
        result = await gamification_service.get_gamification_profile(uid, db)
        return camel_dict(result)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.get("/achievements")
async def achievements(
    uid: str = Depends(require_registered_user),
    db: AsyncClient = Depends(get_db),
) -> list[dict]:
    """Get all achievements with unlock status."""
    result = await gamification_service.get_achievements(uid, db)
    return [camel_dict(a) for a in result]


@router.post("/drill/verify")
async def verify_drill(
    data: DrillVerifyRequest,
    uid: str = Depends(require_registered_user),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Verify drill attempt.

    Returns {correct, xpEarned}.
    If already drilled today: {correct: true, xpEarned: 0, alreadyDrilled: true}.
    If function not in queue: {correct: false, xpEarned: 0, error: "..."}.
    """
    result = await gamification_service.process_drill(
        uid, data.function_name, data.time_seconds, db
    )
    return camel_dict(result)


@router.post("/review")
async def submit_review(
    data: ReviewSubmitRequest,
    uid: str = Depends(require_registered_user),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Submit review card answer.

    Returns {nextReview, intervalDays, xpEarned}.
    If already reviewed today: {alreadyReviewed: true, intervalDays, xpEarned: 0}.
    """
    try:
        result = await gamification_service.process_review(
            uid, data.card_id, data.correct, db
        )
        return camel_dict(result)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.post("/streak")
async def update_streak_route(
    uid: str = Depends(require_registered_user),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Update and return streak info."""
    result = await gamification_service.update_streak(uid, db)
    return camel_dict(result)
