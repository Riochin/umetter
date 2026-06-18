"""
Seed script: posts and friendships placeholder data.
Usage: python scripts/seed_posts_friends.py
"""

import sqlite3
import uuid
import os
import sys
from datetime import datetime, timedelta

DB_PATH = os.path.join(os.path.dirname(__file__), "..", "umetter.db")

# bcrypt hash for "password123"
PASSWORD_HASH = "$2a$10$EliJiiqCwIKuAVQOptUREudXiOAofZpGHQ/eh3e2CPc2zn7LcKm/m"

# ─────────────────────────────────────────
# Seed users (Tsuda-format emails)
# format: [dept][YY][NNN][initials]@gm.tsuda.ac.jp
# ─────────────────────────────────────────
SEED_USERS = [
    {
        "email": "g24102sm@gm.tsuda.ac.jp",
        "department": "g",
        "admission_year": 2024,
        "display_name": "佐藤 美穂",
        "role": "student",
        "timetable_visibility": "all",
    },
    {
        "email": "g23201yk@gm.tsuda.ac.jp",
        "department": "g",
        "admission_year": 2023,
        "display_name": "田中 優花",
        "role": "student",
        "timetable_visibility": "friends",
    },
    {
        "email": "g25301ak@gm.tsuda.ac.jp",
        "department": "g",
        "admission_year": 2025,
        "display_name": "小林 あおい",
        "role": "student",
        "timetable_visibility": "all",
    },
    {
        "email": "cs24401nn@gm.tsuda.ac.jp",
        "department": "cs",
        "admission_year": 2024,
        "display_name": "中村 菜々",
        "role": "student",
        "timetable_visibility": "all",
    },
    {
        "email": "cs23501hr@gm.tsuda.ac.jp",
        "department": "cs",
        "admission_year": 2023,
        "display_name": "松本 ひかる",
        "role": "student",
        "timetable_visibility": "juniors",
    },
]

# ─────────────────────────────────────────
# Posts
# ─────────────────────────────────────────
def make_posts(user_ids: list[str]) -> list[dict]:
    """user_ids[0] is the target user (g24915ir), rest are seed users"""
    now = datetime.utcnow()
    def ts(minutes_ago: int) -> str:
        return (now - timedelta(minutes=minutes_ago)).strftime("%Y-%m-%dT%H:%M:%SZ")

    posts = [
        # seed user posts
        {
            "author_idx": 1,
            "category": "all",
            "body": "今日から時間割登録できるようになった！みんなはもう登録した？📅",
            "is_pinned": 0,
            "created_at": ts(5),
        },
        {
            "author_idx": 2,
            "category": "all",
            "body": "情報科学の課題、DBのER図を書くやつ……これどのツール使えばいいんだろう",
            "is_pinned": 0,
            "created_at": ts(15),
        },
        {
            "author_idx": 3,
            "category": "circle",
            "body": "軽音サークルの新歓、来週の水曜！気軽に遊びに来てください🎸",
            "is_pinned": 0,
            "created_at": ts(30),
        },
        {
            "author_idx": 4,
            "category": "department",
            "body": "CS学科の人、アルゴリズムの授業のレポート提出期限って今週末だよね？",
            "is_pinned": 0,
            "created_at": ts(60),
        },
        {
            "author_idx": 1,
            "category": "all",
            "body": "図書館の4階、静かで集中できるのに誰も来ない穴場スポット✨",
            "is_pinned": 0,
            "created_at": ts(90),
        },
        {
            "author_idx": 5,
            "category": "year",
            "body": "2023年度入学の人！就活の合同説明会の情報共有しましょう〜",
            "is_pinned": 0,
            "created_at": ts(120),
        },
        {
            "author_idx": 2,
            "category": "all",
            "body": "学食のAランチ、今日はハンバーグ！朝から楽しみにしてた🍽",
            "is_pinned": 0,
            "created_at": ts(180),
        },
        {
            "author_idx": 3,
            "category": "all",
            "body": "プログラミング演習の先生、採点が早くて助かる。フィードバックも丁寧だし。",
            "is_pinned": 0,
            "created_at": ts(240),
        },
        {
            "author_idx": 4,
            "category": "faculty",
            "body": "来週の木曜、休講になりました。課題は変わらず提出してください。",
            "is_pinned": 1,
            "created_at": ts(300),
        },
        {
            "author_idx": 5,
            "category": "all",
            "body": "津田ってキャンパスこじんまりしてるけど、その分みんな顔見知りになれるの好き",
            "is_pinned": 0,
            "created_at": ts(360),
        },
        {
            "author_idx": 1,
            "category": "circle",
            "body": "写真部の展示会、来月あります！作品募集中です📷 興味ある人DM！",
            "is_pinned": 0,
            "created_at": ts(500),
        },
        {
            "author_idx": 2,
            "category": "all",
            "body": "単位互換制度使って他大の授業とってみた。新鮮すぎる",
            "is_pinned": 0,
            "created_at": ts(720),
        },
    ]
    return posts


