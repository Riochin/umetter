-- 005_class_syllabus_fields.sql — 学芸学部時間割スプレッドシート対応
--
-- 公開時間割（曜日/時限/時間割コード/授業名/開講期/担当期/教員名/教室/程度/単位/
-- 備考/学科別履修可否…）を classes に取り込めるよう列とテーブルを追加する。
-- 既存カラムとの対応:
--   時間割コード → classes.class_code（004で追加済み）
--   授業名/教員名/教室名称 → name / teacher_name / room
--   曜日/時限 → day_of_week(月=1..土=6) / period

-- classes: 開講期(ターム)・程度・単位・備考
ALTER TABLE classes ADD COLUMN term    TEXT    NOT NULL DEFAULT '';  -- 開講期: 'T1','T134' 等の生値
ALTER TABLE classes ADD COLUMN level   TEXT    NOT NULL DEFAULT '';  -- 程度: 'I','II','III' 等
ALTER TABLE classes ADD COLUMN credits INTEGER NOT NULL DEFAULT 0;   -- 単位
ALTER TABLE classes ADD COLUMN remarks TEXT    NOT NULL DEFAULT '';  -- 備考（ペア授業・集中講義日程等）

-- 学科別の履修可否マトリクス（○=allowed / △=conditional / ×=denied）
-- audience: english(英文) / international(国際) / multicultural(多文化) /
--           mathematics(数学) / information(情報) / integrated(総合) /
--           credit_auditor(科目等履修生) / auditor(聴講生)
CREATE TABLE IF NOT EXISTS class_enrollment_permissions (
    class_id   TEXT NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
    audience   TEXT NOT NULL
                    CHECK(audience IN ('english','international','multicultural',
                                       'mathematics','information','integrated',
                                       'credit_auditor','auditor')),
    permission TEXT NOT NULL DEFAULT 'denied'
                    CHECK(permission IN ('allowed','conditional','denied')),
    note       TEXT NOT NULL DEFAULT '',
    PRIMARY KEY (class_id, audience)
);

CREATE INDEX IF NOT EXISTS idx_class_enroll_audience
    ON class_enrollment_permissions(audience, permission);
