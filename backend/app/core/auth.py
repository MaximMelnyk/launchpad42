"""Firebase Auth dependency for FastAPI."""

import asyncio
from functools import partial

import structlog
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from firebase_admin import auth

from app.core.firebase import get_db

logger = structlog.get_logger()
security = HTTPBearer()


async def verify_firebase_token(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> dict:
    """Verify Firebase ID token and return decoded claims.

    firebase_admin.auth.verify_id_token is synchronous,
    so we run it in executor to avoid blocking the event loop.
    """
    token = credentials.credentials
    try:
        loop = asyncio.get_event_loop()
        decoded = await loop.run_in_executor(
            None, partial(auth.verify_id_token, token, check_revoked=True)
        )
        return decoded
    except auth.RevokedIdTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Firebase ID token has been revoked",
        )
    except auth.InvalidIdTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Firebase ID token",
        )
    except auth.ExpiredIdTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Firebase ID token expired",
        )
    except auth.CertificateFetchError:
        logger.error("Failed to fetch Firebase auth certificates")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Authentication service temporarily unavailable",
        )
    except Exception:
        logger.exception("Unexpected error during token verification")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal authentication error",
        )


def get_uid(token: dict = Depends(verify_firebase_token)) -> str:
    """Extract uid from verified token."""
    return token["uid"]


async def require_registered_user(
    uid: str = Depends(get_uid),
    db=Depends(get_db),
) -> str:
    """Verify UID has an existing user doc. Blocks wrong Google accounts.

    Use this for all endpoints except GET /auth/profile (which auto-creates).
    Allows through if no users exist yet (first login race with profile creation).
    """
    doc = await db.collection("users").document(uid).get()
    if doc.exists:
        return uid

    # No user doc for this UID — check if ANY user exists
    async for existing_doc in db.collection("users").limit(1).stream():
        if existing_doc.id == uid:
            # TOCTOU: profile endpoint created our doc between reads
            return uid
        # Another user exists but not this UID — wrong account
        logger.warning("Blocked unregistered UID", uid=uid)
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="wrong_account",
        )

    # No users exist at all — first login, profile being created in parallel
    return uid
