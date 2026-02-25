"""Exam router — gate exams and final simulations."""

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from google.cloud.firestore_v1 import AsyncClient
from pydantic import BaseModel, Field

from app.core.auth import get_uid
from app.core.firebase import get_db
from app.services import exam_service

logger = structlog.get_logger()
router = APIRouter()


class ExamStartRequest(BaseModel):
    """Request to start an exam."""

    exam_type: str  # "gate" or "final"
    level: int = Field(ge=0, le=6)


class ExamSubmitRequest(BaseModel):
    """Submit an exercise answer during exam."""

    exercise_id: str
    hash_code: str


@router.post("/start")
async def start_exam_route(
    data: ExamStartRequest,
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Start a new exam. Checks cooldown and attempt limits first."""
    try:
        exam = await exam_service.start_exam(uid, data.exam_type, data.level, db)
        return exam.model_dump()
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


@router.post("/{exam_id}/submit")
async def submit_exam(
    exam_id: str,
    data: ExamSubmitRequest,
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Submit an exercise answer during exam."""
    try:
        return await exam_service.submit_exam_exercise(
            uid, exam_id, data.exercise_id, data.hash_code, db
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )


@router.get("/{exam_id}")
async def get_exam(
    exam_id: str,
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Get exam status with time remaining."""
    try:
        return await exam_service.get_exam_status(uid, exam_id, db)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )


@router.get("/{exam_id}/cooldown")
async def check_cooldown(
    exam_id: str,
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Check cooldown status for an exam type."""
    # exam_id here is used as exam_type for cooldown check
    return await exam_service.check_cooldown(uid, exam_id, db)
