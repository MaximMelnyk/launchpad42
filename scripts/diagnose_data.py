"""Diagnostic script — inspect Firestore data for weekly report bug."""

import asyncio
from datetime import date, timedelta

from google.cloud.firestore_v1 import AsyncClient


async def main():
    db = AsyncClient(project="launchpad42-prod")

    # 1. List ALL user documents
    print("=== ALL USERS ===")
    async for doc in db.collection("users").stream():
        data = doc.to_dict()
        print(f"  UID: {doc.id}")
        print(f"    xp: {data.get('xp')}")
        print(f"    level: {data.get('level')}")
        print(f"    phase: {data.get('phase')}")
        print(f"    telegram_chat_id: {data.get('telegram_chat_id')}")
        print(f"    display_name: {data.get('display_name')}")
        print(f"    streak_days: {data.get('streak_days')}")
        print(f"    created_at: {data.get('created_at')}")
        print(f"    updated_at: {data.get('updated_at')}")
        print()

    # 2. List ALL telegram_links
    print("=== ALL TELEGRAM_LINKS ===")
    async for doc in db.collection("telegram_links").stream():
        data = doc.to_dict()
        print(f"  Doc ID: {doc.id}")
        print(f"    chat_id: {data.get('chat_id')}")
        print(f"    role: {data.get('role')}")
        print(f"    display_name: {data.get('display_name')}")
        print()

    # 3. List sessions for the past 2 weeks
    print("=== ALL SESSIONS (last 14 days) ===")
    async for doc in db.collection("sessions").stream():
        data = doc.to_dict()
        print(f"  Doc ID: {doc.id}")
        print(f"    uid: {data.get('uid')}")
        print(f"    date: {data.get('date')}")
        print(f"    xp_earned: {data.get('xp_earned')}")
        print(f"    exercises_completed: {data.get('exercises_completed')}")
        print(f"    mood_start: {data.get('mood_start')}")
        print(f"    started_at: {data.get('started_at')}")
        print(f"    finished_at: {data.get('finished_at')}")
        print()

    # 4. List exercise_progress (completed only)
    print("=== EXERCISE PROGRESS (completed) ===")
    async for doc in db.collection("exercise_progress").stream():
        data = doc.to_dict()
        if data.get("status") == "completed":
            print(f"  Doc ID: {doc.id}")
            print(f"    exercise_id: {data.get('exercise_id')}")
            print(f"    xp_earned: {data.get('xp_earned')}")
            print(f"    completed_at: {data.get('completed_at')}")
            print()

    # 5. Simulate _get_student_uid
    print("=== _get_student_uid SIMULATION ===")
    from google.cloud.firestore_v1.base_query import FieldFilter
    query = db.collection("telegram_links").where(
        filter=FieldFilter("role", "==", "student")
    )
    found_uid = None
    async for doc in query.stream():
        data = doc.to_dict()
        chat_id = data.get("chat_id")
        print(f"  Student telegram_link: doc={doc.id}, chat_id={chat_id}")
        users_query = db.collection("users").where(
            filter=FieldFilter("telegram_chat_id", "==", chat_id)
        )
        async for user_doc in users_query.stream():
            found_uid = user_doc.id
            print(f"  -> Found user by telegram_chat_id: {user_doc.id}")
            break

    if not found_uid:
        print("  -> No user found by telegram_chat_id, using fallback limit(1)")
        async for user_doc in db.collection("users").limit(1).stream():
            print(f"  -> Fallback user: {user_doc.id}")


asyncio.run(main())
