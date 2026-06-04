package handler_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/irj0927/umetter/internal/config"
	"github.com/irj0927/umetter/internal/db"
	"github.com/irj0927/umetter/internal/db/sqlite"
	"github.com/irj0927/umetter/router"
)

func newTestApp(t *testing.T) *gin.Engine {
	t.Helper()
	gin.SetMode(gin.TestMode)

	cfg := &config.Config{
		DBDriver:       "sqlite",
		DBPath:         ":memory:",
		JWTSecret:      "test-secret-handler",
		JWTExpireHours: 1,
		Port:           "8080",
	}

	sqlDB, err := db.Open(cfg)
	if err != nil {
		t.Fatalf("db.Open: %v", err)
	}

	if _, err := sqlDB.Exec(`
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
		VALUES ('teacher.test@gm.tsuda.ac.jp', 'Test Teacher', 'test');
	`); err != nil {
		t.Fatalf("setup verification tables: %v", err)
	}

	t.Cleanup(func() { sqlDB.Close() })

	return router.New(sqlite.NewRepository(sqlDB), cfg)
}

func postJSON(t *testing.T, r *gin.Engine, path string, body any) *httptest.ResponseRecorder {
	t.Helper()

	b, _ := json.Marshal(body)
	req := httptest.NewRequest(http.MethodPost, path, bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	return w
}

func registerAndGetCode(t *testing.T, r *gin.Engine, email string, password string) string {
	t.Helper()

	w := postJSON(t, r, "/api/v1/auth/register", map[string]any{
		"email":    email,
		"password": password,
	})

	if w.Code != http.StatusAccepted {
		t.Fatalf("register status = %d, body = %s", w.Code, w.Body.String())
	}

	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("unmarshal register response: %v", err)
	}

	code, ok := resp["debug_code"].(string)
	if !ok || code == "" {
		t.Fatalf("debug_code is empty: %v", resp)
	}

	return code
}

func verifyAndGetToken(t *testing.T, r *gin.Engine, email string, code string) string {
	t.Helper()

	w := postJSON(t, r, "/api/v1/auth/verify-email", map[string]any{
		"email": email,
		"code":  code,
	})

	if w.Code != http.StatusOK {
		t.Fatalf("verify status = %d, body = %s", w.Code, w.Body.String())
	}

	var resp map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
		t.Fatalf("unmarshal verify response: %v", err)
	}

	token, ok := resp["token"].(string)
	if !ok || token == "" {
		t.Fatalf("token is empty: %v", resp)
	}

	return token
}

// TestRegister — POST /api/v1/auth/register
func TestRegister(t *testing.T) {
	r := newTestApp(t)

	t.Run("正常登録", func(t *testing.T) {
		w := postJSON(t, r, "/api/v1/auth/register", map[string]any{
			"email":        "ab24001@gm.tsuda.ac.jp",
			"password":     "password123",
			"display_name": "テスト太郎",
		})

		if w.Code != http.StatusAccepted {
			t.Fatalf("status = %d, body = %s", w.Code, w.Body.String())
		}

		var resp map[string]any
		if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
			t.Fatalf("unmarshal response: %v", err)
		}

		if resp["email"] != "ab24001@gm.tsuda.ac.jp" {
			t.Errorf("email = %v, want ab24001@gm.tsuda.ac.jp", resp["email"])
		}
		if resp["debug_code"] == "" || resp["debug_code"] == nil {
			t.Error("debug_code が空")
		}
	})

	t.Run("teacherメール登録", func(t *testing.T) {
		code := registerAndGetCode(t, r, "teacher.test@gm.tsuda.ac.jp", "password123")

		w := postJSON(t, r, "/api/v1/auth/verify-email", map[string]any{
			"email": "teacher.test@gm.tsuda.ac.jp",
			"code":  code,
		})

		if w.Code != http.StatusOK {
			t.Fatalf("status = %d, body = %s", w.Code, w.Body.String())
		}

		var resp map[string]any
		if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
			t.Fatalf("unmarshal response: %v", err)
		}

		user := resp["user"].(map[string]any)
		if user["role"] != "faculty" {
			t.Errorf("role = %v, want faculty", user["role"])
		}
	})

	t.Run("許可されていないメール", func(t *testing.T) {
		w := postJSON(t, r, "/api/v1/auth/register", map[string]any{
			"email":    "test@gmail.com",
			"password": "password123",
		})

		if w.Code != http.StatusBadRequest {
			t.Errorf("status = %d, want 400", w.Code)
		}
	})

	t.Run("パスワード短すぎ", func(t *testing.T) {
		w := postJSON(t, r, "/api/v1/auth/register", map[string]any{
			"email":    "ab24002@gm.tsuda.ac.jp",
			"password": "short",
		})

		if w.Code != http.StatusBadRequest {
			t.Errorf("status = %d, want 400", w.Code)
		}
	})

	t.Run("メール重複", func(t *testing.T) {
		w := postJSON(t, r, "/api/v1/auth/register", map[string]any{
			"email":    "ab24001@gm.tsuda.ac.jp",
			"password": "password123",
		})

		if w.Code != http.StatusConflict {
			t.Errorf("status = %d, want 409", w.Code)
		}
	})
}

