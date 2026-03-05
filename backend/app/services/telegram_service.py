"""Telegram bot service — student/mother commands, webhook handling, weekly reports."""

from datetime import date, datetime, timedelta, timezone

import structlog
from google.cloud.firestore_v1 import AsyncClient
from google.cloud.firestore_v1.base_query import FieldFilter
from telegram import InlineKeyboardButton, InlineKeyboardMarkup, Update
from telegram.ext import (
    Application,
    CallbackQueryHandler,
    CommandHandler,
    ContextTypes,
)

from app.core.config import settings
from app.core.utils import is_date_in_range
from app.models.gamification import (
    LEVEL_NAMES,
    LEVEL_XP_THRESHOLDS,
    TelegramLink,
    TelegramRole,
)

logger = structlog.get_logger()

# Brute-force protection: max failed attempts before cooldown
MAX_START_ATTEMPTS = 5
START_COOLDOWN_MINUTES = 60

# Role constants
STUDENT_COMMANDS = {"/start", "/today", "/progress", "/drill", "/hint", "/skip", "/mood"}
MOTHER_COMMANDS = {"/start", "/today", "/week", "/streak", "/level"}

# Mood emoji mapping
MOOD_OPTIONS = {
    "great": "1",
    "good": "2",
    "neutral": "3",
    "tired": "4",
    "struggling": "5",
}

MOOD_LABELS: dict[str, str] = {
    "1": "Чудово",
    "2": "Добре",
    "3": "Нейтрально",
    "4": "Втомлений",
    "5": "Важко",
}


async def _get_db_from_context(context: ContextTypes.DEFAULT_TYPE) -> AsyncClient:
    """Get Firestore client from bot context."""
    return context.bot_data.get("db")


async def _get_role(chat_id: int, db: AsyncClient) -> TelegramRole | None:
    """Determine user role from telegram_links collection."""
    doc = await db.collection("telegram_links").document(str(chat_id)).get()
    if not doc.exists:
        return None
    data = doc.to_dict()
    try:
        return TelegramRole(data.get("role"))
    except ValueError:
        return None


async def _is_linked(chat_id: int, db: AsyncClient) -> bool:
    """Check if chat_id is linked in telegram_links collection."""
    doc = await db.collection("telegram_links").document(str(chat_id)).get()
    return doc.exists


async def _require_linked(update: Update, db: AsyncClient) -> bool:
    """Verify chat is linked. If not, reply with instructions and return False."""
    chat_id = update.effective_chat.id
    if not await _is_linked(chat_id, db):
        msg = update.effective_message
        if msg:
            await msg.reply_text("Спочатку зв'яжіть акаунт через /start")
        return False
    return True


async def _require_role(
    update: Update, db: AsyncClient, required_role: TelegramRole
) -> bool:
    """Check if chat has the required role. Returns True if OK, else replies and returns False."""
    chat_id = update.effective_chat.id
    role = await _get_role(chat_id, db)
    if role != required_role:
        msg = update.effective_message
        if msg:
            await msg.reply_text("Ця команда недоступна для вашої ролі.")
        return False
    return True


async def _record_failed_attempt(chat_id: int, db: AsyncClient) -> None:
    """Record a failed /start access code attempt for brute-force protection."""
    from google.cloud.firestore_v1 import Increment

    doc_ref = db.collection("telegram_rate_limit").document(str(chat_id))
    doc = await doc_ref.get()

    if doc.exists:
        await doc_ref.update({
            "failed_attempts": Increment(1),
            "last_attempt": datetime.now(timezone.utc),
        })
    else:
        await doc_ref.set({
            "chat_id": chat_id,
            "failed_attempts": 1,
            "last_attempt": datetime.now(timezone.utc),
        })


async def _get_student_uid(db: AsyncClient) -> str | None:
    """Get the single student's UID (1-user platform).

    Lookup chain: telegram_links(student) -> chat_id -> users(telegram_chat_id).
    Fallback: oldest user by created_at (deterministic for 1-user platform).
    """
    query = db.collection("telegram_links").where(
        filter=FieldFilter("role", "==", TelegramRole.STUDENT.value)
    )
    async for doc in query.stream():
        data = doc.to_dict()
        chat_id = data.get("chat_id")
        users_query = db.collection("users").where(
            filter=FieldFilter("telegram_chat_id", "==", chat_id)
        )
        async for user_doc in users_query.stream():
            return user_doc.id
    # Fallback: oldest user (deterministic, avoids non-deterministic limit(1))
    fallback_query = db.collection("users").order_by("created_at").limit(1)
    async for user_doc in fallback_query.stream():
        return user_doc.id
    return None


