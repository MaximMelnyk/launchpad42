#!/usr/bin/env python3
"""Seed Firestore with content from content/ directory.

Parses exercise Markdown files (YAML frontmatter), vocab YAML, and review
card YAML, then upserts each document into the corresponding Firestore
collection using set(merge=True) for idempotency.

Usage:
    python scripts/seed.py                          # Seed all
    python scripts/seed.py --phase phase0           # Seed specific phase
    python scripts/seed.py --collection exercises   # Seed specific collection
    python scripts/seed.py --collection vocab
    python scripts/seed.py --collection review_cards
    python scripts/seed.py --dry-run                # Preview without writing
"""

from __future__ import annotations

import argparse
import logging
import sys
from pathlib import Path
from typing import Any

import frontmatter
import yaml

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)-7s | %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("seed")

# Resolve project root relative to this script's location
PROJECT_ROOT = Path(__file__).resolve().parent.parent
CONTENT_DIR = PROJECT_ROOT / "content"

# Valid collection names for CLI validation
VALID_COLLECTIONS = ("all", "exercises", "vocab", "review_cards")


# ---------------------------------------------------------------------------
# Firebase initialization
# ---------------------------------------------------------------------------

def init_firestore(project_id: str):
    """Initialize Firebase Admin SDK and return sync Firestore client.

    Uses Application Default Credentials (ADC) locally.
    Set GOOGLE_APPLICATION_CREDENTIALS env var to a service account key
    if not running on GCP.
    """
    import firebase_admin
    from firebase_admin import credentials, firestore

    if not firebase_admin._apps:
        cred = credentials.ApplicationDefault()
        firebase_admin.initialize_app(cred, {"projectId": project_id})

    return firestore.client()


# ---------------------------------------------------------------------------
# Parsers
# ---------------------------------------------------------------------------

def parse_exercise(filepath: Path) -> dict[str, Any]:
    """Parse a Markdown exercise file with YAML frontmatter.

    Returns a dict suitable for Firestore upsert containing all
    frontmatter fields plus ``content_md`` with the Markdown body.
    """
    post = frontmatter.load(str(filepath))
    metadata = dict(post.metadata)

    if "id" not in metadata:
        raise ValueError(f"Exercise file missing 'id' in frontmatter: {filepath}")

    metadata["content_md"] = post.content
    return metadata


def parse_yaml_file(filepath: Path) -> list[dict[str, Any]]:
    """Parse a YAML file containing a list of documents.

    Each document must have an ``id`` field used as the Firestore doc ID.
    """
    with open(filepath, encoding="utf-8") as f:
        data = yaml.safe_load(f)

    if not isinstance(data, list):
        raise ValueError(f"Expected a YAML list in {filepath}, got {type(data).__name__}")

    for i, entry in enumerate(data):
        if "id" not in entry:
            raise ValueError(f"Entry {i} in {filepath} missing 'id' field")

    return data


# ---------------------------------------------------------------------------
# Seeders
# ---------------------------------------------------------------------------

def seed_exercises(
    db,
    phase: str | None = None,
    dry_run: bool = False,
) -> dict[str, int]:
    """Seed exercises collection from content/exercises/ markdown files."""
    exercises_dir = CONTENT_DIR / "exercises"
    if not exercises_dir.exists():
        log.warning("Exercises directory not found: %s", exercises_dir)
        return {"seeded": 0, "skipped": 0, "errors": 0}

    # Determine which phase directories to scan
    if phase:
        phase_dirs = [exercises_dir / phase]
        if not phase_dirs[0].exists():
            log.warning("Phase directory not found: %s", phase_dirs[0])
            return {"seeded": 0, "skipped": 0, "errors": 0}
    else:
        phase_dirs = sorted(
            p for p in exercises_dir.iterdir()
            if p.is_dir() and not p.name.startswith(".")
        )

    stats = {"seeded": 0, "skipped": 0, "errors": 0}
    collection = db.collection("exercises")

    for phase_dir in phase_dirs:
        md_files = sorted(phase_dir.glob("*.md"))
        if not md_files:
            log.info("No exercise files in %s", phase_dir.name)
            continue

        for filepath in md_files:
            try:
                data = parse_exercise(filepath)
                doc_id = data["id"]

                if dry_run:
                    log.info("[DRY RUN] Would seed exercise: %s (%s)", doc_id, data.get("title", ""))
                    stats["seeded"] += 1
                    continue

                collection.document(doc_id).set(data, merge=True)
                log.info("Seeded exercise: %s (%s)", doc_id, data.get("title", ""))
                stats["seeded"] += 1

            except Exception:
                log.exception("Error seeding exercise from %s", filepath)
                stats["errors"] += 1

    return stats


