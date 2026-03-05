"""Auth router — user profile management."""

from datetime import datetime, timezone

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from google.cloud.firestore_v1 import AsyncClient
from google.cloud.firestore_v1.base_query import FieldFilter

from app.core.auth import get_uid, require_registered_user
from app.core.firebase import get_db
from app.models.user import UserProfile, UserProfileUpdate
from app.services.curriculum_service import get_current_day, get_phase_for_day

logger = structlog.get_logger()
router = APIRouter()


@router.get("/profile")
async def get_profile(
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> UserProfile:
    """Get current user profile."""
    doc = await db.collection("users").document(uid).get()

    # Compute authoritative phase/current_day from day1_date
    computed_day = get_current_day()
    computed_phase = get_phase_for_day(computed_day)

    if not doc.exists:
        # Single-user platform: block login from a second Google account
        async for existing_doc in db.collection("users").limit(1).stream():
            logger.warning(
                "Login attempt from wrong Google account",
                attempted_uid=uid,
                existing_uid=existing_doc.id,
            )
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="wrong_account",
            )

        # First-ever login: auto-create profile with telegram_chat_id from links
        telegram_chat_id = None
        tg_query = db.collection("telegram_links").where(
            filter=FieldFilter("role", "==", "student")
        )
        async for tg_doc in tg_query.stream():
            telegram_chat_id = tg_doc.to_dict().get("chat_id")
            break

        profile = UserProfile(
            uid=uid, phase=computed_phase, current_day=computed_day,
            telegram_chat_id=telegram_chat_id,
        )
        await db.collection("users").document(uid).set(profile.model_dump())
        logger.info("Auto-created user profile", uid=uid)
        return profile

    data = doc.to_dict()
    data["uid"] = uid

    # Sync stale phase/current_day from profile with computed values
    if data.get("phase") != computed_phase or data.get("current_day") != computed_day:
        data["phase"] = computed_phase
        data["current_day"] = computed_day
        try:
            await db.collection("users").document(uid).set(
                {"phase": computed_phase, "current_day": computed_day,
                 "updated_at": datetime.now(timezone.utc)},
                merge=True,
            )
        except Exception:
            logger.warning("Failed to sync phase/current_day", uid=uid)

    return UserProfile(**data)


@router.put("/profile")
async def update_profile(
    data: UserProfileUpdate,
    uid: str = Depends(require_registered_user),
    db: AsyncClient = Depends(get_db),
) -> UserProfile:
    """Update user profile (display_name, mood_today, pause_mode only)."""
    doc = await db.collection("users").document(uid).get()
    if not doc.exists:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found",
        )

    # Only update explicitly provided fields (exclude_unset allows sending null to clear)
    update_data = data.model_dump(exclude_unset=True)

    # Strip None for non-nullable fields (pause_mode is bool, not bool|None)
    if "pause_mode" in update_data and update_data["pause_mode"] is None:
        del update_data["pause_mode"]

    if not update_data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No fields to update",
        )

    update_data["updated_at"] = datetime.now(timezone.utc)

    # Handle pause mode
    if data.pause_mode is True:
        update_data["pause_started_at"] = datetime.now(timezone.utc)
    elif data.pause_mode is False:
        update_data["pause_started_at"] = None

    await db.collection("users").document(uid).set(update_data, merge=True)

    # Return updated profile
    updated_doc = await db.collection("users").document(uid).get()
    updated_data = updated_doc.to_dict()
    updated_data["uid"] = uid
    return UserProfile(**updated_data)
