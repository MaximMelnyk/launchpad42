"""AI Tutor router — Qwen-powered study assistant."""

import structlog
from fastapi import APIRouter, Depends
from google.cloud.firestore_v1 import AsyncClient

from app.core.auth import require_registered_user
from app.core.firebase import get_db
from app.models.tutor import TutorRequest, TutorResponse
from app.services import tutor_service

logger = structlog.get_logger()
router = APIRouter()


@router.post("/ask")
async def ask_tutor_route(
    data: TutorRequest,
    uid: str = Depends(require_registered_user),
    db: AsyncClient = Depends(get_db),
) -> TutorResponse:
    """Ask the AI tutor a question. Rate limited to 20/day."""
    return await tutor_service.ask_tutor(data, uid, db)
