"""Firebase Admin SDK initialization with async Firestore client."""

import firebase_admin
from firebase_admin import credentials
from google.cloud.firestore_v1 import AsyncClient

# Module-level reference, initialized in lifespan
db: AsyncClient | None = None


def init_firebase(project_id: str = "launchpad42-prod") -> AsyncClient:
    """Initialize Firebase Admin SDK and return async Firestore client.

    Called once during app lifespan startup.
    Uses Application Default Credentials (ADC) on Cloud Run,
    or GOOGLE_APPLICATION_CREDENTIALS locally.
    """
    global db

    if not firebase_admin._apps:
        cred = credentials.ApplicationDefault()
        firebase_admin.initialize_app(cred, {"projectId": project_id})

    db = AsyncClient(project=project_id)
    return db


def get_db() -> AsyncClient:
    """FastAPI dependency to get Firestore async client."""
    if db is None:
        raise RuntimeError("Firestore not initialized. Call init_firebase() first.")
    return db
