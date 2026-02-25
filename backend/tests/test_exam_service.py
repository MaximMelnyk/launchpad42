"""Tests for exam service — datetime normalization, exam lifecycle."""

from datetime import datetime, timezone

import pytest

from app.services.exam_service import _ensure_aware


class TestEnsureAware:
    """Datetime normalization tests."""

    def test_none_returns_none(self):
        assert _ensure_aware(None) is None

    def test_aware_datetime_unchanged(self):
        dt = datetime(2026, 3, 1, 12, 0, tzinfo=timezone.utc)
        result = _ensure_aware(dt)
        assert result == dt
        assert result.tzinfo is not None

    def test_naive_datetime_gets_utc(self):
        dt = datetime(2026, 3, 1, 12, 0)
        result = _ensure_aware(dt)
        assert result.tzinfo == timezone.utc
        assert result.year == 2026

    def test_iso_string_parsed(self):
        result = _ensure_aware("2026-03-01T12:00:00")
        assert isinstance(result, datetime)
        assert result.tzinfo == timezone.utc

    def test_iso_string_with_tz_parsed(self):
        result = _ensure_aware("2026-03-01T12:00:00+00:00")
        assert isinstance(result, datetime)
        assert result.tzinfo is not None

    def test_invalid_string_raises(self):
        with pytest.raises(ValueError):
            _ensure_aware("not-a-date")