# --- Student Handlers ---


async def cmd_start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Welcome message, link telegram_chat_id to user.

    Mother must provide access code: /start mother CODE
    """
    db = await _get_db_from_context(context)
    if db is None:
        await update.message.reply_text("Bot is initializing, try again later.")
        return

    chat_id = update.effective_chat.id
    user_name = update.effective_user.first_name or "User"

    # Check if already linked
    doc = await db.collection("telegram_links").document(str(chat_id)).get()
    if doc.exists:
        role = doc.to_dict().get("role", "student")
        if role == TelegramRole.MOTHER.value:
            await update.message.reply_text(
                f"Привіт! Ви підключені як спостерігач.\n"
                f"Доступні команди: /today, /week, /streak, /level"
            )
        else:
            await update.message.reply_text(
                f"Привіт, {user_name}! Ти вже підключений до LaunchPad 42.\n"
                f"Доступні команди: /today, /progress, /drill, /mood"
            )
        return

    # Parse command arguments: /start student CODE or /start mother CODE
    args = context.args or []
    if len(args) < 2 or args[0].lower() not in ("student", "mother"):
        await update.message.reply_text(
            "Введіть /start student КОД або /start mother КОД"
        )
        return

    requested_role = args[0].lower()
    provided_code = args[1]

    # Brute-force protection: check failed attempt count
    rate_doc = await db.collection("telegram_rate_limit").document(str(chat_id)).get()
    if rate_doc.exists:
        rate_data = rate_doc.to_dict()
        attempts = rate_data.get("failed_attempts", 0)
        last_attempt = rate_data.get("last_attempt")
        if attempts >= MAX_START_ATTEMPTS and last_attempt:
            if isinstance(last_attempt, str):
                last_attempt = datetime.fromisoformat(last_attempt)
            if last_attempt.tzinfo is None:
                last_attempt = last_attempt.replace(tzinfo=timezone.utc)
            cooldown_end = last_attempt + timedelta(minutes=START_COOLDOWN_MINUTES)
            if datetime.now(timezone.utc) < cooldown_end:
                await update.message.reply_text(
                    "Забагато невдалих спроб. Спробуйте через годину."
                )
                return
            # Cooldown expired, reset counter
            await db.collection("telegram_rate_limit").document(str(chat_id)).delete()

    if requested_role == "mother":
        if not settings.mother_access_code:
            await update.message.reply_text(
                "Код доступу для спостерігача не налаштовано. "
                "Зверніться до адміністратора."
            )
            return
        if provided_code != settings.mother_access_code:
            await _record_failed_attempt(chat_id, db)
            await update.message.reply_text("Невірний код доступу.")
            return

        # Valid mother access code — link as mother
        link = TelegramLink(
            chat_id=chat_id,
            role=TelegramRole.MOTHER,
            display_name=update.effective_user.first_name or "",
        )
        await db.collection("telegram_links").document(str(chat_id)).set(
            link.model_dump()
        )
        await update.message.reply_text(
            "Ви підключені як спостерігач. Використовуйте /week для тижневого звіту."
        )
        return

    # requested_role == "student"
    if not settings.student_access_code:
        await update.message.reply_text(
            "Код доступу для студента не налаштовано. "
            "Зверніться до адміністратора."
        )
        return
    if provided_code != settings.student_access_code:
        await _record_failed_attempt(chat_id, db)
        await update.message.reply_text("Невірний код доступу.")
        return

    # Valid student access code — link as student
    uid = await _get_student_uid(db)
    if uid:
        await db.collection("users").document(uid).set(
            {"telegram_chat_id": chat_id, "updated_at": datetime.now(timezone.utc)},
            merge=True,
        )

    link = TelegramLink(
        chat_id=chat_id,
        role=TelegramRole.STUDENT,
        display_name=update.effective_user.first_name or "",
    )
    await db.collection("telegram_links").document(str(chat_id)).set(
        link.model_dump()
    )

    await update.message.reply_text(
        f"Привіт, {user_name}! Ти підключений як студент.\n"
        f"Доступні команди: /today, /progress, /drill, /mood"
    )


async def cmd_today(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Today's exercises summary (student) or yes/no (mother)."""
    db = await _get_db_from_context(context)
    if db is None:
        await update.message.reply_text("Bot is initializing.")
        return

    # P1-3: Verify chat is linked
    if not await _require_linked(update, db):
        return

    chat_id = update.effective_chat.id
    role = await _get_role(chat_id, db)

    uid = await _get_student_uid(db)
    if not uid:
        await update.message.reply_text("Студент ще не зареєстрований.")
        return

    today_str = date.today().isoformat()
    session_doc = await db.collection("sessions").document(f"{uid}_{today_str}").get()

    if role == TelegramRole.MOTHER:
        # Mother sees only yes/no
        if session_doc.exists:
            data = session_doc.to_dict()
            if data.get("finished_at"):
                await update.message.reply_text("Сьогодні: Так, сесію завершено.")
            else:
                await update.message.reply_text("Сьогодні: Сесія в процесі.")
        else:
            await update.message.reply_text("Сьогодні: Ще не починав.")
        return

    # Student view
    if session_doc.exists:
        data = session_doc.to_dict()
        exercises = data.get("exercises_completed", [])
        xp = data.get("xp_earned", 0)
        mood = data.get("mood_start", "?")

        text = (
            f"Сьогоднішня сесія:\n"
            f"Настрій: {MOOD_LABELS.get(mood, mood)}\n"
            f"Вправ виконано: {len(exercises)}\n"
            f"XP зароблено: {xp}\n"
        )
        if data.get("finished_at"):
            text += "Статус: Завершено"
        else:
            text += "Статус: В процесі"
    else:
        text = "Сьогодні сесію ще не розпочато. Використай /mood щоб почати!"

    await update.message.reply_text(text)


