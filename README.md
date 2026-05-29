# うめったー Backend

津田塾大学生専用の時間割管理・匿名SNS「うめったー」のGoバックエンド。

## 技術スタック

| 項目 | 内容 |
|---|---|
| 言語 | Go 1.22 |
| フレームワーク | Gin |
| ローカルDB | SQLite (`modernc.org/sqlite` — pure Go) |
| 本番DB | Cloudflare D1 REST API |
| 認証 | JWT + bcrypt |
| デプロイ先 | Cloudflare Workers Container |

## セットアップ

```bash
# 1. 環境変数ファイルを作成
cp .env.example .env

# 2. .env の JWT_SECRET を任意の文字列に変更（必須）
#    例: JWT_SECRET=my-local-dev-secret

# 3. 依存パッケージのインストール
go mod download
```

## 起動

```bash
make dev
# または
go run ./cmd/server
```

デフォルトで `http://localhost:8080` で起動します（`PORT` 変数で変更可）。

初回起動時、`DB_PATH` に指定した SQLite ファイルが自動作成され、マイグレーションが実行されます。

## ビルド

```bash
make build
# バイナリ: ./umetter
```

## API エンドポイント（Sprint 2 実装済み）

| メソッド | パス | 認証 | 概要 |
|---|---|---|---|
| POST | `/api/v1/auth/register` | 不要 | 新規登録（`@gm.tsuda.ac.jp` 限定） |
| POST | `/api/v1/auth/login` | 不要 | ログイン・JWT 発行 |
| GET | `/api/v1/me` | Bearer JWT | 自分のユーザー情報取得 |

### 登録

```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"email":"ab24001@gm.tsuda.ac.jp","password":"password123","display_name":"りおちゃん"}'
```

メールアドレスから学科コード・入学年度が自動抽出されます（例: `ab24001` → `department: ab`, `admission_year: 2024`）。

### ログイン

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"ab24001@gm.tsuda.ac.jp","password":"password123"}'
```

レスポンスの `token` を以降のリクエストで使用します。

### 自分の情報を取得

```bash
curl http://localhost:8080/api/v1/me \
  -H 'Authorization: Bearer <TOKEN>'
```

## 環境変数

| 変数名 | デフォルト | 説明 |
|---|---|---|
| `DB_DRIVER` | `sqlite` | `sqlite` または `d1` |
| `DB_PATH` | `./umetter.db` | SQLite ファイルパス |
| `D1_ACCOUNT_ID` | — | Cloudflare アカウント ID（D1 使用時） |
| `D1_DATABASE_ID` | — | D1 データベース ID（D1 使用時） |
| `D1_API_TOKEN` | — | Cloudflare API トークン（D1 使用時） |
| `JWT_SECRET` | **必須** | JWT 署名シークレット |
| `JWT_EXPIRE_HOURS` | `720` | JWT 有効期限（時間） |
| `PORT` | `8080` | リッスンポート |

## ディレクトリ構成

```
cmd/server/main.go                  # エントリポイント
internal/
  config/config.go                  # 環境変数
  domain/user.go                    # ドメインモデル・メール解析
  repository/repository.go          # Repository インターフェース
  db/
    db.go                           # DB 接続・マイグレーション
    migrations/001_init.sql         # スキーマ（全テーブル）
    sqlite/repository.go            # SQLite 実装
    d1/repository.go                # Cloudflare D1 実装（Sprint 4）
  middleware/auth.go                # JWT 検証ミドルウェア
  handler/
    auth.go                         # 認証ハンドラ
    me.go                           # ユーザー情報ハンドラ
router/router.go                    # ルーティング
```