def seed_vocab(
    db,
    phase: str | None = None,
    dry_run: bool = False,
) -> dict[str, int]:
    """Seed vocab collection from content/vocab/ YAML files."""
    vocab_dir = CONTENT_DIR / "vocab"
    if not vocab_dir.exists():
        log.warning("Vocab directory not found: %s", vocab_dir)
        return {"seeded": 0, "skipped": 0, "errors": 0}

    # Determine which files to process
    if phase:
        yaml_files = [vocab_dir / f"{phase}.yaml"]
        if not yaml_files[0].exists():
            # Try .yml extension as fallback
            yaml_files = [vocab_dir / f"{phase}.yml"]
            if not yaml_files[0].exists():
                log.warning("Vocab file not found for phase: %s", phase)
                return {"seeded": 0, "skipped": 0, "errors": 0}
    else:
        yaml_files = sorted(
            f for f in vocab_dir.iterdir()
            if f.suffix in (".yaml", ".yml") and not f.name.startswith(".")
        )

    stats = {"seeded": 0, "skipped": 0, "errors": 0}
    collection = db.collection("vocab")

    for filepath in yaml_files:
        if not filepath.exists():
            log.warning("Vocab file not found: %s", filepath)
            continue

        try:
            entries = parse_yaml_file(filepath)
        except Exception:
            log.exception("Error parsing vocab file %s", filepath)
            stats["errors"] += 1
            continue

        for entry in entries:
            try:
                doc_id = entry["id"]

                # Filter by phase if specified and entry has phase field
                if phase and entry.get("phase") and entry["phase"] != phase:
                    stats["skipped"] += 1
                    continue

                if dry_run:
                    log.info("[DRY RUN] Would seed vocab: %s (%s)", doc_id, entry.get("term_fr", ""))
                    stats["seeded"] += 1
                    continue

                collection.document(doc_id).set(entry, merge=True)
                log.info("Seeded vocab: %s (%s)", doc_id, entry.get("term_fr", ""))
                stats["seeded"] += 1

            except Exception:
                log.exception("Error seeding vocab entry %s", entry.get("id", "unknown"))
                stats["errors"] += 1

    return stats


