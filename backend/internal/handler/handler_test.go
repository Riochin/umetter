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

// TestRegister — POST /api/v1/auth/register
func TestRegister(t *testing.T) {
	r := newTestApp(t)

	t.Run("正常登録", func(t *testing.T) {
		w := postJSON(t, r, "/api/v1/auth/register", map[string]any{
			"email":        "ab24001@gm.tsuda.ac.jp",
			"password":     "password123",
			"display_name": "テスト太郎",
		})
		if w.Code != http.StatusCreated {
			t.Fatalf("status = %d, body = %s", w.Code, w.Body.String())
		}
		var resp map[string]any
		json.Unmarshal(w.Body.Bytes(), &resp)
		user := resp["user"].(map[string]any)
		if user["department"] != "ab" {
			t.Errorf("department = %v, want ab", user["department"])
		}
		if user["admission_year"].(float64) != 2024 {
			t.Errorf("admission_year = %v, want 2024", user["admission_year"])
		}
		if resp["token"] == "" || resp["token"] == nil {
			t.Error("token が空")
		}
	})

	t.Run("津田塾以外のメール", func(t *testing.T) {
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
		// ab24001 は上の正常登録で登録済み
		w := postJSON(t, r, "/api/v1/auth/register", map[string]any{
			"email":    "ab24001@gm.tsuda.ac.jp",
			"password": "password123",
		})
		if w.Code != http.StatusConflict {
			t.Errorf("status = %d, want 409", w.Code)
		}
	})
}

// TestLogin — POST /api/v1/auth/login
func TestLogin(t *testing.T) {
	r := newTestApp(t)
	postJSON(t, r, "/api/v1/auth/register", map[string]any{
		"email":    "cs25001@gm.tsuda.ac.jp",
		"password": "mypassword1",
	})

	t.Run("正常ログイン", func(t *testing.T) {
		w := postJSON(t, r, "/api/v1/auth/login", map[string]any{
			"email":    "cs25001@gm.tsuda.ac.jp",
			"password": "mypassword1",
		})
		if w.Code != http.StatusOK {
			t.Fatalf("status = %d, body = %s", w.Code, w.Body.String())
		}
		var resp map[string]any
		json.Unmarshal(w.Body.Bytes(), &resp)
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
	w := postJSON(t, r, "/api/v1/auth/register", map[string]any{
		"email":    "me24001@gm.tsuda.ac.jp",
		"password": "password123",
	})
	var authResp map[string]any
	json.Unmarshal(w.Body.Bytes(), &authResp)
	token := authResp["token"].(string)

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
