"""Shared base model with camelCase alias generation for frontend contract."""

from datetime import datetime, timezone

from pydantic import BaseModel, ConfigDict

from app.core.utils import to_camel


def utcnow() -> datetime:
    """Return current UTC datetime (timezone-aware). Shared default factory."""
    return datetime.now(timezone.utc)


class CamelModel(BaseModel):
    """Base model that serializes snake_case fields as camelCase for JSON responses."""

    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,
    )
