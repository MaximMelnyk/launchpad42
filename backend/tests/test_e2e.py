"""E2E tests — full HTTP flow through FastAPI with mocked auth and Firestore.

Covers: auth, session lifecycle, exercise submission, gamification (XP, levels,
streaks, achievements), drills, SM-2 reviews, exam lifecycle, AI tutor,
dashboard aggregation, and error handling.
"""

import pytest
from datetime import date, datetime, timedelta, timezone
from unittest.mock import AsyncMock, MagicMock, patch

from fastapi import FastAPI
from httpx import ASGITransport, AsyncClient

from tests.conftest import MockFirestoreDB, TEST_UID


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _create_app(db: MockFirestoreDB) -> FastAPI:
    """Build FastAPI app with all routers, auth + db overridden."""
    from app.core.auth import get_uid
    from app.core.firebase import get_db
    from app.routers import (
        auth, curriculum, dashboard, exam,
        gamification, health, session, tutor,
    )

    app = FastAPI()
    app.include_router(health.router)
    app.include_router(auth.router, prefix="/auth")
    app.include_router(curriculum.router, prefix="/curriculum")
    app.include_router(session.router, prefix="/session")
    app.include_router(gamification.router, prefix="/gamification")
    app.include_router(exam.router, prefix="/exam")
    app.include_router(tutor.router, prefix="/tutor")
    app.include_router(dashboard.router, prefix="/dashboard")

    app.dependency_overrides[get_uid] = lambda: TEST_UID
    app.dependency_overrides[get_db] = lambda: db
    return app


def _seed_exercises(db: MockFirestoreDB) -> None:
    """Seed 5 shell exercises (needed for gate exam level 1)."""
    for i, (ex_id, title) in enumerate([
        ("shell00_ex00", "Shell Basics"),
        ("shell00_ex01", "ls -la"),
        ("shell00_ex02", "chmod"),
        ("shell00_ex03", "cat"),
        ("shell00_ex04", "midLS"),
    ], start=1):
        db.seed("exercises", ex_id, {
            "id": ex_id,
            "module": "shell00",
            "phase": "phase1",
            "title": title,
            "difficulty": 1,
            "xp": 20,
            "estimated_minutes": 15,
            "prerequisites": [],
            "tags": ["shell"],
            "norminette": False,
            "man_pages": [],
            "multi_day": False,
            "content_md": f"# {title}\n\nDescription.",
            "order": i,
        })


def _seed_user(db: MockFirestoreDB, xp: int = 180, level: int = 0) -> None:
    """Seed user profile."""
    db.seed("users", TEST_UID, {
        "uid": TEST_UID,
        "display_name": "Maksym",
        "email": "test@example.com",
        "level": level,
        "xp": xp,
        "phase": "phase0",
        "current_day": 5,
        "streak_days": 3,
        "shields": 0,
        "weekly_completed_days": [],
        "pause_mode": False,
        "telegram_chat_id": None,
        "mood_today": None,
        "created_at": datetime(2026, 2, 26, tzinfo=timezone.utc),
        "updated_at": datetime(2026, 2, 26, tzinfo=timezone.utc),
    })


def _base_db(xp: int = 180, level: int = 0) -> MockFirestoreDB:
    """Create and seed a standard E2E database."""
    db = MockFirestoreDB()
    _seed_user(db, xp=xp, level=level)
    _seed_exercises(db)

    # Review card (due in the past)
    db.seed("review_cards", "vocab_01", {
        "id": "vocab_01",
        "term": "variable",
        "definition": "змінна",
        "interval_days": 3,
        "next_review": datetime(2020, 1, 1, tzinfo=timezone.utc),
        "review_count": 0,
        "correct_count": 0,
    })

    # Drill pool with 2 functions
    db.seed("drill_pool", TEST_UID, {
        "uid": TEST_UID,
        "function_queue": ["shell00_ex00", "shell00_ex01"],
        "last_drilled": {},
        "updated_at": datetime(2026, 2, 26, tzinfo=timezone.utc),
    })

    return db