async def cmd_progress(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Level, XP, streak, phase summary."""
    db = await _get_db_from_context(context)
    if db is None:
        await update.message.reply_text("Bot is initializing.")
        return

    # P1-3: Verify chat is linked
    if not await _require_linked(update, db):
        return

    # Role check: student only
    if not await _require_role(update, db, TelegramRole.STUDENT):
        return

    uid = await _get_student_uid(db)
    if not uid:
        await update.message.reply_text("Студент ще не зареєстрований.")
        return

    user_doc = await db.collection("users").document(uid).get()
    if not user_doc.exists:
        await update.message.reply_text("Профіль не знайдено.")
        return

    u = user_doc.to_dict()
    level = u.get("level", 0)
    xp = u.get("xp", 0)
    next_xp = LEVEL_XP_THRESHOLDS.get(min(level + 1, 6), LEVEL_XP_THRESHOLDS[6])
    level_name = LEVEL_NAMES.get(level, "?")
    phase = u.get("phase", "phase0")
    streak = u.get("streak_days", 0)
    shields = u.get("shields", 0)

    # Progress bar
    progress_pct = min(100, int((xp / next_xp) * 100)) if next_xp > 0 else 100
    bar_filled = progress_pct // 10
    bar = "=" * bar_filled + "-" * (10 - bar_filled)

    text = (
        f"Рівень {level}: {level_name}\n"
        f"XP: {xp}/{next_xp} [{bar}] {progress_pct}%\n"
        f"Фаза: {phase}\n"
        f"Серія: {streak} днів\n"
        f"Щити: {shields}/3"
    )

    await update.message.reply_text(text)


async def cmd_drill(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Random function from drill pool."""
    db = await _get_db_from_context(context)
    if db is None:
        await update.message.reply_text("Bot is initializing.")
        return

    # P1-3: Verify chat is linked
    if not await _require_linked(update, db):
        return

    # Role check: student only
    if not await _require_role(update, db, TelegramRole.STUDENT):
        return

    uid = await _get_student_uid(db)
    if not uid:
        await update.message.reply_text("Студент ще не зареєстрований.")
        return

    drill_doc = await db.collection("drill_pool").document(uid).get()
    if not drill_doc.exists or not drill_doc.to_dict().get("function_queue"):
        await update.message.reply_text(
            "Черга дрилів порожня. Заверши більше вправ, щоб заповнити чергу!"
        )
        return

    queue = drill_doc.to_dict().get("function_queue", [])
    # Pick the least recently drilled (first in queue)
    next_drill = queue[0]

    # Fetch exercise name
    ex_doc = await db.collection("exercises").document(next_drill).get()
    title = next_drill
    if ex_doc.exists:
        title = ex_doc.to_dict().get("title", next_drill)

    await update.message.reply_text(
        f"Дрил: {title}\n"
        f"ID: {next_drill}\n\n"
        f"Напиши функцію та завантаж результат через платформу.\n"
        f"Відлік часу почався!"
    )


async def cmd_hint(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Current exercise hint (if in session)."""
    db = await _get_db_from_context(context)
    if db is None:
        await update.message.reply_text("Bot is initializing.")
        return

    # P1-3: Verify chat is linked
    if not await _require_linked(update, db):
        return

    # Role check: student only
    if not await _require_role(update, db, TelegramRole.STUDENT):
        return

    uid = await _get_student_uid(db)
    if not uid:
        await update.message.reply_text("Студент ще не зареєстрований.")
        return

    # Check current session
    today_str = date.today().isoformat()
    session_doc = await db.collection("sessions").document(f"{uid}_{today_str}").get()
    if not session_doc.exists:
        await update.message.reply_text("Немає активної сесії. Почни з /mood.")
        return

    await update.message.reply_text(
        "Підказки доступні через платформу (веб-інтерфейс).\n"
        "Кожна підказка зменшує бонус XP за вправу."
    )


async def cmd_skip(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Skip current exercise."""
    db = await _get_db_from_context(context)
    if db is None:
        await update.message.reply_text("Bot is initializing.")
        return

    # P1-3: Verify chat is linked
    if not await _require_linked(update, db):
        return

    # Role check: student only
    if not await _require_role(update, db, TelegramRole.STUDENT):
        return

    await update.message.reply_text(
        "Пропуск вправи реєструється через платформу (веб-інтерфейс).\n"
        "Пропущені вправи можна повернути пізніше."
    )


async def cmd_mood(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Mood check with inline keyboard (5 moods)."""
    db = await _get_db_from_context(context)
    if db is None:
        await update.message.reply_text("Bot is initializing.")
        return

    # P1-3: Verify chat is linked
    if not await _require_linked(update, db):
        return

    # Role check: student only
    if not await _require_role(update, db, TelegramRole.STUDENT):
        return

    keyboard = [
        [
            InlineKeyboardButton("1 Чудово", callback_data="mood_1"),
            InlineKeyboardButton("2 Добре", callback_data="mood_2"),
            InlineKeyboardButton("3 Нормально", callback_data="mood_3"),
        ],
        [
            InlineKeyboardButton("4 Втомлений", callback_data="mood_4"),
            InlineKeyboardButton("5 Важко", callback_data="mood_5"),
        ],
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    await update.message.reply_text(
        "Як себе почуваєш?",
        reply_markup=reply_markup,
    )


async def _handle_mood_callback(
    update: Update, context: ContextTypes.DEFAULT_TYPE
) -> None:
    """Handle mood selection callback."""
    db = await _get_db_from_context(context)
    if db is None:
        return

    # P2: Verify chat is linked (callback can come from any chat)
    if not await _require_linked(update, db):
        return

    query = update.callback_query
    await query.answer()

    mood_value = query.data.replace("mood_", "")
    mood_label = MOOD_LABELS.get(mood_value, mood_value)

    uid = await _get_student_uid(db)
    if not uid:
        await query.edit_message_text("Студент ще не зареєстрований.")
        return

    # Start session via service
    from app.services.session_service import start_session
    await start_session(uid, mood_value, db)

    await query.edit_message_text(
        f"Настрій: {mood_label}\n"
        f"Сесію розпочато! Використовуй /today для плану."
    )


# --- Mother Handlers ---


async def mother_today(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Redirects to cmd_today which handles role differentiation."""
    await cmd_today(update, context)


async def mother_week(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Weekly summary (primary report)."""
    db = await _get_db_from_context(context)
    if db is None:
        await update.message.reply_text("Bot is initializing.")
        return

    # P1-3: Verify chat is linked
    if not await _require_linked(update, db):
        return

    chat_id = update.effective_chat.id
    role = await _get_role(chat_id, db)
    if role != TelegramRole.MOTHER:
        await update.message.reply_text("Ця команда тільки для спостерігача.")
        return

    uid = await _get_student_uid(db)
    if not uid:
        await update.message.reply_text("Студент ще не зареєстрований.")
        return

    text = await _generate_weekly_report(uid, db)
    await update.message.reply_text(text)


async def mother_streak(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Current streak info."""
    db = await _get_db_from_context(context)
    if db is None:
        await update.message.reply_text("Bot is initializing.")
        return

    # P1-3: Verify chat is linked
    if not await _require_linked(update, db):
        return

    chat_id = update.effective_chat.id
    role = await _get_role(chat_id, db)
    if role != TelegramRole.MOTHER:
        await update.message.reply_text("Ця команда тільки для спостерігача.")
        return

    uid = await _get_student_uid(db)
    if not uid:
        await update.message.reply_text("Студент ще не зареєстрований.")
        return

    user_doc = await db.collection("users").document(uid).get()
    if not user_doc.exists:
        await update.message.reply_text("Профіль не знайдено.")
        return

    u = user_doc.to_dict()
    weekly_days = u.get("weekly_completed_days", [])

    # Count this week
    today = date.today()
    monday = today - timedelta(days=today.weekday())
    week_count = sum(
        1 for d_str in weekly_days
        if is_date_in_range(d_str, monday, today)
    )

    streak = u.get("streak_days", 0)
    shields = u.get("shields", 0)

    await update.message.reply_text(
        f"Тижнева активність: {week_count}/7 днів\n"
        f"Серія: {streak} днів поспіль\n"
        f"Щити: {shields}/3"
    )


async def mother_level(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Current level and phase."""
    db = await _get_db_from_context(context)
    if db is None:
        await update.message.reply_text("Bot is initializing.")
        return

    # P1-3: Verify chat is linked
    if not await _require_linked(update, db):
        return

    chat_id = update.effective_chat.id
    role = await _get_role(chat_id, db)
    if role != TelegramRole.MOTHER:
        await update.message.reply_text("Ця команда тільки для спостерігача.")
        return

    uid = await _get_student_uid(db)
    if not uid:
        await update.message.reply_text("Студент ще не зареєстрований.")
        return

    user_doc = await db.collection("users").document(uid).get()
    if not user_doc.exists:
        await update.message.reply_text("Профіль не знайдено.")
        return

    u = user_doc.to_dict()
    level = u.get("level", 0)
    xp = u.get("xp", 0)
    next_xp = LEVEL_XP_THRESHOLDS.get(min(level + 1, 6), LEVEL_XP_THRESHOLDS[6])
    level_name = LEVEL_NAMES.get(level, "?")
    phase = u.get("phase", "phase0")

    progress_pct = min(100, int((xp / next_xp) * 100)) if next_xp > 0 else 100
    bar_filled = progress_pct // 10
    bar = "=" * bar_filled + "-" * (10 - bar_filled)

    await update.message.reply_text(
        f"Рівень {level}: {level_name}\n"
        f"Прогрес: [{bar}] {progress_pct}%\n"
        f"Фаза: {phase}"
    )


# --- Reports ---


async def _generate_weekly_report(uid: str, db: AsyncClient) -> str:
    """Generate weekly summary text."""
    user_doc = await db.collection("users").document(uid).get()
    if not user_doc.exists:
        return "Профіль студента не знайдено."

    u = user_doc.to_dict()

    # Count sessions this week
    today = date.today()
    monday = today - timedelta(days=today.weekday())
    sessions_count = 0
    total_xp = 0
    total_exercises = 0

    for i in range(7):
        d = monday + timedelta(days=i)
        if d > today:
            break
        doc_id = f"{uid}_{d.isoformat()}"
        session_doc = await db.collection("sessions").document(doc_id).get()
        if session_doc.exists:
            s_data = session_doc.to_dict()
            sessions_count += 1
            total_xp += s_data.get("xp_earned", 0)
            total_exercises += len(s_data.get("exercises_completed", []))

    level = u.get("level", 0)
    level_name = LEVEL_NAMES.get(level, "?")
    streak = u.get("streak_days", 0)
    phase = u.get("phase", "phase0")

    report = (
        f"Тижневий звіт ({monday.isoformat()} -- {today.isoformat()}):\n\n"
        f"Сесій проведено: {sessions_count}/7\n"
        f"Вправ виконано: {total_exercises}\n"
        f"XP зароблено: {total_xp}\n"
        f"Серія: {streak} днів\n\n"
        f"Рівень: {level} ({level_name})\n"
        f"Фаза: {phase}\n\n"
        f"Загальний XP: {u.get('xp', 0)}"
    )

    return report


async def send_weekly_report(db: AsyncClient) -> None:
    """Sunday 19:00 auto-report to all observers (mother role)."""
    # Find all observer chats
    query = db.collection("telegram_links").where(
        filter=FieldFilter("role", "==", TelegramRole.MOTHER.value)
    )
    observer_chat_ids: list[int] = []
    async for doc in query.stream():
        chat_id = doc.to_dict().get("chat_id")
        if chat_id:
            observer_chat_ids.append(chat_id)

    if not observer_chat_ids:
        logger.warning("No observer chats linked for weekly report")
        return

    uid = await _get_student_uid(db)
    if not uid:
        logger.warning("No student found for weekly report")
        return

    report = await _generate_weekly_report(uid, db)

    # Send to all observers
    from telegram import Bot
    if settings.telegram_bot_token:
        bot = Bot(settings.telegram_bot_token)
        for chat_id in observer_chat_ids:
            try:
                await bot.send_message(chat_id=chat_id, text=report)
                logger.info("Weekly report sent", chat_id=chat_id)
            except Exception:
                logger.exception("Failed to send weekly report", chat_id=chat_id)


async def send_student_preview(db: AsyncClient) -> None:
    """Saturday 19:00 preview to student."""
    uid = await _get_student_uid(db)
    if not uid:
        return

    # Read student chat_id from telegram_links (not users doc — P1-6 security fix)
    query = db.collection("telegram_links").where(
        filter=FieldFilter("role", "==", TelegramRole.STUDENT.value)
    )
    student_chat_id: int | None = None
    async for doc in query.stream():
        student_chat_id = doc.to_dict().get("chat_id")
        break

    if not student_chat_id:
        logger.warning("No student chat linked for preview")
        return

    report = await _generate_weekly_report(uid, db)
    preview_text = (
        f"Попередній перегляд тижневого звіту:\n\n{report}\n\n"
        "Цей звіт буде надіслано завтра о 19:00."
    )

    from telegram import Bot
    if settings.telegram_bot_token:
        bot = Bot(settings.telegram_bot_token)
        await bot.send_message(chat_id=student_chat_id, text=preview_text)
        logger.info("Student preview sent", chat_id=student_chat_id)


# --- Bot Setup ---


def setup_bot(token: str) -> Application:
    """Create bot Application, register all handlers."""
    app = Application.builder().token(token).build()

    # Command handlers
    app.add_handler(CommandHandler("start", cmd_start))
    app.add_handler(CommandHandler("today", cmd_today))
    app.add_handler(CommandHandler("progress", cmd_progress))
    app.add_handler(CommandHandler("drill", cmd_drill))
    app.add_handler(CommandHandler("hint", cmd_hint))
    app.add_handler(CommandHandler("skip", cmd_skip))
    app.add_handler(CommandHandler("mood", cmd_mood))

    # Mother-specific commands (handled via role check inside)
    app.add_handler(CommandHandler("week", mother_week))
    app.add_handler(CommandHandler("streak", mother_streak))
    app.add_handler(CommandHandler("level", mother_level))

    # Callback handlers
    app.add_handler(CallbackQueryHandler(_handle_mood_callback, pattern=r"^mood_"))

    return app


async def handle_webhook(update_data: dict, db: AsyncClient, bot_app: Application) -> None:
    """Parse webhook update and process."""
    # Store db in bot_data for handlers to access
    bot_app.bot_data["db"] = db

    update = Update.de_json(update_data, bot_app.bot)
    await bot_app.process_update(update)
