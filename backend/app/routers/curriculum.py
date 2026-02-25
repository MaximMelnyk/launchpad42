"""Curriculum router — exercise listing, today's plan, submissions."""

import structlog
from fastapi import APIRouter, Depends, HTTPException, status
from google.cloud.firestore_v1 import AsyncClient

from app.core.auth import get_uid
from app.core.firebase import get_db
from app.models.exercise import Exercise, ExerciseSubmission
from app.services import curriculum_service, exercise_service

logger = structlog.get_logger()
router = APIRouter()


@router.get("/today")
async def get_today(
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Returns {exercises, review_cards, drill, current_day, phase}."""
    return await curriculum_service.get_today_exercises(uid, db)


@router.get("/exercises/{exercise_id}")
async def get_exercise(
    exercise_id: str,
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Get exercise details with progress status."""
    try:
        exercise = await curriculum_service.get_exercise_detail(exercise_id, db)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=str(e),
        )

    # Fetch user progress for this exercise
    progress = await exercise_service.get_exercise_progress(uid, exercise_id, db)

    return {
        "exercise": exercise.model_dump(),
        "progress": progress.model_dump() if progress else None,
    }


@router.get("/phase/{phase}")
async def get_phase(
    phase: str,
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> list[dict]:
    """All exercises for a phase, with progress status for each."""
    valid_phases = {"phase0", "phase1", "phase2", "phase3", "phase4", "phase5"}
    if phase not in valid_phases:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid phase: {phase}. Valid: {', '.join(sorted(valid_phases))}",
        )

    exercises = await curriculum_service.get_phase_exercises(phase, db)

    result = []
    for ex in exercises:
        progress = await exercise_service.get_exercise_progress(uid, ex.id, db)
        result.append(
            {
                "exercise": ex.model_dump(),
                "progress": progress.model_dump() if progress else None,
            }
        )

    return result


@router.post("/exercises/{exercise_id}/submit")
async def submit_exercise(
    exercise_id: str,
    submission: ExerciseSubmission,
    uid: str = Depends(get_uid),
    db: AsyncClient = Depends(get_db),
) -> dict:
    """Submit exercise completion. Returns {xp_earned, bonuses, level_up, achievements_unlocked}."""
    try:
        result = await exercise_service.submit_exercise(
            uid, exercise_id, submission, db
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e),
        )

    return result