# ---------------------------------------------------------------------------
# Test 1: Full Student Day Flow
# session → exercise → XP → level up → achievements → streak → dashboard
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_e2e_student_day_flow():
    """Simulate a complete student training day covering core endpoints."""
    db = _base_db(xp=180, level=0)
    app = _create_app(db)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as c:
        # --- Health (public) ---
        r = await c.get("/health")
        assert r.status_code == 200
        assert r.json()["status"] == "ok"

        # --- Auth: get profile ---
        r = await c.get("/auth/profile")
        assert r.status_code == 200
        profile = r.json()
        assert profile["displayName"] == "Maksym"
        assert profile["level"] == 0
        assert profile["xp"] == 180

        # --- Auth: update profile ---
        r = await c.put(
            "/auth/profile",
            json={"displayName": "Max"},
        )
        assert r.status_code == 200
        assert r.json()["displayName"] == "Max"

        # --- Session: start ---
        r = await c.post("/session/start", json={"mood": "2"})
        assert r.status_code == 200
        session = r.json()
        assert session["moodStart"] == "2"
        assert session["uid"] == TEST_UID

        # --- Session: current ---
        r = await c.get("/session/current")
        assert r.status_code == 200
        assert r.json() is not None
        assert r.json()["moodStart"] == "2"

        # --- Curriculum: view exercise ---
        r = await c.get("/curriculum/exercises/shell00_ex00")
        assert r.status_code == 200
        ex_data = r.json()
        assert ex_data["exercise"]["title"] == "Shell Basics"
        assert ex_data["exercise"]["xp"] == 20

        # --- Curriculum: submit exercise ---
        # XP: base 20 + first_attempt 10 + no_hints 5 = 35
        # Total: 180 + 35 = 215 >= 200 (level 1 threshold) → level up
        r = await c.post(
            "/curriculum/exercises/shell00_ex00/submit",
            json={"hashCode": "abcd1234", "hintsUsed": 0},
        )
        assert r.status_code == 200
        sub = r.json()
        assert sub["xpEarned"] == 35
        assert "first_attempt" in sub["bonuses"]
        assert "no_hints" in sub["bonuses"]
        assert sub["levelUp"] is True
        assert "first_blood" in sub["achievementsUnlocked"]

        # --- Curriculum: re-submit same exercise → 0 XP (anti-farming) ---
        r = await c.post(
            "/curriculum/exercises/shell00_ex00/submit",
            json={"hashCode": "abcd1234", "hintsUsed": 0},
        )
        assert r.status_code == 200
        assert r.json()["xpEarned"] == 0
        assert r.json()["alreadyCompleted"] is True

        # --- Curriculum: submit second exercise (with hints → no bonus) ---
        r = await c.post(
            "/curriculum/exercises/shell00_ex01/submit",
            json={"hashCode": "11223344", "hintsUsed": 2},
        )
        assert r.status_code == 200
        sub2 = r.json()
        # first_attempt bonus yes (first try), but no no_hints bonus
        assert sub2["xpEarned"] > 0
        assert "first_attempt" in sub2["bonuses"]
        assert "no_hints" not in sub2["bonuses"]

        # --- Gamification: profile ---
        r = await c.get("/gamification/profile")
        assert r.status_code == 200
        gam = r.json()
        assert gam["level"] == 1
        assert gam["levelName"] == "Shell"
        assert gam["xp"] > 180  # XP increased

        # --- Gamification: streak ---
        r = await c.post("/gamification/streak")
        assert r.status_code == 200
        streak = r.json()
        assert "streakDays" in streak
        assert "shields" in streak
        assert "weeklyProgress" in streak

        # --- Gamification: achievements ---
        r = await c.get("/gamification/achievements")
        assert r.status_code == 200
        achs = r.json()
        assert len(achs) == 8  # All 8 achievements listed
        fb = next(a for a in achs if a["achievementId"] == "first_blood")
        assert fb["unlocked"] is True
        assert fb["unlockedAt"] is not None
        assert fb["nameUk"] == "Перший крок"

        # --- Dashboard (aggregated) ---
        r = await c.get("/dashboard")
        assert r.status_code == 200
        dash = r.json()
        assert "user" in dash
        assert "session" in dash
        assert "gamification" in dash
        assert "achievements" in dash
        assert "currentDay" in dash
        assert dash["gamification"]["level"] == 1

        # --- Verify session aggregates updated after exercise submissions ---
        r = await c.get("/session/current")
        assert r.status_code == 200
        sess_data = r.json()
        assert "shell00_ex00" in sess_data["exercisesCompleted"]
        assert "shell00_ex01" in sess_data["exercisesCompleted"]
        assert sess_data["xpEarned"] > 0

        # --- Session: end ---
        r = await c.post(
            "/session/end",
            json={"mood": "1", "durationMinutes": 90},
        )
        assert r.status_code == 200
        ended = r.json()
        assert ended["moodEnd"] == "1"
        assert ended["durationMinutes"] == 90


