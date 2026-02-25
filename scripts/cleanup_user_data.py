#!/usr/bin/env python3
"""Clean up all user-generated data from Firestore.

Deletes documents from collections that contain user activity
(progress, sessions, tutor history, achievements, etc.) while
preserving seeded content (exercises, review_cards, vocab).

Usage:
    python scripts/cleanup_user_data.py              # Dry run (default)
    python scripts/cleanup_user_data.py --confirm     # Actually delete
    python scripts/cleanup_user_data.py --project ID  # Custom project ID
"""

from __future__ import annotations

import argparse
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-7s | %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("cleanup")

# Collections with user-generated data (safe to wipe)
USER_COLLECTIONS = [
    "tutor_history",
    "tutor_usage",
    "exercise_progress",
    "sessions",
    "achievements",
    "drill_pool",
    "exams",
    "users",
    "telegram_rate_limit",
]

# Preserved user collections — keep linked Telegram accounts
PRESERVED_USER_COLLECTIONS = ["telegram_links"]

# Content collections — NEVER delete
CONTENT_COLLECTIONS = ["exercises", "review_cards", "vocab"]

DEFAULT_PROJECT = "launchpad42-prod"


def init_firestore(project_id: str):
    """Initialize Firebase Admin SDK and return sync Firestore client."""
    import firebase_admin
    from firebase_admin import credentials, firestore

    if not firebase_admin._apps:
        cred = credentials.ApplicationDefault()
        firebase_admin.initialize_app(cred, {"projectId": project_id})

    return firestore.client()


def delete_collection(db, collection_name: str, dry_run: bool) -> int:
    """Delete all documents in a collection. Returns count deleted."""
    coll_ref = db.collection(collection_name)
    docs = list(coll_ref.stream())
    count = len(docs)

    if count == 0:
        log.info("  %s: empty, skipping", collection_name)
        return 0

    if dry_run:
        log.info("  %s: %d docs (dry run, not deleting)", collection_name, count)
        for doc in docs[:5]:
            log.info("    - %s", doc.id)
        if count > 5:
            log.info("    ... and %d more", count - 5)
        return count

    batch = db.batch()
    for doc in docs:
        batch.delete(doc.reference)
    batch.commit()
    log.info("  %s: %d docs deleted", collection_name, count)
    return count


def main():
    parser = argparse.ArgumentParser(description="Clean up user data from Firestore")
    parser.add_argument(
        "--confirm",
        action="store_true",
        help="Actually delete (default is dry run)",
    )
    parser.add_argument(
        "--project",
        default=DEFAULT_PROJECT,
        help=f"GCP project ID (default: {DEFAULT_PROJECT})",
    )
    args = parser.parse_args()

    dry_run = not args.confirm

    if dry_run:
        log.info("=== DRY RUN (add --confirm to actually delete) ===")
    else:
        log.info("=== DELETING user data from %s ===", args.project)

    db = init_firestore(args.project)

    total = 0
    for collection in USER_COLLECTIONS:
        total += delete_collection(db, collection, dry_run)

    log.info("")
    log.info("Content collections (preserved): %s", ", ".join(CONTENT_COLLECTIONS))
    log.info("User collections (preserved): %s", ", ".join(PRESERVED_USER_COLLECTIONS))
    log.info("Total documents %s: %d", "found" if dry_run else "deleted", total)

    if dry_run and total > 0:
        log.info("")
        log.info("Run with --confirm to delete these documents.")


if __name__ == "__main__":
    main()
