"""Auth router — user profile management."""

from datetime import datetime

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from google.cloud.firestore_v1 import AsyncClient

from app.core.auth import get_uid
from app.core.firebase import get_db
from app.models.user import UserProfile, UserProfileUpdate

logger = structlog.get_logger()
router = APIRouter()


@router.get("/profile")
async def get_profile(
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> UserProfile:
    """Get current user profile."""
    doc = await db.collection("users").document(uid).get()
    if not doc.exists:
        # Auto-create profile for new user
        profile = UserProfile(uid=uid)
        await db.collection("users").document(uid).set(profile.model_dump())
        logger.info("Auto-created user profile", uid=uid)
        return profile

    data = doc.to_dict()
    data["uid"] = uid
    return UserProfile(**data)


@router.put("/profile")
async def update_profile(
    data: UserProfileUpdate,
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> UserProfile:
    """Update user profile (display_name, mood_today, pause_mode only)."""
    doc = await db.collection("users").document(uid).get()
    if not doc.exists:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found",
        )

    # Only update non-None fields
    update_data = data.model_dump(exclude_none=True)
    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No fields to update",
        )

    update_data["updated_at"] = datetime.utcnow()

    # Handle pause mode
    if data.pause_mode is True:
        update_data["pause_started_at"] = datetime.utcnow()
    elif data.pause_mode is False:
        update_data["pause_started_at"] = None

    await db.collection("users").document(uid).set(update_data, merge=True)

    # Return updated profile
    updated_doc = await db.collection("users").document(uid).get()
    updated_data = updated_doc.to_dict()
    updated_data["uid"] = uid
    return UserProfile(**updated_data)
