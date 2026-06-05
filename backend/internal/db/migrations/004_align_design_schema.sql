-- 004_align_design_schema.sql — 当初ER設計に合わせた追加カラム
--
-- SQLite の ALTER TABLE ADD COLUMN には制約がある:
--   * UNIQUE / PRIMARY KEY 制約は付けられない
--   * デフォルト値に式（strftime など）は使えない（定数のみ）
-- そのため class_code の一意性は部分インデックスで担保し、
-- タイムスタンプ列はデフォルト '' としてアプリ側で値を設定する。

-- classes: 授業コード（任意・設定済みのみ一意）と学期
ALTER TABLE classes ADD COLUMN class_code TEXT NOT NULL DEFAULT '';
ALTER TABLE classes ADD COLUMN semester   TEXT NOT NULL DEFAULT ''
    CHECK(semester IN ('first', 'second', 'full', ''));

CREATE UNIQUE INDEX IF NOT EXISTS idx_classes_class_code
    ON classes(class_code) WHERE class_code <> '';

-- user_timetables: 登録時刻
ALTER TABLE user_timetables ADD COLUMN created_at TEXT NOT NULL DEFAULT '';

-- friendships: 承認/拒否の更新時刻
ALTER TABLE friendships ADD COLUMN updated_at TEXT NOT NULL DEFAULT '';