# ---------------------------------------------------------------------------
# Test 2: Multi-level Jump (P2-1 fix validation)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_e2e_multi_level_jump():
    """Verify check_level_up loops correctly: level 0 → level 2 in one submit."""
    db = _base_db(xp=580, level=0)  # Just below level 2 (600)
    app = _create_app(db)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as c:
        # Submit exercise: XP 580 + 35 = 615 > 600 (level 2)
        # Should jump from level 0 directly to level 2 (skipping level 1)
        r = await c.post(
            "/curriculum/exercises/shell00_ex00/submit",
            json={"hashCode": "aabbccdd", "hintsUsed": 0},
        )
        assert r.status_code == 200
        assert r.json()["levelUp"] is True

        r = await c.get("/gamification/profile")
        assert r.status_code == 200
        assert r.json()["level"] == 2
        assert r.json()["levelName"] == "Core"


# ---------------------------------------------------------------------------
# Test 3: Drill + Review SRS Flow
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_e2e_drill_and_review_flow():
    """Drill verification and SM-2 review with anti-farming guards."""
    db = _base_db(xp=100, level=1)
    app = _create_app(db)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as c:
        # --- Drill: verify (fast completion → 20 XP) ---
        r = await c.post(
            "/gamification/drill/verify",
            json={"functionName": "shell00_ex00", "timeSeconds": 120},
        )
        assert r.status_code == 200
        drill = r.json()
        assert drill["correct"] is True
        assert drill["xpEarned"] == 20  # Fast: 120s < 900s estimated

        # --- Drill: same function again today → 0 XP (anti-farming) ---
        r = await c.post(
            "/gamification/drill/verify",
            json={"functionName": "shell00_ex00", "timeSeconds": 120},
        )
        assert r.status_code == 200
        assert r.json()["xpEarned"] == 0
        assert r.json()["alreadyDrilled"] is True

        # --- Drill: different function → XP awarded ---
        r = await c.post(
            "/gamification/drill/verify",
            json={"functionName": "shell00_ex01", "timeSeconds": 1200},
        )
        assert r.status_code == 200
        drill2 = r.json()
        assert drill2["correct"] is True
        assert drill2["xpEarned"] == 10  # Slow: 1200s > 900s

        # --- Drill: function not in queue → error ---
        r = await c.post(
            "/gamification/drill/verify",
            json={"functionName": "nonexistent_fn", "timeSeconds": 60},
        )
        assert r.status_code == 200
        assert r.json()["correct"] is False
        assert "error" in r.json()

        # --- Review: correct answer → XP + interval advance ---
        r = await c.post(
            "/gamification/review",
            json={"cardId": "vocab_01", "correct": True},
        )
        assert r.status_code == 200
        rev = r.json()
        assert rev["xpEarned"] == 5  # XP_BONUS_VOCAB
        assert rev["intervalDays"] == 5  # 3 → 5 in SM-2

        # --- Review: same card again → 0 XP (not due yet) ---
        r = await c.post(
            "/gamification/review",
            json={"cardId": "vocab_01", "correct": True},
        )
        assert r.status_code == 200
        assert r.json()["xpEarned"] == 0
        assert r.json()["alreadyReviewed"] is True

        # --- Review: nonexistent card → 404 ---
        r = await c.post(
            "/gamification/review",
            json={"cardId": "nonexistent_card", "correct": True},
        )
        assert r.status_code == 404

        # --- Verify total XP increase ---
        r = await c.get("/gamification/profile")
        assert r.status_code == 200
        # 100 + 20 (drill1) + 10 (drill2) + 5 (review) + achievements
        assert r.json()["xp"] > 100