def seed_review_cards(
    db,
    phase: str | None = None,
    dry_run: bool = False,
) -> dict[str, int]:
    """Seed review_cards collection from content/review_cards/ YAML files."""
    cards_dir = CONTENT_DIR / "review_cards"
    if not cards_dir.exists():
        log.warning("Review cards directory not found: %s", cards_dir)
        return {"seeded": 0, "skipped": 0, "errors": 0}

    # Determine which files to process
    if phase:
        yaml_files = [cards_dir / f"{phase}.yaml"]
        if not yaml_files[0].exists():
            yaml_files = [cards_dir / f"{phase}.yml"]
            if not yaml_files[0].exists():
                log.warning("Review cards file not found for phase: %s", phase)
                return {"seeded": 0, "skipped": 0, "errors": 0}
    else:
        yaml_files = sorted(
            f for f in cards_dir.iterdir()
            if f.suffix in (".yaml", ".yml") and not f.name.startswith(".")
        )

    stats = {"seeded": 0, "skipped": 0, "errors": 0}
    collection = db.collection("review_cards")

    for filepath in yaml_files:
        if not filepath.exists():
            log.warning("Review cards file not found: %s", filepath)
            continue

        try:
            entries = parse_yaml_file(filepath)
        except Exception:
            log.exception("Error parsing review cards file %s", filepath)
            stats["errors"] += 1
            continue

        for entry in entries:
            try:
                doc_id = entry["id"]

                if phase and entry.get("phase") and entry["phase"] != phase:
                    stats["skipped"] += 1
                    continue

                if dry_run:
                    log.info("[DRY RUN] Would seed review card: %s", doc_id)
                    stats["seeded"] += 1
                    continue

                collection.document(doc_id).set(entry, merge=True)
                log.info("Seeded review card: %s", doc_id)
                stats["seeded"] += 1

            except Exception:
                log.exception("Error seeding review card %s", entry.get("id", "unknown"))
                stats["errors"] += 1

    return stats


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Seed Firestore with content from content/ directory.",
    )
    parser.add_argument(
        "--phase",
        type=str,
        default=None,
        help="Seed only a specific phase (e.g. phase0, phase1).",
    )
    parser.add_argument(
        "--collection",
        type=str,
        default="all",
        choices=VALID_COLLECTIONS,
        help="Seed a specific collection (default: all).",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview what would be seeded without writing to Firestore.",
    )
    parser.add_argument(
        "--project-id",
        type=str,
        default="launchpad42-prod",
        help="GCP project ID (default: launchpad42-prod).",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    log.info("=" * 60)
    log.info("42 LaunchPad Content Seeder")
    log.info("Project: %s", args.project_id)
    log.info("Content dir: %s", CONTENT_DIR)
    log.info("Phase filter: %s", args.phase or "all")
    log.info("Collection: %s", args.collection)
    log.info("Dry run: %s", args.dry_run)
    log.info("=" * 60)

    if not CONTENT_DIR.exists():
        log.error("Content directory not found: %s", CONTENT_DIR)
        return 1

    # Initialize Firestore (skip for dry run if no credentials available)
    db = None
    if not args.dry_run:
        try:
            db = init_firestore(args.project_id)
            log.info("Firestore client initialized")
        except Exception:
            log.exception("Failed to initialize Firestore")
            return 1
    else:
        log.info("[DRY RUN] Skipping Firestore initialization")

    results: dict[str, dict[str, int]] = {}
    total_errors = 0

    # Seed exercises
    if args.collection in ("all", "exercises"):
        log.info("-" * 40)
        log.info("Seeding exercises...")
        stats = seed_exercises(db, phase=args.phase, dry_run=args.dry_run)
        results["exercises"] = stats
        total_errors += stats["errors"]

    # Seed vocab
    if args.collection in ("all", "vocab"):
        log.info("-" * 40)
        log.info("Seeding vocab...")
        stats = seed_vocab(db, phase=args.phase, dry_run=args.dry_run)
        results["vocab"] = stats
        total_errors += stats["errors"]

    # Seed review cards
    if args.collection in ("all", "review_cards"):
        log.info("-" * 40)
        log.info("Seeding review cards...")
        stats = seed_review_cards(db, phase=args.phase, dry_run=args.dry_run)
        results["review_cards"] = stats
        total_errors += stats["errors"]

    # Summary
    log.info("=" * 60)
    log.info("SEED SUMMARY")
    log.info("=" * 60)
    for collection_name, stats in results.items():
        log.info(
            "  %-15s  seeded: %3d  skipped: %3d  errors: %3d",
            collection_name,
            stats["seeded"],
            stats["skipped"],
            stats["errors"],
        )

    grand_seeded = sum(s["seeded"] for s in results.values())
    grand_skipped = sum(s["skipped"] for s in results.values())
    log.info("-" * 60)
    log.info(
        "  %-15s  seeded: %3d  skipped: %3d  errors: %3d",
        "TOTAL",
        grand_seeded,
        grand_skipped,
        total_errors,
    )
    log.info("=" * 60)

    if total_errors > 0:
        log.warning("Completed with %d error(s)", total_errors)
        return 1

    log.info("Done!")
    return 0


if __name__ == "__main__":
    sys.exit(main())
