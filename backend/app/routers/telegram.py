"""Telegram webhook router — receives updates from Telegram Bot API."""

import hashlib

import structlog
from fastapi import APIRouter, HTTPException, Header, Request, status

from app.core.config import settings
from app.core.firebase import get_db

logger = structlog.get_logger()
router = APIRouter()


def _get_webhook_secret_token() -> str:
    """Derive webhook secret token from bot token hash (first 32 chars)."""
    if not settings.telegram_bot_token:
        return ""
    return hashlib.sha256(settings.telegram_bot_token.encode()).hexdigest()[:32]


def _get_scheduler_secret() -> str:
    """Derive scheduler secret from bot token hash (last 32 chars)."""
    if not settings.telegram_bot_token:
        return ""
    return hashlib.sha256(
        f"scheduler:{settings.telegram_bot_token}".encode()
    ).hexdigest()[:32]


def _verify_scheduler_secret(header_value: str | None) -> None:
    """Verify X-Scheduler-Secret header matches derived secret."""
    if not settings.telegram_bot_token:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Bot not configured",
        )
    expected = _get_scheduler_secret()
    if header_value != expected:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid scheduler secret",
        )


@router.post("/webhook")
async def telegram_webhook(
    request: Request,
    x_telegram_bot_api_secret_token: str | None = Header(default=None),
) -> dict:
    """Parse webhook update and process via telegram_service."""
    db = get_db()

    # Check if bot is configured
    if not settings.telegram_bot_token:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Telegram bot not configured",
        )

    # Verify webhook secret token (P1-1)
    expected_secret = _get_webhook_secret_token()
    if expected_secret and x_telegram_bot_api_secret_token != expected_secret:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid webhook secret token",
        )

    # Get bot app from FastAPI state
    bot_app = getattr(request.app.state, "bot", None)
    if bot_app is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Telegram bot not initialized",
        )

    try:
        update_data = await request.json()
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid JSON payload",
        )

    try:
        from app.services.telegram_service import handle_webhook

        await handle_webhook(update_data, db, bot_app)
    except Exception:
        logger.exception("Error processing Telegram webhook")
        # Return 200 to prevent Telegram from retrying
        # (failed updates are logged, not retried)

    return {"ok": True}


@router.post("/weekly-report")
async def trigger_weekly_report(
    request: Request,
    x_scheduler_secret: str | None = Header(default=None),
) -> dict:
    """Trigger weekly report (called by Cloud Scheduler).

    Requires X-Scheduler-Secret header matching telegram_bot_token.
    """
    _verify_scheduler_secret(x_scheduler_secret)
    db = get_db()

    try:
        from app.services.telegram_service import send_weekly_report

        await send_weekly_report(db)
        return {"status": "sent"}
    except Exception:
        logger.exception("Error sending weekly report")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to send weekly report",
        )


@router.post("/student-preview")
async def trigger_student_preview(
    request: Request,
    x_scheduler_secret: str | None = Header(default=None),
) -> dict:
    """Trigger student preview (called by Cloud Scheduler).

    Requires X-Scheduler-Secret header matching telegram_bot_token.
    """
    _verify_scheduler_secret(x_scheduler_secret)
    db = get_db()

    try:
        from app.services.telegram_service import send_student_preview

        await send_student_preview(db)
        return {"status": "sent"}
    except Exception:
        logger.exception("Error sending student preview")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to send student preview",
        )