# ---------------------------------------------------------------------------
# Test 4: Exam Lifecycle (gate exam, 5 exercises, pass)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_e2e_exam_lifecycle():
    """Full gate exam: cooldown check → start → submit all → pass → XP bonus."""
    db = _base_db(xp=300, level=1)
    app = _create_app(db)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as c:
        # --- Cooldown check: no prior exams → can start ---
        r = await c.get("/exam/cooldown/gate")
        assert r.status_code == 200
        assert r.json()["canStart"] is True

        # --- Start gate exam level 1 ---
        r = await c.post(
            "/exam/start",
            json={"examType": "gate", "level": 1},
        )
        assert r.status_code == 200
        exam = r.json()
        exam_id = exam["examId"]
        assert exam["examType"] == "gate"
        assert exam["status"] == "in_progress"
        assert len(exam["exercises"]) == 5
        assert exam["timeLimitMinutes"] == 240

        # --- Get exam status ---
        r = await c.get(f"/exam/{exam_id}")
        assert r.status_code == 200
        status = r.json()
        assert status["status"] == "in_progress"
        assert "timeRemainingMinutes" in status

        # --- Submit all 5 exercises (8-char hex hash each) ---
        hashes = ["a1b2c3d4", "e5f6a7b8", "c9d0e1f2", "a3b4c5d6", "e7f8a9b0"]
        exercises = exam["exercises"]

        for i, (ex_id, hash_code) in enumerate(zip(exercises, hashes)):
            r = await c.post(
                f"/exam/{exam_id}/submit",
                json={"exerciseId": ex_id, "hashCode": hash_code},
            )
            assert r.status_code == 200
            result = r.json()
            assert result["correct"] is True
            assert result["score"] == (i + 1) / 5

            if i < 4:
                assert result["completed"] is False
            else:
                assert result["completed"] is True

        # --- Verify exam passed ---
        r = await c.get(f"/exam/{exam_id}")
        assert r.status_code == 200
        final = r.json()
        assert final["status"] == "passed"
        assert final["score"] == 1.0

        # --- Verify XP bonus awarded ---
        r = await c.get("/gamification/profile")
        assert r.status_code == 200
        # 300 (initial) + 50 (exam pass bonus) + achievements
        assert r.json()["xp"] >= 350

        # --- Invalid exam type → 400 ---
        r = await c.get("/exam/cooldown/invalid_type")
        assert r.status_code == 400


# ---------------------------------------------------------------------------
# Test 5: AI Tutor Flow
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_e2e_tutor_no_api_key():
    """Tutor returns error message when API key is not configured."""
    db = _base_db()
    app = _create_app(db)

    with patch("app.services.tutor_service.settings") as mock_settings:
        mock_settings.tutor_api_key = ""

        async with AsyncClient(
            transport=ASGITransport(app=app), base_url="http://test"
        ) as c:
            # Rate limit check still passes (< 20/day)
            r = await c.post(
                "/tutor/ask",
                json={"message": "Що таке write()?"},
            )
            assert r.status_code == 200
            resp = r.json()
            assert "недоступний" in resp["reply"]
            assert resp["tokensUsed"] == 0


