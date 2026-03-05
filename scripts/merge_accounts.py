#!/usr/bin/env python3
"""One-time script: merge duplicate user account into canonical.

Canonical: m9su3quQGNaytWVj5rQjcYb1feF2 (Feb 26, xp=190)
Duplicate: Ch2MRztqtBbtbqVrcukc6wPbnCh1 (Mar 4, xp=80)

Uses Firestore REST API with gcloud auth token (ADC not required).

Usage:
    python scripts/merge_accounts.py          # Dry run
    python scripts/merge_accounts.py --live   # Execute merge
"""

import json
import subprocess
import sys

PROJECT = "launchpad42-prod"
BASE = f"https://firestore.googleapis.com/v1/projects/{PROJECT}/databases/(default)/documents"

CANONICAL_UID = "m9su3quQGNaytWVj5rQjcYb1feF2"
DUPLICATE_UID = "Ch2MRztqtBbtbqVrcukc6wPbnCh1"
STUDENT_CHAT_ID = 630005842


def get_token() -> str:
    result = subprocess.run(
        ["gcloud", "auth", "print-access-token"],
        capture_output=True, text=True, check=True,
    )
    return result.stdout.strip()


def api_get(token: str, path: str) -> dict:
    import urllib.request
    req = urllib.request.Request(
        f"{BASE}/{path}",
        headers={"Authorization": f"Bearer {token}"},
    )
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read())


def api_list(token: str, collection: str) -> list[dict]:
    import urllib.request
    docs = []
    url = f"{BASE}/{collection}?pageSize=100"
    while url:
        req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read())
        docs.extend(data.get("documents", []))
        next_token = data.get("nextPageToken")
        url = f"{BASE}/{collection}?pageSize=100&pageToken={next_token}" if next_token else None
    return docs


def api_patch(token: str, path: str, fields: dict, update_mask: list[str]) -> None:
    import urllib.request
    body = {"fields": fields}
    mask = "&".join(f"updateMask.fieldPaths={f}" for f in update_mask)
    url = f"{BASE}/{path}?{mask}"
    data = json.dumps(body).encode()
    req = urllib.request.Request(
        url, data=data, method="PATCH",
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
    )
    urllib.request.urlopen(req)


def api_create(token: str, collection: str, doc_id: str, fields: dict) -> None:
    import urllib.request
    body = {"fields": fields}
    url = f"{BASE}/{collection}?documentId={doc_id}"
    data = json.dumps(body).encode()
    req = urllib.request.Request(
        url, data=data, method="POST",
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
    )
    urllib.request.urlopen(req)


def api_delete(token: str, path: str) -> None:
    import urllib.request
    req = urllib.request.Request(
        f"{BASE}/{path}", method="DELETE",
        headers={"Authorization": f"Bearer {token}"},
    )
    urllib.request.urlopen(req)


def extract_value(field: dict):
    """Extract Python value from Firestore REST field."""
    if "integerValue" in field:
        return int(field["integerValue"])
    if "stringValue" in field:
        return field["stringValue"]
    if "booleanValue" in field:
        return field["booleanValue"]
    if "nullValue" in field:
        return None
    if "arrayValue" in field:
        return [extract_value(v) for v in field["arrayValue"].get("values", [])]
    if "timestampValue" in field:
        return field["timestampValue"]
    return None


def to_firestore_fields(data: dict) -> dict:
    """Convert Python dict to Firestore REST fields format."""
    fields = {}
    for k, v in data.items():
        if v is None:
            fields[k] = {"nullValue": None}
        elif isinstance(v, bool):
            fields[k] = {"booleanValue": v}
        elif isinstance(v, int):
            fields[k] = {"integerValue": str(v)}
        elif isinstance(v, str):
            fields[k] = {"stringValue": v}
        elif isinstance(v, list):
            if v:
                fields[k] = {"arrayValue": {"values": [
                    {"stringValue": str(item)} for item in v
                ]}}
            else:
                fields[k] = {"arrayValue": {}}
    return fields


