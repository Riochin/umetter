# API リファレンス

ベースURL: `/api/v1` ／ 認証: `Authorization: Bearer <token>`（🔒 マークのエンドポイント）

- [認証](#認証)
- [マイページ](#マイページ)
- [タイムライン](#タイムライン)
- [授業・時間割](#授業時間割)
- [友達・公開認可](#友達公開認可)
- [データモデル](#データモデル)

---

## 認証

### POST `/auth/register`

メールアドレスで仮登録し、確認コードをメール送信する。学生メール（`[学科][入学年2桁][番号]@gm.tsuda.ac.jp`）は学科・入学年を自動抽出。教員は許可リスト（`teacher_allowed_emails`）に登録されたメールのみ可。

リクエスト:
```json
{ "email": "ab24001@gm.tsuda.ac.jp", "password": "password123", "display_name": "うめ子" }
```
| フィールド | 必須 | 制約 |
|---|---|---|
| `email` | ✅ | メール形式。学生メール or 許可済み教員メール |
| `password` | ✅ | 8文字以上 |
| `display_name` | – | 任意 |

レスポンス `202 Accepted`:
```json
{ "message": "verification code sent", "email": "ab24001@gm.tsuda.ac.jp", "debug_code": "123456" }
```
> `debug_code` は `EMAIL_DEBUG=true` のときのみ含まれる（開発用）。

エラー: `400`（メール/パスワード不正・許可外メール）, `409`（登録済み）

---

### POST `/auth/verify-email`

確認コードを検証し、JWT を発行する。

リクエスト:
```json
{ "email": "ab24001@gm.tsuda.ac.jp", "code": "123456" }
```

レスポンス `200 OK`:
```json
{ "token": "<JWT>", "user": { /* safeUser */ } }
```

エラー: `400`（コード未発行・期限切れ）, `401`（コード不一致）, `404`（ユーザー不明）

---

### POST `/auth/login`

メール確認済みユーザーのログイン。JWT を発行する。

リクエスト:
```json
{ "email": "ab24001@gm.tsuda.ac.jp", "password": "password123" }
```

レスポンス `200 OK`:
```json
{ "token": "<JWT>", "user": { /* safeUser */ } }
```

エラー: `401`（認証情報不正／メール存在有無は秘匿）, `403`（メール未確認）

---

## マイページ

### GET `/me` 🔒

ログイン中ユーザーの情報を返す。

レスポンス `200 OK`: [safeUser](#safeuser)

---

### PATCH `/me/visibility` 🔒

時間割の公開範囲を変更する。

リクエスト:
```json
{ "timetable_visibility": "juniors" }
```
| 値 | 公開対象 |
|---|---|
| `private` | 自分のみ |
| `friends` | 相互承認した友達のみ |
| `juniors` | 友達 ＋ 同学科の後輩（友達申請なしで閲覧可） |
| `all` | 全員 |

レスポンス `200 OK`: 更新後の [safeUser](#safeuser)

エラー: `400`（不正な値）

---

## タイムライン

### GET `/posts` 🔒

投稿一覧を取得する。匿名投稿（`post_type = 0`）は投稿者情報をマスクして返す。

クエリ: `?category=all|department|circle|faculty|year`（省略時は全件）

レスポンス `200 OK`:
```json
{ "posts": [ { /* PublicPost */ } ] }
```

---

### POST `/posts` 🔒

投稿を作成する（匿名・テキスト＋添付1点）。

リクエスト:
```json
{ "body": "テスト投稿", "category": "all", "attachment_url": "" }
```
| フィールド | 必須 | 制約 |
|---|---|---|
| `body` | ✅ | 280文字以内 |
| `category` | – | 省略時 `all` |
| `attachment_url` | – | 任意 |

レスポンス `201 Created`:
```json
{ "id": "<post-id>" }
```

---

### POST `/posts/:id/report` 🔒

投稿を通報する（1ユーザーにつき1投稿1回まで）。

リクエスト:
```json
{ "reason": "スパム" }
```

レスポンス `201 Created`:
```json
{ "message": "reported" }
```

エラー: `404`（投稿なし）, `409`（通報済み）

---

## 授業・時間割

### GET `/classes` 🔒

授業を検索する（授業名・教員名で部分一致）。

クエリ: `?keyword=英語`（省略時は全件）

レスポンス `200 OK`:
```json
{ "classes": [ { /* Class */ } ] }
```

---

### POST `/timetables` 🔒

自分の時間割に授業を登録する。

リクエスト:
```json
{ "class_id": "cls-eng1", "memo": "1限つらい" }
```
| フィールド | 必須 |
|---|---|
| `class_id` | ✅ |
| `memo` | – |

レスポンス `201 Created`:
```json
{ "id": "<timetable-entry-id>" }
```

エラー: `404`（授業なし）, `409`（登録済み）

---

### GET `/timetables` 🔒

自分の時間割一覧を返す（授業情報を結合）。

レスポンス `200 OK`:
```json
{ "timetable": [ { /* TimetableEntry */ } ] }
```

---

### PATCH `/timetables/:id` 🔒

時間割エントリの出欠カウント・メモを更新する。指定フィールドのみ更新（部分更新）。

リクエスト（すべて任意）:
```json
{ "memo": "出席した", "count_present": 3, "count_absent": 0, "count_late": 1 }
```

レスポンス `200 OK`:
```json
{ "message": "updated" }
```

エラー: `403`（他人のエントリ）, `404`（エントリなし）

---

## 友達・公開認可

友達関係は**相互承認制**。申請者が `POST /friends/request` を送り、受信者（addressee）が `PATCH /friends/:id` で承認/拒否する。

### POST `/friends/request` 🔒

友達申請を送る。

リクエスト:
```json
{ "addressee_id": "<user-id>" }
```

レスポンス `201 Created`:
```json
{ "id": "<friendship-id>" }
```

エラー: `400`（自分自身への申請）, `404`（相手が存在しない）, `409`（申請済み）

---

### PATCH `/friends/:id` 🔒

友達申請を承認/拒否する。**受信者（addressee）本人のみ**、かつ `pending` のもののみ操作可。

リクエスト:
```json
{ "status": "approved" }
```
`status` は `approved` または `rejected`。

レスポンス `200 OK`:
```json
{ "message": "approved" }
```

エラー: `400`（不正な status）, `403`（受信者本人でない）, `404`（申請なし）, `409`（既に処理済み）

---

### GET `/friends` 🔒

自分が関与する（申請した／された）友達関係の一覧を返す。

レスポンス `200 OK`:
```json
{ "friendships": [ { /* Friendship */ } ] }
```

---

### GET `/friends/:id/timetable` 🔒

指定ユーザー（`:id`）の時間割を**公開範囲チェック付き**で閲覧する。`:id` は時間割の持ち主（owner）の user ID。

**公開認可ロジック**（仕様書 5.5「縦の繋がり自動承認」）:

| owner の公開範囲 | 閲覧可否 |
|---|---|
| 本人 | 常に閲覧可 |
| `all` | 誰でも閲覧可 |
| `private` | 本人以外不可 |
| `friends` | 相互承認した友達のみ |
| `juniors` | 相互承認した友達 **または** 同学科かつ自分より後の入学年（＝後輩）。後輩は友達申請なしで閲覧可 |

レスポンス `200 OK`:
```json
{ "timetable": [ { /* TimetableEntry */ } ] }
```

エラー: `403`（公開範囲外）, `404`（ユーザーなし）

---

## データモデル

### safeUser

パスワードハッシュ等の機微情報を除いたユーザー表現。

```json
{
  "id": "uuid",
  "email": "ab24001@gm.tsuda.ac.jp",
  "department": "ab",
  "admission_year": 2024,
  "display_name": "うめ子",
  "role": "student",
  "timetable_visibility": "friends"
}
```
- `role`: `student` / `faculty` / `admin`
- `timetable_visibility`: `private` / `friends` / `juniors` / `all`

### PublicPost

```json
{
  "id": "uuid",
  "post_type": 0,
  "category": "all",
  "body": "テスト投稿",
  "attachment_url": "",
  "is_pinned": false,
  "created_at": "2026-06-05T12:00:00Z"
}
```
- `post_type`: `0`=匿名 / `1`=記名
- `category`: `all` / `department` / `circle` / `faculty` / `year`

### Class

```json
{
  "id": "cls-eng1",
  "class_code": "EL001A02",
  "name": "英語コミュニケーションI",
  "teacher_name": "山田 花子",
  "day_of_week": 1,
  "period": 1,
  "room": "本館101",
  "term": "T1",
  "semester": "",
  "level": "I",
  "credits": 1,
  "remarks": "",
  "is_canceled": false
}
```
- `day_of_week`: 1（月）〜6（土）
- `period`: 1〜6限
- `class_code`: 時間割コード（任意）
- `term`: 開講期（ターム）。`T1` / `T134` 等の生値
- `semester`: `first`（前期）/ `second`（後期）/ `full`（通年）/ `""`（未設定）
- `level`: 程度（`I`/`II`/`III` 等） ／ `credits`: 単位数 ／ `remarks`: 備考

> 学科別の履修可否は別テーブル `class_enrollment_permissions` で保持（[database.md](./database.md) 参照）。専用 API は未実装。

### TimetableEntry

時間割エントリと授業情報を結合した表現。

```json
{
  "id": "uuid",
  "class_id": "cls-eng1",
  "class_code": "",
  "name": "英語コミュニケーションI",
  "teacher_name": "山田 花子",
  "day_of_week": 1,
  "period": 1,
  "room": "本館101",
  "term": "T1",
  "semester": "",
  "level": "I",
  "credits": 1,
  "remarks": "",
  "is_canceled": false,
  "memo": "1限つらい",
  "count_present": 3,
  "count_absent": 0,
  "count_late": 1,
  "created_at": "2026-06-05T12:00:00Z"
}
```

### Friendship

```json
{
  "id": "uuid",
  "requester_id": "uuid",
  "addressee_id": "uuid",
  "status": "approved",
  "created_at": "2026-06-05T12:00:00Z",
  "updated_at": "2026-06-05T12:30:00Z"
}
```
- `status`: `pending` / `approved` / `rejected`
- `updated_at`: 申請作成・承認/拒否の更新時刻