@pytest.mark.asyncio
async def test_e2e_tutor_with_mocked_api():
    """Tutor returns AI response with student context (mocked Qwen API)."""
    db = _base_db(xp=200, level=1)
    app = _create_app(db)

    mock_response = MagicMock()
    mock_response.status_code = 200
    mock_response.raise_for_status = MagicMock()
    mock_response.json.return_value = {
        "choices": [{"message": {"content": "Використовуй write(1, &c, 1);"}}],
        "usage": {"total_tokens": 42},
    }

    mock_client_instance = AsyncMock()
    mock_client_instance.post = AsyncMock(return_value=mock_response)
    mock_client_instance.__aenter__ = AsyncMock(return_value=mock_client_instance)
    mock_client_instance.__aexit__ = AsyncMock(return_value=False)

    with patch("app.services.tutor_service.settings") as mock_settings, \
         patch("app.services.tutor_service.httpx.AsyncClient", return_value=mock_client_instance):
        mock_settings.tutor_api_key = "test-key"
        mock_settings.tutor_api_base = "http://fake-api"
        mock_settings.tutor_model = "test-model"

        async with AsyncClient(
            transport=ASGITransport(app=app), base_url="http://test"
        ) as c:
            r = await c.post(
                "/tutor/ask",
                json={
                    "message": "Як працює write?",
                    "exerciseId": "shell00_ex00",
                },
            )
            assert r.status_code == 200
            resp = r.json()
            assert "write" in resp["reply"]
            assert resp["tokensUsed"] == 42

            # Verify context was sent to API (student profile + exercise)
            call_args = mock_client_instance.post.call_args
            messages = call_args.kwargs["json"]["messages"]
            # System prompt + profile + exercise context + user message
            assert len(messages) >= 3
            # System prompt is first
            assert "tutor" in messages[0]["content"].lower()

            # Verify conversation was saved to tutor_history
            history_data = db._collections.get("tutor_history", {}).get(TEST_UID)
            assert history_data is not None
            assert len(history_data["messages"]) == 2  # user + assistant


@pytest.mark.asyncio
async def test_e2e_tutor_rate_limit():
    """Tutor enforces 20 questions/day limit."""
    db = _base_db()
    app = _create_app(db)

    # Pre-seed usage counter at 20 (limit reached)
    today_str = date.today().isoformat()
    db.seed("tutor_usage", f"{TEST_UID}_{today_str}", {
        "uid": TEST_UID,
        "date": today_str,
        "count": 20,
        "updated_at": datetime.now(timezone.utc),
    })

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as c:
        r = await c.post(
            "/tutor/ask",
            json={"message": "Ще питання"},
        )
        assert r.status_code == 200
        resp = r.json()
        assert "ліміт" in resp["reply"]
        assert resp["tokensUsed"] == 0


# ---------------------------------------------------------------------------
# Test 6: Error Handling
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_e2e_error_handling():
    """Verify proper error responses for invalid requests."""
    db = _base_db()
    app = _create_app(db)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as c:
        # --- 404: nonexistent exercise ---
        r = await c.get("/curriculum/exercises/nonexistent_exercise")
        assert r.status_code == 404

        # --- 400: invalid hash format ---
        r = await c.post(
            "/curriculum/exercises/shell00_ex00/submit",
            json={"hashCode": "INVALID", "hintsUsed": 0},
        )
        assert r.status_code == 400

        # --- 400: invalid phase ---
        r = await c.get("/curriculum/phase/phase99")
        assert r.status_code == 400

        # --- 400: start exam with invalid type ---
        r = await c.post(
            "/exam/start",
            json={"examType": "invalid", "level": 1},
        )
        assert r.status_code == 400

        # --- 400: start exam with no exercises for level 0 ---
        r = await c.post(
            "/exam/start",
            json={"examType": "gate", "level": 0},
        )
        assert r.status_code == 400

        # --- 404: get nonexistent exam ---
        r = await c.get("/exam/nonexistent123")
        assert r.status_code == 404

        # --- 400: submit to nonexistent exam ---
        r = await c.post(
            "/exam/nonexistent123/submit",
            json={"exerciseId": "shell00_ex00", "hashCode": "aabbccdd"},
        )
        assert r.status_code == 400

        # --- 400: no fields in profile update ---
        r = await c.put("/auth/profile", json={})
        assert r.status_code == 400

        # --- Session end without start → error ---
        # Delete any existing session first
        today_str = date.today().isoformat()
        doc_id = f"{TEST_UID}_{today_str}"
        if "sessions" in db._collections:
            db._collections["sessions"].pop(doc_id, None)
        r = await c.post(
            "/session/end",
            json={"mood": "1", "durationMinutes": 60},
        )
        assert r.status_code == 400


