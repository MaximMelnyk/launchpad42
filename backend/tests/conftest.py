"""Shared test fixtures for 42 LaunchPad backend tests."""

from datetime import datetime
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from httpx import ASGITransport, AsyncClient


# --- Mock Firestore Document ---


class MockDocumentSnapshot:
    """Mock a Firestore document snapshot."""

    def __init__(self, data: dict | None = None, doc_id: str = "test-doc"):
        self._data = data
        self._id = doc_id
        self.exists = data is not None

    @property
    def id(self) -> str:
        return self._id

    def to_dict(self) -> dict | None:
        return self._data


class MockQueryStream:
    """Mock an async Firestore query stream."""

    def __init__(self, docs: list[MockDocumentSnapshot]):
        self._docs = docs

    def __aiter__(self):
        return self

    async def __anext__(self):
        if not self._docs:
            raise StopAsyncIteration
        return self._docs.pop(0)


class MockQuery:
    """Mock a Firestore query object with chained where()."""

    def __init__(self, docs: list[MockDocumentSnapshot] | None = None):
        self._docs = docs or []

    def where(self, **kwargs):
        return self

    def limit(self, n: int):
        return self

    def stream(self):
        return MockQueryStream(list(self._docs))


class MockDocumentRef:
    """Mock a Firestore document reference.

    Holds a reference to the parent collection's dict so writes persist.
    """

    def __init__(
        self,
        collection_dict: dict[str, dict],
        doc_id: str = "test-doc",
    ):
        self._collection = collection_dict
        self._id = doc_id

    async def get(self):
        data = self._collection.get(self._id)
        return MockDocumentSnapshot(data, self._id)

    async def set(self, data: dict, merge: bool = False):
        if merge and self._id in self._collection:
            self._collection[self._id].update(data)
        else:
            self._collection[self._id] = data

    async def update(self, data: dict):
        """Update fields in existing document. Handles Increment and ArrayUnion sentinels."""
        from google.cloud.firestore_v1.transforms import _NumericValue, _ValueList

        if self._id not in self._collection:
            raise ValueError(f"Document {self._id} does not exist")
        for key, value in data.items():
            if isinstance(value, _NumericValue):
                # Handle Increment/Minimum/Maximum sentinels
                current = self._collection[self._id].get(key, 0)
                self._collection[self._id][key] = current + value.value
            elif isinstance(value, _ValueList):
                # Handle ArrayUnion/ArrayRemove sentinels
                current = self._collection[self._id].get(key, [])
                for item in value.values:
                    if item not in current:
                        current.append(item)
                self._collection[self._id][key] = current
            else:
                self._collection[self._id][key] = value

    async def delete(self):
        """Delete document from collection."""
        self._collection.pop(self._id, None)


class MockCollectionRef:
    """Mock a Firestore collection reference."""

    def __init__(self, docs: dict[str, dict] | None = None):
        self._docs = docs if docs is not None else {}

    def document(self, doc_id: str) -> MockDocumentRef:
        return MockDocumentRef(self._docs, doc_id)

    def where(self, **kwargs):
        query_docs = [
            MockDocumentSnapshot(data, doc_id)
            for doc_id, data in self._docs.items()
        ]
        return MockQuery(query_docs)

    def limit(self, n: int):
        return self.where()

    def stream(self):
        return MockQueryStream([
            MockDocumentSnapshot(data, doc_id)
            for doc_id, data in self._docs.items()
        ])


class MockFirestoreDB:
    """Mock Firestore AsyncClient with data storage."""

    def __init__(self):
        self._collections: dict[str, dict[str, dict]] = {}

    def collection(self, name: str) -> MockCollectionRef:
        if name not in self._collections:
            self._collections[name] = {}
        return MockCollectionRef(self._collections[name])

    def seed(self, collection: str, doc_id: str, data: dict):
        """Seed test data into a collection."""
        if collection not in self._collections:
            self._collections[collection] = {}
        self._collections[collection][doc_id] = data


# --- Fixtures ---


@pytest.fixture
def mock_db():
    """Mock Firestore AsyncClient with in-memory storage."""
    return MockFirestoreDB()


@pytest.fixture
def mock_user_profile():
    """Sample user profile data."""
    return {
        "uid": "test-uid-123",
        "display_name": "Maksym",
        "email": "test@example.com",
        "level": 0,
        "xp": 0,
        "phase": "phase0",
        "current_day": 1,
        "streak_days": 0,
        "shields": 0,
        "weekly_completed_days": [],
        "pause_mode": False,
        "telegram_chat_id": None,
        "mood_today": None,
        "created_at": datetime(2026, 2, 26),
        "updated_at": datetime(2026, 2, 26),
    }


@pytest.fixture
def mock_exercise():
    """Sample exercise data."""
    return {
        "id": "c00_ex00_ft_putchar",
        "module": "c00",
        "phase": "phase2",
        "title": "ft_putchar",
        "difficulty": 1,
        "xp": 20,
        "estimated_minutes": 15,
        "prerequisites": [],
        "tags": ["c", "write", "basics"],
        "norminette": True,
        "man_pages": ["write"],
        "multi_day": False,
        "content_md": "# ft_putchar\n\nWrite a function...",
        "order": 1,
    }


@pytest.fixture
def mock_exercise_progress():
    """Sample exercise progress data."""
    return {
        "uid": "test-uid-123",
        "exercise_id": "c00_ex00_ft_putchar",
        "status": "completed",
        "attempts": 1,
        "hints_used": 0,
        "xp_earned": 35,
        "hash_code": "abcd1234",
        "first_attempt_pass": True,
        "started_at": datetime(2026, 2, 26, 10, 0),
        "completed_at": datetime(2026, 2, 26, 10, 15),
        "updated_at": datetime(2026, 2, 26, 10, 15),
    }


@pytest.fixture
def seeded_db(mock_db, mock_user_profile, mock_exercise):
    """Firestore mock pre-seeded with user and exercise."""
    mock_db.seed("users", "test-uid-123", mock_user_profile)
    mock_db.seed("exercises", "c00_ex00_ft_putchar", mock_exercise)
    return mock_db


TEST_UID = "test-uid-123"
