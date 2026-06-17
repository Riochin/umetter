from pathlib import Path
import re
import sqlite3
import urllib.request

import openpyxl


BASE_DIR = Path(__file__).resolve().parents[1]
DB_PATH = BASE_DIR / "umetter.db"
DATA_DIR = BASE_DIR / "data" / "raw"
XLSX_PATH = DATA_DIR / "tsuda_gakugei_timetable_2026.xlsx"

TIMETABLE_URL = (
    "https://docs.google.com/spreadsheets/d/e/"
    "2PACX-1vR45LvUqliCyhWy5Kq8L3IShriPz4lSGMuftbOnBv5MKRwOujDc19zhiqFuJP3v_XKsfAf3oO9IMrFS/"
    "pub?output=xlsx"
)

DAY_MAP = {
    "月": 1,
    "火": 2,
    "水": 3,
    "木": 4,
    "金": 5,
    "土": 6,
}


def clean_text(value) -> str:
    if value is None:
        return ""

    # 5206.0 みたいな教室番号を 5206 にする
    if isinstance(value, float) and value.is_integer():
        return str(int(value))

    text = str(value).replace("\n", " ").strip()
    text = re.sub(r"\s+", " ", text)

    # 授業名の先頭にある ★ はアプリ表示上は邪魔なので消す
    text = text.removeprefix("★").strip()

    # openpyxlが 5206.0 を文字列として返した場合も整える
    if re.fullmatch(r"\d+\.0", text):
        return text[:-2]

    return text


def to_period(value) -> int | None:
    if value is None or value == "":
        return None

    try:
        return int(float(value))
    except ValueError:
        return None


def make_class_id(code: str, day_of_week: int, period: int) -> str:
    # classes.id は TEXT なので、時間割コード + 曜日 + 時限で安定IDを作る
    # T2は同じ授業が日付ごとに複数行あるため、日付はIDに含めない
    safe_code = re.sub(r"[^A-Za-z0-9_-]", "_", code)
    return f"tt_{safe_code}_{day_of_week}_{period}"


def download_xlsx() -> None:
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    if XLSX_PATH.exists():
        print(f"既存ファイルを使います: {XLSX_PATH}")
        return

    print("時間割ファイルをダウンロードします...")
    urllib.request.urlretrieve(TIMETABLE_URL, XLSX_PATH)
    print(f"保存しました: {XLSX_PATH}")


def parse_t134(ws):
    """
    T134:
    6行目: ヘッダー
    A:曜日 B:時限 C:時間割コード D:授業名 E:開講期 F:担当期 G:教員名 H:教室名称
    """
    rows = []

    for row in ws.iter_rows(min_row=7, values_only=True):
        day = clean_text(row[0])
        period = to_period(row[1])
        code = clean_text(row[2])
        name = clean_text(row[3])
        teacher_name = clean_text(row[6])
        room = clean_text(row[7])

        if not day or period is None or not code or not name:
            continue

        day_of_week = DAY_MAP.get(day)
        if day_of_week is None:
            continue

        rows.append({
            "id": make_class_id(code, day_of_week, period),
            "name": name,
            "teacher_name": teacher_name,
            "day_of_week": day_of_week,
            "period": period,
            "room": room,
        })

    return rows


def parse_t2(ws):
    """
    T2:
    7行目: ヘッダー
    A:時間割コード B:授業名 C:教員氏名 D:教室名称 E:曜日 F:時限 G:授業年月日
    """
    rows = []

    for row in ws.iter_rows(min_row=9, values_only=True):
        code = clean_text(row[0])
        name = clean_text(row[1])
        teacher_name = clean_text(row[2])
        room = clean_text(row[3])
        day = clean_text(row[4])
        period = to_period(row[5])

        if not day or period is None or not code or not name:
            continue

        day_of_week = DAY_MAP.get(day)
        if day_of_week is None:
            continue

        rows.append({
            "id": make_class_id(code, day_of_week, period),
            "name": name,
            "teacher_name": teacher_name,
            "day_of_week": day_of_week,
            "period": period,
            "room": room,
        })

    return rows


def dedupe_classes(classes):
    """
    同じ id の授業は1件にまとめる。
    T134のT1/T3/T4重複や、T2の日付ごとの重複をここで消す。
    """
    unique = {}

    for cls in classes:
        if cls["id"] not in unique:
            unique[cls["id"]] = cls

    return list(unique.values())


def import_classes(classes):
    conn = sqlite3.connect(DB_PATH)

    try:
        conn.execute("PRAGMA foreign_keys = ON")

        sql = """
        INSERT INTO classes (
            id,
            name,
            teacher_name,
            day_of_week,
            period,
            room,
            is_canceled
        )
        VALUES (?, ?, ?, ?, ?, ?, 0)
        ON CONFLICT(id) DO UPDATE SET
            name = excluded.name,
            teacher_name = excluded.teacher_name,
            day_of_week = excluded.day_of_week,
            period = excluded.period,
            room = excluded.room;
        """

        conn.executemany(
            sql,
            [
                (
                    cls["id"],
                    cls["name"],
                    cls["teacher_name"],
                    cls["day_of_week"],
                    cls["period"],
                    cls["room"],
                )
                for cls in classes
            ],
        )

        conn.commit()

    finally:
        conn.close()


def main():
    download_xlsx()

    wb = openpyxl.load_workbook(XLSX_PATH, data_only=True)

    all_classes = []

    if "T134" in wb.sheetnames:
        all_classes.extend(parse_t134(wb["T134"]))

    if "T2" in wb.sheetnames:
        all_classes.extend(parse_t2(wb["T2"]))

    unique_classes = dedupe_classes(all_classes)

    print(f"抽出件数: {len(all_classes)}")
    print(f"重複排除後: {len(unique_classes)}")

    print("\nサンプル:")
    for cls in unique_classes[:10]:
        print(cls)

    import_classes(unique_classes)

    print("\nclasses テーブルへの流し込みが完了しました。")


if __name__ == "__main__":
    main()
