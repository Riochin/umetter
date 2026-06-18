-- 002_seed_classes.sql — sample syllabus data for development/testing.
-- Idempotent: fixed IDs + INSERT OR IGNORE so re-running migrations is safe.

INSERT OR IGNORE INTO classes (id, name, teacher_name, day_of_week, period, room, is_canceled) VALUES
    ('cls-eng1',  '英語コミュニケーションI', '山田 花子', 1, 1, '本館101', 0),
    ('cls-eng2',  '英語リーディングII',     '山田 花子', 3, 2, '本館102', 0),
    ('cls-math1', '微分積分学I',           '佐藤 一郎', 2, 3, '理系棟201', 0),
    ('cls-cs1',   '情報科学入門',          '鈴木 二郎', 4, 4, '情報棟301', 0),
    ('cls-hist1', '日本史概論',           '田中 三郎', 5, 1, '本館205', 0),
    ('cls-psy1',  '心理学概論',           '高橋 四子', 1, 5, '本館301', 1);