# ---------------------------------------------------------------------------
# Test 7: Curriculum Browsing
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_e2e_curriculum_browsing():
    """Verify today endpoint and phase listing."""
    db = _base_db()
    app = _create_app(db)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as c:
        # --- Today's exercises ---
        r = await c.get("/curriculum/today")
        assert r.status_code == 200
        today = r.json()
        assert "currentDay" in today
        assert "phase" in today
        assert "exercises" in today
        assert "reviewCards" in today
        assert "drill" in today

        # --- Phase listing ---
        r = await c.get("/curriculum/phase/phase1")
        assert r.status_code == 200
        exercises = r.json()
        assert isinstance(exercises, list)
        assert len(exercises) == 5  # 5 shell exercises seeded in phase1
        # Each item has exercise + progress
        for item in exercises:
            assert "exercise" in item
            assert "progress" in item


# ---------------------------------------------------------------------------
# Test 8: Profile Auto-Create
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_e2e_profile_auto_create():
    """Verify new user profile is auto-created on first GET /auth/profile."""
    db = MockFirestoreDB()  # Empty DB — no user seeded
    app = _create_app(db)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as c:
        r = await c.get("/auth/profile")
        assert r.status_code == 200
        profile = r.json()
        assert profile["uid"] == TEST_UID
        assert profile["level"] == 0
        assert profile["xp"] == 0

        # Verify profile was persisted with computed phase/current_day
        stored = db._collections["users"][TEST_UID]
        assert stored["uid"] == TEST_UID
        assert "phase" in stored
        assert "current_day" in stored


# ---------------------------------------------------------------------------
# Test 9: Phase/CurrentDay Sync on Profile Read (P2-M01 fix)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_e2e_phase_sync_on_profile_read():
    """Verify profile sync: stale phase/current_day is overwritten by computed."""
    db = _base_db()
    # Seed user with intentionally stale phase
    db._collections["users"][TEST_UID]["phase"] = "phase0"
    db._collections["users"][TEST_UID]["current_day"] = 1
    app = _create_app(db)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as c:
        r = await c.get("/auth/profile")
        assert r.status_code == 200
        profile = r.json()
        # Computed values should override stale ones
        # (exact values depend on settings.day1_date and today's date)
        assert profile["currentDay"] >= 1
        assert profile["phase"].startswith("phase")
        # Verify DB was updated to match
        stored = db._collections["users"][TEST_UID]
        assert stored["phase"] == profile["phase"]
        assert stored["current_day"] == profile["currentDay"]


# ---------------------------------------------------------------------------
# Test 10: Mood Clearing via Profile Update (P2-M06 fix)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_e2e_mood_clearing():
    """Verify mood_today can be cleared by sending null (exclude_unset fix)."""
    db = _base_db()
    # Set mood to non-null
    db._collections["users"][TEST_UID]["mood_today"] = "3"
    app = _create_app(db)

    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as c:
        # Confirm mood is set
        r = await c.get("/auth/profile")
        assert r.status_code == 200
        assert r.json()["moodToday"] == "3"

        # Clear mood by sending null
        r = await c.put("/auth/profile", json={"moodToday": None})
        assert r.status_code == 200
        assert r.json()["moodToday"] is None

        # Verify persisted
        stored = db._collections["users"][TEST_UID]
        assert stored["mood_today"] is None
