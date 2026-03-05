"""Integration tests for FastAPI routers using TestClient."""

from datetime import date, datetime
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from httpx import ASGITransport, AsyncClient

from tests.conftest import MockDocumentSnapshot, MockFirestoreDB, MockQuery


@pytest.fixture
def mock_firebase_db():
    """Create a mock Firestore DB with test data."""
    db = MockFirestoreDB()
    db.seed("users", "test-uid-123", {
        "uid": "test-uid-123",
        "display_name": "Maksym",
        "email": "test@example.com",
        "level": 0,
        "xp": 50,
        "phase": "phase0",
        "current_day": 1,
        "streak_days": 3,
        "shields": 0,
        "weekly_completed_days": [],
        "pause_mode": False,
        "telegram_chat_id": None,
        "mood_today": None,
        "created_at": datetime(2026, 2, 26),
        "updated_at": datetime(2026, 2, 26),
    })
    return db


@pytest.fixture
def app_with_mocks(mock_firebase_db):
    """Create FastAPI app with mocked dependencies."""
    # Patch Firebase init and auth before importing app
    with (
        patch("app.core.firebase.init_firebase", return_value=mock_firebase_db),
        patch("app.core.firebase.db", mock_firebase_db),
        patch("app.core.config.settings") as mock_settings,
    ):
        mock_settings.project_id = "test-project"
        mock_settings.environment = "test"
        mock_settings.allowed_origins = ["http://localhost:5173"]
        mock_settings.telegram_bot_token = ""
        mock_settings.telegram_webhook_path = "/telegram/webhook"
        mock_settings.mother_access_code = ""
        mock_settings.tutor_api_key = ""
        mock_settings.tutor_api_base = "https://test.api"
        mock_settings.tutor_model = "test-model"
        mock_settings.day1_date = "2026-02-26"
        mock_settings.piscine_date = "2026-06-29"

        from app.main import app

        # Override get_db to return mock
        from app.core.firebase import get_db

        app.dependency_overrides[get_db] = lambda: mock_firebase_db

        # Override auth dependencies to return test uid
        from app.core.auth import get_uid, require_registered_user

        app.dependency_overrides[get_uid] = lambda: "test-uid-123"
        app.dependency_overrides[require_registered_user] = lambda: "test-uid-123"

        yield app

        # Cleanup overrides
        app.dependency_overrides.clear()


# --- Health Check ---


class TestHealthEndpoint:
    """Health check endpoint tests."""

    @pytest.mark.asyncio
    async def test_health_returns_200(self, app_with_mocks):
        transport = ASGITransport(app=app_with_mocks)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.get("/health")
            assert response.status_code == 200
            data = response.json()
            assert data["status"] == "ok"


# --- Auth Endpoints ---


class TestAuthEndpoints:
    """Auth router integration tests."""

    @pytest.mark.asyncio
    async def test_get_profile(self, app_with_mocks):
        transport = ASGITransport(app=app_with_mocks)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.get("/auth/profile")
            assert response.status_code == 200
            data = response.json()
            assert data["uid"] == "test-uid-123"
            # CamelModel: response keys are camelCase
            assert data["displayName"] == "Maksym"
            assert data["level"] == 0

    @pytest.mark.asyncio
    async def test_update_profile(self, app_with_mocks):
        transport = ASGITransport(app=app_with_mocks)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            # CamelModel accepts both camelCase and snake_case (populate_by_name=True)
            response = await client.put(
                "/auth/profile",
                json={"displayName": "New Name"},
            )
            assert response.status_code == 200
            data = response.json()
            assert data["displayName"] == "New Name"

    @pytest.mark.asyncio
    async def test_update_profile_empty(self, app_with_mocks):
        transport = ASGITransport(app=app_with_mocks)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.put(
                "/auth/profile",
                json={},
            )
            assert response.status_code == 400

    @pytest.mark.asyncio
    async def test_wrong_account_blocked(self, mock_firebase_db):
        """Login with a second Google account returns 403 wrong_account."""
        with (
            patch("app.core.firebase.init_firebase", return_value=mock_firebase_db),
            patch("app.core.firebase.db", mock_firebase_db),
            patch("app.core.config.settings") as mock_settings,
        ):
            mock_settings.project_id = "test-project"
            mock_settings.environment = "test"
            mock_settings.allowed_origins = ["http://localhost:5173"]
            mock_settings.telegram_bot_token = ""
            mock_settings.telegram_webhook_path = "/telegram/webhook"
            mock_settings.mother_access_code = ""
            mock_settings.tutor_api_key = ""
            mock_settings.tutor_api_base = "https://test.api"
            mock_settings.tutor_model = "test-model"
            mock_settings.day1_date = "2026-02-26"
            mock_settings.piscine_date = "2026-06-29"

            from app.main import app
            from app.core.firebase import get_db
            from app.core.auth import get_uid

            # Override get_uid to return a DIFFERENT uid
            app.dependency_overrides[get_db] = lambda: mock_firebase_db
            app.dependency_overrides[get_uid] = lambda: "wrong-uid-999"

            transport = ASGITransport(app=app)
            async with AsyncClient(transport=transport, base_url="http://test") as client:
                response = await client.get("/auth/profile")
                assert response.status_code == 403
                assert response.json()["detail"] == "wrong_account"

            app.dependency_overrides.clear()


# --- Session Endpoints ---


class TestSessionEndpoints:
    """Session router integration tests."""

    @pytest.mark.asyncio
    async def test_start_session(self, app_with_mocks):
        transport = ASGITransport(app=app_with_mocks)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.post(
                "/session/start",
                json={"mood": "3"},
            )
            assert response.status_code == 200
            data = response.json()
            assert data["uid"] == "test-uid-123"
            # CamelModel: response keys are camelCase
            assert data["moodStart"] == "3"
            assert data["date"] == date.today().isoformat()

    @pytest.mark.asyncio
    async def test_get_current_session_none(self, app_with_mocks):
        transport = ASGITransport(app=app_with_mocks)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.get("/session/current")
            assert response.status_code == 200
            # No session exists yet
            assert response.json() is None

    @pytest.mark.asyncio
    async def test_end_session_no_active(self, app_with_mocks):
        transport = ASGITransport(app=app_with_mocks)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            # CamelModel accepts both camelCase and snake_case
            response = await client.post(
                "/session/end",
                json={"mood": "4", "durationMinutes": 120},
            )
            assert response.status_code == 400


# --- Gamification Endpoints ---


class TestGamificationEndpoints:
    """Gamification router integration tests."""

    @pytest.mark.asyncio
    async def test_gamification_profile(self, app_with_mocks):
        transport = ASGITransport(app=app_with_mocks)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.get("/gamification/profile")
            assert response.status_code == 200
            data = response.json()
            assert data["level"] == 0
            # Fix 1: raw dicts now wrapped in camel_dict, keys are camelCase
            assert data["levelName"] == "Init"
            assert data["xp"] == 50
