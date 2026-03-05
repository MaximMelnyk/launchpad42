"""Session router — daily session lifecycle."""

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from google.cloud.firestore_v1 import AsyncClient

from app.core.auth import require_registered_user
from app.core.firebase import get_db
from app.models.session import Session, SessionEnd, SessionStart
from app.services import session_service

logger = structlog.get_logger()
router = APIRouter()


@router.post("/start")
async def start(
    data: SessionStart,
    uid: str = Depends(require_registered_user),
    db: AsyncClient = Depends(get_db),
) -> Session:
    """Start a new daily session with mood check-in."""
    return await session_service.start_session(uid, data.mood, db)


@router.post("/end")
async def end(
    data: SessionEnd,
    uid: str = Depends(require_registered_user),
    db: AsyncClient = Depends(get_db),
) -> Session:
    """End today's session."""
    try:
        return await session_service.end_session(
            uid, data.mood, data.duration_minutes, db
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


@router.get("/current")
async def current(
    uid: str = Depends(require_registered_user),
    db: AsyncClient = Depends(get_db),
) -> Session | None:
    """Returns current session or null."""
    session = await session_service.get_current_session(uid, db)
    return session
