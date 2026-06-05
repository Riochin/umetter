CREATE TABLE IF NOT EXISTS teacher_allowed_emails (
    email      TEXT NOT NULL PRIMARY KEY,
    name       TEXT NOT NULL DEFAULT '',
    source     TEXT NOT NULL DEFAULT 'manual',
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
);

CREATE TABLE IF NOT EXISTS email_verification_codes (
    email      TEXT NOT NULL PRIMARY KEY,
    code_hash  TEXT NOT NULL,
    purpose    TEXT NOT NULL DEFAULT 'register',
    expires_at TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
);

CREATE TABLE IF NOT EXISTS verified_emails (
    email       TEXT NOT NULL PRIMARY KEY,
    verified_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
);

INSERT OR IGNORE INTO teacher_allowed_emails (email, name, source)
VALUES
    ('teacher.test@gm.tsuda.ac.jp', 'Test Teacher', 'test');