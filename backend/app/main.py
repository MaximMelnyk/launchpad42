"""42 LaunchPad — FastAPI application entry point."""

from contextlib import asynccontextmanager

import structlog
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.firebase import init_firebase
from app.routers import (
    auth,
    curriculum,
    dashboard,
    exam,
    gamification,
    health,
    session,
    telegram,
    tutor,
)

logger = structlog.get_logger()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Initialize Firebase and Telegram bot on startup."""
    logger.info("Starting 42 LaunchPad API", environment=settings.environment)
    db = init_firebase(settings.project_id)
    app.state.db = db
    logger.info("Firebase initialized", project=settings.project_id)

    # Setup Telegram bot if token configured
    if settings.telegram_bot_token:
        try:
            from app.services.telegram_service import setup_bot

            bot_app = setup_bot(settings.telegram_bot_token)
            app.state.bot = bot_app
            await bot_app.initialize()
            logger.info("Telegram bot initialized")
        except Exception:
            logger.exception("Failed to initialize Telegram bot")

    yield

    # Shutdown Telegram bot
    if hasattr(app.state, "bot"):
        try:
            await app.state.bot.shutdown()
            logger.info("Telegram bot shut down")
        except Exception:
            logger.exception("Error shutting down Telegram bot")

    logger.info("Shutting down 42 LaunchPad API")


is_production = settings.environment == "production"

app = FastAPI(
    title="42 LaunchPad API",
    version="0.1.0",
    lifespan=lifespan,
    docs_url=None if is_production else "/docs",
    redoc_url=None if is_production else "/redoc",
    openapi_url=None if is_production else "/openapi.json",
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)

# Routers
app.include_router(health.router)
app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(curriculum.router, prefix="/curriculum", tags=["curriculum"])
app.include_router(session.router, prefix="/session", tags=["session"])
app.include_router(gamification.router, prefix="/gamification", tags=["gamification"])
app.include_router(exam.router, prefix="/exam", tags=["exam"])
app.include_router(telegram.router, prefix="/telegram", tags=["telegram"])
app.include_router(tutor.router, prefix="/tutor", tags=["tutor"])
app.include_router(dashboard.router, prefix="/dashboard", tags=["dashboard"])
