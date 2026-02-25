"""Application configuration via environment variables."""

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """All config from env vars / Secret Manager."""

    # App
    project_id: str = "launchpad42-prod"
    environment: str = "development"
    allowed_origins: list[str] = [
        "http://localhost:5173",
        "https://launchpad42-prod.web.app",
        "https://launchpad42-prod.firebaseapp.com",
    ]

    # Telegram
    telegram_bot_token: str = ""
    telegram_webhook_path: str = "/telegram/webhook"
    mother_access_code: str = ""

    # AI Tutor (DashScope / Qwen)
    tutor_api_key: str = ""
    tutor_api_base: str = "https://dashscope-intl.aliyuncs.com/compatible-mode/v1"
    tutor_model: str = "qwen3.5-flash"

    # Curriculum
    day1_date: str = "2026-02-26"
    piscine_date: str = "2026-06-29"

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8"}


settings = Settings()
