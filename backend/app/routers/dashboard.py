"""Dashboard router — aggregated view for the student."""

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from google.cloud.firestore_v1 import AsyncClient

from app.core.auth import get_uid
from app.core.firebase import get_db
from app.core.utils import camel_dict
from app.models.user import UserProfile
from app.services import (
    curriculum_service,
    gamification_service,
    session_service,
)

logger = structlog.get_logger()
router = APIRouter()


@router.get("")
async def get_dashboard(
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Aggregated dashboard data: user + session + exercises + achievements + gamification."""
    # User profile
    user_doc = await db.collection("users").document(uid).get()
    if not user_doc.exists:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found",
        )
    user_data = user_doc.to_dict()
    user_data["uid"] = uid
    user = UserProfile(**user_data)

    # Current session
    session = await session_service.get_current_session(uid, db)

    # Today's exercises
    today_data = await curriculum_service.get_today_exercises(uid, db)

    # Gamification profile
    try:
        gamification = await gamification_service.get_gamification_profile(uid, db)
    except ValueError:
        gamification = None

    # Achievements
    achievements = await gamification_service.get_achievements(uid, db)

    # Current training day
    current_day = session_service.get_current_day()

    return camel_dict({
        "user": user.model_dump(by_alias=True),
        "session": session.model_dump(by_alias=True) if session else None,
        "today": today_data,
        "gamification": gamification,
        "achievements": achievements,
        "current_day": current_day,
    })