def run():
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    # ── 1. Find the target user (the real registered user) ──
    cur.execute("SELECT id, email FROM users ORDER BY created_at ASC")
    existing_users = cur.fetchall()
    if not existing_users:
        print("ERROR: No users found in DB. Register first.")
        sys.exit(1)

    # Use the most recently registered user as the "target" user
    target_id = existing_users[-1][0]
    target_email = existing_users[-1][1]
    print(f"Target user: {target_email} ({target_id})")

    # ── 2. Insert seed users ──
    seed_ids = []
    for u in SEED_USERS:
        cur.execute("SELECT id FROM users WHERE email = ?", (u["email"],))
        row = cur.fetchone()
        if row:
            seed_ids.append(row[0])
            print(f"  skip (exists): {u['email']}")
            continue

        uid = str(uuid.uuid4())
        seed_ids.append(uid)
        cur.execute(
            """INSERT INTO users
               (id, email, password_hash, department, admission_year, display_name, role, timetable_visibility)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
            (uid, u["email"], PASSWORD_HASH, u["department"], u["admission_year"],
             u["display_name"], u["role"], u["timetable_visibility"]),
        )
        # Mark as verified so they can log in
        cur.execute(
            "INSERT OR IGNORE INTO verified_emails (email) VALUES (?)",
            (u["email"],),
        )
        print(f"  created: {u['display_name']} ({u['email']})")

    # ── 3. Insert posts ──
    all_user_ids = [target_id] + seed_ids  # index 0 = target, 1-5 = seed
    posts = make_posts(all_user_ids)
    inserted_posts = 0
    for p in posts:
        pid = str(uuid.uuid4())
        author_id = all_user_ids[p["author_idx"]]
        cur.execute(
            """INSERT OR IGNORE INTO posts
               (id, author_id, post_type, category, body, attachment_url, is_pinned, created_at)
               VALUES (?, ?, 0, ?, ?, '', ?, ?)""",
            (pid, author_id, p["category"], p["body"], p["is_pinned"], p["created_at"]),
        )
        inserted_posts += 1

    # ── 4. Insert friendships ──
    # approved: seed users 0,1 are already friends with target
    # pending:  seed users 2,3 sent requests to target
    # pending:  target sent request to seed user 4
    friendships = [
        (seed_ids[0], target_id,   "approved"),
        (seed_ids[1], target_id,   "approved"),
        (seed_ids[2], target_id,   "pending"),
        (seed_ids[3], target_id,   "pending"),
        (target_id,   seed_ids[4], "pending"),
    ]
    inserted_friends = 0
    for req_id, addr_id, status in friendships:
        fid = str(uuid.uuid4())
        try:
            cur.execute(
                """INSERT OR IGNORE INTO friendships (id, requester_id, addressee_id, status)
                   VALUES (?, ?, ?, ?)""",
                (fid, req_id, addr_id, status),
            )
            inserted_friends += 1
        except Exception as e:
            print(f"  friendship skip: {e}")

    conn.commit()
    conn.close()

    print(f"\nDone! {inserted_posts} posts, {inserted_friends} friendships inserted.")
    print("Seed user password: password123")


if __name__ == "__main__":
    run()
