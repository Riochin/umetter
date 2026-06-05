package handler_test

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

// registerAndToken registers a user, verifies the email, and returns (userID, token).
// Registration requires email verification (PR #6): register → debug_code → verify-email.
func registerAndToken(t *testing.T, r *gin.Engine, email, password string) (string, string) {
	t.Helper()
	code := registerAndGetCode(t, r, email, password)

	w := postJSON(t, r, "/api/v1/auth/verify-email", map[string]any{
		"email": email,
		"code":  code,
	})
	if w.Code != http.StatusOK {
		t.Fatalf("verify-email %s: status = %d, body = %s", email, w.Code, w.Body.String())
	}
	var resp map[string]any
	json.Unmarshal(w.Body.Bytes(), &resp)
	token := resp["token"].(string)
	user := resp["user"].(map[string]any)
	return user["id"].(string), token
}

// authReq issues an authenticated request with an optional JSON body.
func authReq(t *testing.T, r *gin.Engine, method, path, token string, body any) *httptest.ResponseRecorder {
	t.Helper()
	var reader *bytes.Reader
	if body != nil {
		b, _ := json.Marshal(body)
		reader = bytes.NewReader(b)
	} else {
		reader = bytes.NewReader(nil)
	}
	req := httptest.NewRequest(method, path, reader)
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	return w
}

// TestClassSearch — GET /api/v1/classes?keyword=
func TestClassSearch(t *testing.T) {
	r := newTestApp(t)
	_, token := registerAndToken(t, r, "ab24101@gm.tsuda.ac.jp", "password123")

	t.Run("キーワードヒット", func(t *testing.T) {
		w := authReq(t, r, http.MethodGet, "/api/v1/classes?keyword=英語", token, nil)
		if w.Code != http.StatusOK {
			t.Fatalf("status = %d, body = %s", w.Code, w.Body.String())
		}
		var resp map[string]any
		json.Unmarshal(w.Body.Bytes(), &resp)
		classes := resp["classes"].([]any)
		if len(classes) != 2 {
			t.Errorf("英語 hits = %d, want 2", len(classes))
		}
	})

	t.Run("キーワードなしで全件", func(t *testing.T) {
		w := authReq(t, r, http.MethodGet, "/api/v1/classes", token, nil)
		var resp map[string]any
		json.Unmarshal(w.Body.Bytes(), &resp)
		if len(resp["classes"].([]any)) != 6 {
			t.Errorf("all classes = %d, want 6", len(resp["classes"].([]any)))
		}
	})
}

// TestTimetableRegisterAndList — POST/GET /api/v1/timetables
func TestTimetableRegisterAndList(t *testing.T) {
	r := newTestApp(t)
	_, token := registerAndToken(t, r, "ab24102@gm.tsuda.ac.jp", "password123")

	var entryID string
	t.Run("登録", func(t *testing.T) {
		w := authReq(t, r, http.MethodPost, "/api/v1/timetables", token, map[string]any{
			"class_id": "cls-eng1",
			"memo":     "1限つらい",
		})
		if w.Code != http.StatusCreated {
			t.Fatalf("status = %d, body = %s", w.Code, w.Body.String())
		}
		var resp map[string]any
		json.Unmarshal(w.Body.Bytes(), &resp)
		entryID = resp["id"].(string)
	})

	t.Run("存在しない授業は404", func(t *testing.T) {
		w := authReq(t, r, http.MethodPost, "/api/v1/timetables", token, map[string]any{
			"class_id": "no-such-class",
		})
		if w.Code != http.StatusNotFound {
			t.Errorf("status = %d, want 404", w.Code)
		}
	})

	t.Run("重複登録は409", func(t *testing.T) {
		w := authReq(t, r, http.MethodPost, "/api/v1/timetables", token, map[string]any{
			"class_id": "cls-eng1",
		})
		if w.Code != http.StatusConflict {
			t.Errorf("status = %d, want 409", w.Code)
		}
	})

	t.Run("一覧に反映", func(t *testing.T) {
		w := authReq(t, r, http.MethodGet, "/api/v1/timetables", token, nil)
		var resp map[string]any
		json.Unmarshal(w.Body.Bytes(), &resp)
		tt := resp["timetable"].([]any)
		if len(tt) != 1 {
			t.Fatalf("timetable len = %d, want 1", len(tt))
		}
		entry := tt[0].(map[string]any)
		if entry["name"] != "英語コミュニケーションI" {
			t.Errorf("name = %v", entry["name"])
		}
	})

	t.Run("出欠・メモ更新", func(t *testing.T) {
		w := authReq(t, r, http.MethodPatch, "/api/v1/timetables/"+entryID, token, map[string]any{
			"memo":          "出席した",
			"count_present": 3,
		})
		if w.Code != http.StatusOK {
			t.Fatalf("status = %d, body = %s", w.Code, w.Body.String())
		}
		// confirm persisted
		w2 := authReq(t, r, http.MethodGet, "/api/v1/timetables", token, nil)
		var resp map[string]any
		json.Unmarshal(w2.Body.Bytes(), &resp)
		entry := resp["timetable"].([]any)[0].(map[string]any)
		if entry["count_present"].(float64) != 3 || entry["memo"] != "出席した" {
			t.Errorf("update not persisted: %+v", entry)
		}
	})

	t.Run("他人のエントリ更新は403", func(t *testing.T) {
		_, otherToken := registerAndToken(t, r, "ab24103@gm.tsuda.ac.jp", "password123")
		w := authReq(t, r, http.MethodPatch, "/api/v1/timetables/"+entryID, otherToken, map[string]any{
			"memo": "hack",
		})
		if w.Code != http.StatusForbidden {
			t.Errorf("status = %d, want 403", w.Code)
		}
	})
}
