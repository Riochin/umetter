# Timetable Import Scripts

津田塾大学の公開Google Sheetsから学芸学部時間割を取得し、SQLiteの `classes` テーブルへ流し込むためのスクリプトです。

## ファイル

- `inspect_timetable.py`
  - xlsxのシート名・行列構造を確認するための調査用スクリプト
- `import_timetable.py`
  - `T134` / `T2` シートから授業情報を抽出し、`classes` テーブルへUPSERTするスクリプト
- `requirements.txt`
  - Pythonスクリプト実行に必要なライブラリ

## 登録する情報

以下の情報を `classes` テーブルへ登録します。

- 時間割コード
- ターム
- 授業名
- 教員名
- 曜日
- 時限
- 教室名称

## タームの扱い

- `T134` シート
  - `担当期` カラムをもとに `T1` / `T3` / `T4` として保存します。
- `T2` シート
  - 第2ターム用シートのため、`T2` として保存します。

## 実行方法

cd backend

python3 -m venv .venv
source .venv/bin/activate
pip install -r scripts/requirements.txt

python scripts/import_timetable.py

## 仕様メモ

- xlsxファイルが存在しない場合は、公開Google Sheetsから自動でダウンロードします。
- `T134` シートと `T2` シートを対象にしています。
- `T2` シートは授業日ごとに同じ授業が複数行あるため、時間割コード・ターム・曜日・時限をもとに重複排除しています。
- `classes.id` は `tt_<時間割コード>_<ターム>_<曜日番号>_<時限>` の形式で生成しています。
