"""AI Tutor service — Qwen API via httpx, rate-limited, Ukrainian.

Features:
- Conversation history (last 10 exchanges per user, stored in Firestore)
- Student profile context (level, phase, streak, completed exercises)
- Exercise context (title, description from exercises collection)
- Rate limit: 20 questions/day per user
"""

from datetime import date, datetime, timezone

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

# Conversation history limit (user+assistant pairs)
HISTORY_LIMIT = 10

# System prompt for the tutor
SYSTEM_PROMPT = (
    "You are a Piscine 42 tutor. Answer in Ukrainian. "
    "Guide the student, do not give complete solutions. "
    "Focus on understanding concepts, not copying code. "
    "If the student shares code, point out the logical approach rather than "
    "fixing the code directly. Use Socratic method — ask leading questions. "
    "You have access to the student's profile and conversation history."
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
            "updated_at": datetime.now(timezone.utc),
        },
        merge=True,
    )
    return new_count


async def _get_student_profile(uid: str, db: AsyncClient) -> str:
    """Build student profile context string from Firestore user doc."""
    user_doc = await db.collection("users").document(uid).get()
    if not user_doc.exists:
        return ""

    u = user_doc.to_dict()
    level = u.get("level", 0)
    phase = u.get("phase", "phase0")
    xp = u.get("xp", 0)
    streak = u.get("streak_days", 0)
    shields = u.get("shields", 0)

    # Count completed exercises
    completed = 0
    progress_query = db.collection("exercise_progress").where(
        "uid", "==", uid
    ).where("status", "==", "completed")
    async for _ in progress_query.stream():
        completed += 1

    from app.models.gamification import LEVEL_NAMES
    level_name = LEVEL_NAMES.get(level, "Unknown")

    return (
        f"[Student profile: level {level} ({level_name}), phase {phase}, "
        f"XP {xp}, streak {streak} days, shields {shields}, "
        f"completed exercises: {completed}]"
    )


async def _get_exercise_context(exercise_id: str, db: AsyncClient) -> str:
    """Load exercise details from Firestore for tutor context."""
    doc = await db.collection("exercises").document(exercise_id).get()
    if not doc.exists:
        return f"[Student is working on exercise: {exercise_id}]"

    ex = doc.to_dict()
    title = ex.get("title", exercise_id)
    module = ex.get("module", "")
    difficulty = ex.get("difficulty", "?")
    content_md = ex.get("content_md", "")

    # Truncate content to avoid token overflow (first 500 chars)
    if len(content_md) > 500:
        content_md = content_md[:500] + "..."

    parts = [f"[Exercise: {title} (module: {module}, difficulty: {difficulty})"]
    if content_md:
        parts.append(f"Description:\n{content_md}")
    parts.append("]")

    return "\n".join(parts)


async def _load_history(uid: str, db: AsyncClient) -> list[dict[str, str]]:
    """Load last N conversation exchanges from Firestore.

    Returns list of {role, content} dicts ready for API messages[].
    """
    doc_ref = db.collection("tutor_history").document(uid)
    doc = await doc_ref.get()
    if not doc.exists:
        return []

    data = doc.to_dict()
    return data.get("messages", [])


async def _save_history(
    uid: str,
    history: list[dict[str, str]],
    user_msg: str,
    assistant_msg: str,
    db: AsyncClient,
) -> None:
    """Append user+assistant exchange to history, trim to HISTORY_LIMIT pairs."""
    history.append({"role": "user", "content": user_msg})
    history.append({"role": "assistant", "content": assistant_msg})

    # Keep last HISTORY_LIMIT pairs (2 messages per pair)
    max_messages = HISTORY_LIMIT * 2
    if len(history) > max_messages:
        history = history[-max_messages:]

    doc_ref = db.collection("tutor_history").document(uid)
    await doc_ref.set(
        {
            "uid": uid,
            "messages": history,
            "updated_at": datetime.now(timezone.utc),
        },
    )


async def ask_tutor(
    request: TutorRequest, uid: str, db: AsyncClient
) -> TutorResponse:
    """Call Qwen API via httpx with full context.

    Context includes: student profile, exercise details, conversation history.
    Rate limit: 20 questions/day per user.
    Timeout: 30s.
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

    # Build messages with full context
    messages: list[dict[str, str]] = [{"role": "system", "content": SYSTEM_PROMPT}]

    # Add student profile context
    profile_ctx = await _get_student_profile(uid, db)
    if profile_ctx:
        messages.append({"role": "system", "content": profile_ctx})

    # Add exercise context if provided
    if request.exercise_id:
        exercise_ctx = await _get_exercise_context(request.exercise_id, db)
        messages.append({"role": "system", "content": exercise_ctx})

    # Add conversation history
    history = await _load_history(uid, db)
    messages.extend(history)

    # Add current user message
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

    # Save conversation history
    await _save_history(uid, history, user_message, reply, db)

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
