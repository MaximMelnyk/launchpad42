"""Firebase Auth dependency for FastAPI."""

import asyncio
from functools import partial

import structlog
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from firebase_admin import auth

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