// TestVerifyEmail — POST /api/v1/auth/verify-email
func TestVerifyEmail(t *testing.T) {
	r := newTestApp(t)

	t.Run("正常確認", func(t *testing.T) {
		code := registerAndGetCode(t, r, "ve24001@gm.tsuda.ac.jp", "password123")
		token := verifyAndGetToken(t, r, "ve24001@gm.tsuda.ac.jp", code)

		if token == "" {
			t.Error("token が空")
		}
	})

	t.Run("確認コード不一致", func(t *testing.T) {
		registerAndGetCode(t, r, "ve24002@gm.tsuda.ac.jp", "password123")

		w := postJSON(t, r, "/api/v1/auth/verify-email", map[string]any{
			"email": "ve24002@gm.tsuda.ac.jp",
			"code":  "000000",
		})

		if w.Code != http.StatusUnauthorized {
			t.Errorf("status = %d, want 401", w.Code)
		}
	})
}

// TestLogin — POST /api/v1/auth/login
func TestLogin(t *testing.T) {
	r := newTestApp(t)

	code := registerAndGetCode(t, r, "cs25001@gm.tsuda.ac.jp", "mypassword1")

	t.Run("メール未確認ではログイン不可", func(t *testing.T) {
		w := postJSON(t, r, "/api/v1/auth/login", map[string]any{
			"email":    "cs25001@gm.tsuda.ac.jp",
			"password": "mypassword1",
		})

		if w.Code != http.StatusForbidden {
			t.Errorf("status = %d, want 403", w.Code)
		}
	})

	verifyAndGetToken(t, r, "cs25001@gm.tsuda.ac.jp", code)

	t.Run("正常ログイン", func(t *testing.T) {
		w := postJSON(t, r, "/api/v1/auth/login", map[string]any{
			"email":    "cs25001@gm.tsuda.ac.jp",
			"password": "mypassword1",
		})

		if w.Code != http.StatusOK {
			t.Fatalf("status = %d, body = %s", w.Code, w.Body.String())
		}

		var resp map[string]any
		if err := json.Unmarshal(w.Body.Bytes(), &resp); err != nil {
			t.Fatalf("unmarshal response: %v", err)
		}

		if resp["token"] == "" || resp["token"] == nil {
			t.Error("token が空")
		}
	})

	t.Run("パスワード不一致", func(t *testing.T) {
		w := postJSON(t, r, "/api/v1/auth/login", map[string]any{
			"email":    "cs25001@gm.tsuda.ac.jp",
			"password": "wrongpassword",
		})

		if w.Code != http.StatusUnauthorized {
			t.Errorf("status = %d, want 401", w.Code)
		}
	})

	t.Run("存在しないメール", func(t *testing.T) {
		w := postJSON(t, r, "/api/v1/auth/login", map[string]any{
			"email":    "notexist24001@gm.tsuda.ac.jp",
			"password": "password123",
		})

		// メール存在有無を区別しない（列挙攻撃防止）
		if w.Code != http.StatusUnauthorized {
			t.Errorf("status = %d, want 401", w.Code)
		}
	})
}

// TestGetMe — GET /api/v1/me
func TestGetMe(t *testing.T) {
	r := newTestApp(t)

	code := registerAndGetCode(t, r, "me24001@gm.tsuda.ac.jp", "password123")
	token := verifyAndGetToken(t, r, "me24001@gm.tsuda.ac.jp", code)

	t.Run("有効なトークンで200", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/me", nil)
		req.Header.Set("Authorization", "Bearer "+token)

		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		if w.Code != http.StatusOK {
			t.Fatalf("status = %d, body = %s", w.Code, w.Body.String())
		}
	})

	t.Run("トークンなしで401", func(t *testing.T) {
		req := httptest.NewRequest(http.MethodGet, "/api/v1/me", nil)

		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)

		if w.Code != http.StatusUnauthorized {
			t.Errorf("status = %d, want 401", w.Code)
		}
	})
}
