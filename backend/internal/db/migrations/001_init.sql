-- 001_init.sql — うめったー initial schema
-- SQLite-compatible; Cloudflare D1 compatible (SQLite dialect)

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

-- ------------------------------------------------------------
-- users
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id                   TEXT NOT NULL PRIMARY KEY,
    email                TEXT NOT NULL UNIQUE,
    password_hash        TEXT NOT NULL,
    department           TEXT NOT NULL,
    admission_year       INTEGER NOT NULL,
    display_name         TEXT NOT NULL DEFAULT '',
    role                 TEXT NOT NULL DEFAULT 'student'
                             CHECK(role IN ('student','faculty','admin')),
    timetable_visibility TEXT NOT NULL DEFAULT 'friends'
                             CHECK(timetable_visibility IN ('private','friends','juniors','all')),
    created_at           TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
);

-- ------------------------------------------------------------
-- classes  (syllabus master, seeded separately)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS classes (
    id           TEXT    NOT NULL PRIMARY KEY,
    name         TEXT    NOT NULL,
    teacher_name TEXT    NOT NULL DEFAULT '',
    day_of_week  INTEGER NOT NULL CHECK(day_of_week BETWEEN 1 AND 6),
    period       INTEGER NOT NULL CHECK(period BETWEEN 1 AND 6),
    room         TEXT    NOT NULL DEFAULT '',
    is_canceled  INTEGER NOT NULL DEFAULT 0 CHECK(is_canceled IN (0,1))
);

-- ------------------------------------------------------------
-- user_timetables
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_timetables (
    id            TEXT    NOT NULL PRIMARY KEY,
    user_id       TEXT    NOT NULL REFERENCES users(id)   ON DELETE CASCADE,
    class_id      TEXT    NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    memo          TEXT    NOT NULL DEFAULT '',
    count_present INTEGER NOT NULL DEFAULT 0,
    count_absent  INTEGER NOT NULL DEFAULT 0,
    count_late    INTEGER NOT NULL DEFAULT 0,
    UNIQUE(user_id, class_id)
);

-- ------------------------------------------------------------
-- friendships
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS friendships (
    id           TEXT NOT NULL PRIMARY KEY,
    requester_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    addressee_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status       TEXT NOT NULL DEFAULT 'pending'
                      CHECK(status IN ('pending','approved','rejected')),
    created_at   TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now')),
    UNIQUE(requester_id, addressee_id)
);

-- ------------------------------------------------------------
-- posts
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS posts (
    id             TEXT    NOT NULL PRIMARY KEY,
    author_id      TEXT    NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    post_type      INTEGER NOT NULL DEFAULT 0
                           CHECK(post_type IN (0,1)),
    category       TEXT    NOT NULL DEFAULT 'all'
                           CHECK(category IN ('all','department','circle','faculty','year')),
    body           TEXT    NOT NULL CHECK(length(body) <= 280),
    attachment_url TEXT    NOT NULL DEFAULT '',
    is_pinned      INTEGER NOT NULL DEFAULT 0 CHECK(is_pinned IN (0,1)),
    created_at     TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
);

CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_category   ON posts(category);

-- ------------------------------------------------------------
-- ume_likes  (梅いいね; 1 user × 1 post)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ume_likes (
    post_id    TEXT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now')),
    PRIMARY KEY (post_id, user_id)
);

-- ------------------------------------------------------------
-- reports
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS reports (
    id          TEXT NOT NULL PRIMARY KEY,
    post_id     TEXT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    reporter_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason      TEXT NOT NULL DEFAULT '',
    created_at  TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now')),
    UNIQUE(post_id, reporter_id)
);

-- ------------------------------------------------------------
-- blocks
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS blocks (
    id         TEXT NOT NULL PRIMARY KEY,
    blocker_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocked_id TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now')),
    UNIQUE(blocker_id, blocked_id)
);

-- ------------------------------------------------------------
-- notifications
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS notifications (
    id         TEXT    NOT NULL PRIMARY KEY,
    user_id    TEXT    NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type       TEXT    NOT NULL,
    payload    TEXT    NOT NULL DEFAULT '{}',
    is_read    INTEGER NOT NULL DEFAULT 0 CHECK(is_read IN (0,1)),
    created_at TEXT    NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id, is_read, created_at DESC);
