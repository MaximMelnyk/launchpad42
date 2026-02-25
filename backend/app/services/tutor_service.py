"""AI Tutor service — Qwen API via httpx, rate-limited, Ukrainian."""

from datetime import date, datetime

import httpx
import structlog
from google.cloud.firestore_v1 import AsyncClient

from app.core.config import settings
from app.models.tutor import TutorRequest, TutorResponse

logger = structlog.get_logger()

# Rate limit: 20 questions per day per user
DAILY_QUESTION_LIMIT = 20

# Request timeout (seconds)
REQUEST_TIMEOUT = 30.0

# System prompt for the tutor
SYSTEM_PROMPT = (
    "You are a Piscine 42 tutor. Answer in Ukrainian. "
    "Guide the student, do not give complete solutions. "
    "Focus on understanding concepts, not copying code. "
    "If the student shares code, point out the logical approach rather than "
    "fixing the code directly. Use Socratic method — ask leading questions."
)


async def _check_rate_limit(uid: str, db: AsyncClient) -> bool:
    """Check if user is within daily question limit.

    Uses Firestore document to track daily count.
    Returns True if under limit, False if exceeded.
    """
    today_str = date.today().isoformat()
    doc_id = f"{uid}_{today_str}"
    counter_ref = db.collection("tutor_usage").document(doc_id)
    counter_doc = await counter_ref.get()

    if not counter_doc.exists:
        return True

    data = counter_doc.to_dict()
    return data.get("count", 0) < DAILY_QUESTION_LIMIT


async def _increment_usage(uid: str, db: AsyncClient) -> int:
    """Increment daily usage counter. Returns new count."""
    today_str = date.today().isoformat()
    doc_id = f"{uid}_{today_str}"
    counter_ref = db.collection("tutor_usage").document(doc_id)
    counter_doc = await counter_ref.get()

    if counter_doc.exists:
        current = counter_doc.to_dict().get("count", 0)
        new_count = current + 1
    else:
        new_count = 1

    await counter_ref.set(
        {
            "uid": uid,
            "date": today_str,
            "count": new_count,
            "updated_at": datetime.utcnow(),
        },
        merge=True,
    )
    return new_count


async def ask_tutor(
    request: TutorRequest, uid: str, db: AsyncClient
) -> TutorResponse:
    """Call Qwen API via httpx.

    Rate limit: 20 questions/day per user.
    Timeout: 30s.
    Handles: timeout, quota exceeded, API errors.
    """
    # Check rate limit
    if not await _check_rate_limit(uid, db):
        return TutorResponse(
            reply=(
                "Ти вичерпав ліміт запитань на сьогодні "
                f"({DAILY_QUESTION_LIMIT} на день). "
                "Спробуй розібратися самостійно або повернись завтра!"
            ),
            tokens_used=0,
        )

    # Check API key
    if not settings.tutor_api_key:
        return TutorResponse(
            reply="Тютор тимчасово недоступний (API не налаштовано).",
            tokens_used=0,
        )

    # Build messages
    messages = [{"role": "system", "content": SYSTEM_PROMPT}]

    # Add exercise context if provided
    if request.exercise_id:
        exercise_context = f"[Student is working on exercise: {request.exercise_id}]"
        messages.append({"role": "system", "content": exercise_context})

    # Add code context if provided
    user_message = request.message
    if request.code:
        user_message += f"\n\nМій код:\n```\n{request.code}\n```"

    messages.append({"role": "user", "content": user_message})

    # Call API
    try:
        async with httpx.AsyncClient(timeout=REQUEST_TIMEOUT) as client:
            response = await client.post(
                f"{settings.tutor_api_base}/chat/completions",
                headers={
                    "Authorization": f"Bearer {settings.tutor_api_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "model": settings.tutor_model,
                    "messages": messages,
                    "max_tokens": 1000,
                    "temperature": 0.7,
                },
            )

            if response.status_code == 429:
                return TutorResponse(
                    reply="API перевантажений. Спробуй через кілька хвилин.",
                    tokens_used=0,
                )

            response.raise_for_status()
            data = response.json()

            reply = data["choices"][0]["message"]["content"]
            tokens_used = data.get("usage", {}).get("total_tokens", 0)

    except httpx.TimeoutException:
        logger.warning("Tutor API timeout", uid=uid)
        return TutorResponse(
            reply="Тютор не відповідає (таймаут). Спробуй ще раз.",
            tokens_used=0,
        )
    except httpx.HTTPStatusError as e:
        logger.error("Tutor API error", uid=uid, status=e.response.status_code)
        return TutorResponse(
            reply="Помилка тютора. Спробуй пізніше.",
            tokens_used=0,
        )
    except Exception:
        logger.exception("Unexpected tutor error", uid=uid)
        return TutorResponse(
            reply="Несподівана помилка. Спробуй пізніше.",
            tokens_used=0,
        )

    # Increment usage counter
    count = await _increment_usage(uid, db)

    remaining = DAILY_QUESTION_LIMIT - count
    if remaining <= 5:
        reply += f"\n\n(Залишилось питань на сьогодні: {remaining})"

    logger.info(
        "Tutor question answered",
        uid=uid,
        tokens=tokens_used,
        daily_count=count,
    )

    return TutorResponse(reply=reply, tokens_used=tokens_used)