def main(dry_run: bool = True) -> None:
    print(f"Mode: {'DRY RUN' if dry_run else 'LIVE'}")
    token = get_token()

    # 1. Read both users
    canonical_raw = api_get(token, f"users/{CANONICAL_UID}")
    duplicate_raw = api_get(token, f"users/{DUPLICATE_UID}")

    canonical_xp = int(canonical_raw["fields"]["xp"]["integerValue"])
    duplicate_xp = int(duplicate_raw["fields"]["xp"]["integerValue"])
    print(f"Canonical XP: {canonical_xp}")
    print(f"Duplicate XP: {duplicate_xp}")

    # 2. Exercise progress
    all_ep = api_list(token, "exercise_progress")
    dup_ep = [d for d in all_ep if d["name"].split("/")[-1].startswith(DUPLICATE_UID)]
    can_ep_ids = {d["name"].split("/")[-1] for d in all_ep if d["name"].split("/")[-1].startswith(CANONICAL_UID)}

    print(f"\nDuplicate exercise_progress: {len(dup_ep)}")
    xp_to_add = 0
    for doc in dup_ep:
        doc_id = doc["name"].split("/")[-1]
        fields = doc["fields"]
        exercise_id = fields["exercise_id"]["stringValue"]
        xp = int(fields.get("xp_earned", {}).get("integerValue", "0"))
        canonical_ep_id = f"{CANONICAL_UID}_{exercise_id}"

        if canonical_ep_id in can_ep_ids:
            print(f"  {exercise_id}: SKIP (already in canonical)")
        else:
            print(f"  {exercise_id}: MIGRATE (+{xp} XP)")
            xp_to_add += xp

            if not dry_run:
                # Create new doc under canonical UID
                new_fields = dict(fields)
                new_fields["uid"] = {"stringValue": CANONICAL_UID}
                api_create(token, "exercise_progress", canonical_ep_id, new_fields)

        if not dry_run:
            api_delete(token, f"exercise_progress/{doc_id}")

    # 3. Sessions
    all_sessions = api_list(token, "sessions")
    dup_sessions = [d for d in all_sessions if d["name"].split("/")[-1].startswith(DUPLICATE_UID)]
    can_session_ids = {d["name"].split("/")[-1] for d in all_sessions if d["name"].split("/")[-1].startswith(CANONICAL_UID)}

    print(f"\nDuplicate sessions: {len(dup_sessions)}")
    new_weekly_dates = []
    for doc in dup_sessions:
        doc_id = doc["name"].split("/")[-1]
        fields = doc["fields"]
        date_str = fields["date"]["stringValue"]
        new_doc_id = f"{CANONICAL_UID}_{date_str}"
        new_weekly_dates.append(date_str)

        if new_doc_id in can_session_ids:
            print(f"  {date_str}: MERGE into existing canonical session")
            if not dry_run:
                # Read canonical session, merge exercises and XP
                can_session = api_get(token, f"sessions/{new_doc_id}")
                can_fields = can_session["fields"]
                can_exercises = [v["stringValue"] for v in
                                 can_fields.get("exercises_completed", {}).get("arrayValue", {}).get("values", [])]
                dup_exercises = [v["stringValue"] for v in
                                 fields.get("exercises_completed", {}).get("arrayValue", {}).get("values", [])]
                merged = list(set(can_exercises + dup_exercises))
                can_xp = int(can_fields.get("xp_earned", {}).get("integerValue", "0"))
                dup_xp = int(fields.get("xp_earned", {}).get("integerValue", "0"))
                update = to_firestore_fields({
                    "exercises_completed": merged,
                    "xp_earned": can_xp + dup_xp,
                })
                api_patch(token, f"sessions/{new_doc_id}", update,
                          ["exercises_completed", "xp_earned"])
        else:
            print(f"  {date_str}: MOVE to canonical")
            if not dry_run:
                new_fields = dict(fields)
                new_fields["uid"] = {"stringValue": CANONICAL_UID}
                api_create(token, "sessions", new_doc_id, new_fields)

        if not dry_run:
            api_delete(token, f"sessions/{doc_id}")

    # 4. Achievements
    all_ach = api_list(token, "achievements")
    dup_ach = [d for d in all_ach if d["name"].split("/")[-1].startswith(DUPLICATE_UID)]

    can_ach_ids = {d["name"].split("/")[-1] for d in all_ach if d["name"].split("/")[-1].startswith(CANONICAL_UID)}

    print(f"\nDuplicate achievements: {len(dup_ach)}")
    for doc in dup_ach:
        doc_id = doc["name"].split("/")[-1]
        ach_id = doc["fields"]["achievement_id"]["stringValue"]
        canonical_ach_id = f"{CANONICAL_UID}_{ach_id}"

        if canonical_ach_id in can_ach_ids:
            print(f"  {ach_id}: DELETE duplicate (canonical already has it)")
        else:
            print(f"  {ach_id}: MOVE to canonical (missing from canonical)")
            if not dry_run:
                new_fields = dict(doc["fields"])
                new_fields["uid"] = {"stringValue": CANONICAL_UID}
                api_create(token, "achievements", canonical_ach_id, new_fields)

        if not dry_run:
            api_delete(token, f"achievements/{doc_id}")

    # 5. Update canonical user
    new_xp = canonical_xp + xp_to_add
    existing_weekly = extract_value(canonical_raw["fields"].get("weekly_completed_days", {"arrayValue": {}})) or []
    merged_weekly = list(set(existing_weekly + new_weekly_dates))

    print(f"\nCanonical user update:")
    print(f"  XP: {canonical_xp} + {xp_to_add} = {new_xp}")
    print(f"  telegram_chat_id: null -> {STUDENT_CHAT_ID}")
    print(f"  weekly_completed_days: {merged_weekly}")

    if not dry_run:
        update_fields = to_firestore_fields({
            "xp": new_xp,
            "telegram_chat_id": STUDENT_CHAT_ID,
            "weekly_completed_days": merged_weekly,
        })
        api_patch(token, f"users/{CANONICAL_UID}", update_fields,
                  ["xp", "telegram_chat_id", "weekly_completed_days"])

    # 6. Delete duplicate user
    print(f"\nDelete duplicate user: {DUPLICATE_UID}")
    if not dry_run:
        api_delete(token, f"users/{DUPLICATE_UID}")

    print(f"\n{'DRY RUN complete.' if dry_run else 'MIGRATION COMPLETE.'}")


if __name__ == "__main__":
    live = "--live" in sys.argv
    main(dry_run=not live)
