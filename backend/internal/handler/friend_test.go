package handler_test

import (
	"encoding/json"
	"net/http"
	"testing"

	"github.com/gin-gonic/gin"
)

// TestFriendRequestFlow — POST /friends/request → PATCH /friends/:id → GET /friends
func TestFriendRequestFlow(t *testing.T) {
	r := newTestApp(t)
	aID, aToken := registerAndToken(t, r, "ab24300@gm.tsuda.ac.jp", "password123")
	bID, bToken := registerAndToken(t, r, "ab24301@gm.tsuda.ac.jp", "password123")

	t.Run("自己申請は400", func(t *testing.T) {
		w := authReq(t, r, http.MethodPost, "/api/v1/friends/request", aToken, map[string]any{
			"addressee_id": aID,
		})
		if w.Code != http.StatusBadRequest {
			t.Errorf("status = %d, want 400", w.Code)
		}
	})

	var friendshipID string
	t.Run("申請", func(t *testing.T) {
		w := authReq(t, r, http.MethodPost, "/api/v1/friends/request", aToken, map[string]any{
			"addressee_id": bID,
		})
		if w.Code != http.StatusCreated {
			t.Fatalf("status = %d, body = %s", w.Code, w.Body.String())
		}
		var resp map[string]any
		json.Unmarshal(w.Body.Bytes(), &resp)
		friendshipID = resp["id"].(string)
	})

	t.Run("重複申請は409", func(t *testing.T) {
		w := authReq(t, r, http.MethodPost, "/api/v1/friends/request", aToken, map[string]any{
			"addressee_id": bID,
		})
		if w.Code != http.StatusConflict {
			t.Errorf("status = %d, want 409", w.Code)
		}
	})

	t.Run("申請者本人は承認できず403", func(t *testing.T) {
		w := authReq(t, r, http.MethodPatch, "/api/v1/friends/"+friendshipID, aToken, map[string]any{
			"status": "approved",
		})
		if w.Code != http.StatusForbidden {
			t.Errorf("status = %d, want 403", w.Code)
		}
	})

	t.Run("addresseeが承認", func(t *testing.T) {
		w := authReq(t, r, http.MethodPatch, "/api/v1/friends/"+friendshipID, bToken, map[string]any{
			"status": "approved",
		})
		if w.Code != http.StatusOK {
			t.Fatalf("status = %d, body = %s", w.Code, w.Body.String())
		}
	})

	t.Run("承認済みは再応答できず409", func(t *testing.T) {
		w := authReq(t, r, http.MethodPatch, "/api/v1/friends/"+friendshipID, bToken, map[string]any{
			"status": "rejected",
		})
		if w.Code != http.StatusConflict {
			t.Errorf("status = %d, want 409", w.Code)
		}
	})

	t.Run("両者のGET /friendsに反映", func(t *testing.T) {
		for _, token := range []string{aToken, bToken} {
			w := authReq(t, r, http.MethodGet, "/api/v1/friends", token, nil)
			var resp map[string]any
			json.Unmarshal(w.Body.Bytes(), &resp)
			fs := resp["friendships"].([]any)
			if len(fs) != 1 {
				t.Fatalf("friendships len = %d, want 1", len(fs))
			}
			if fs[0].(map[string]any)["status"] != "approved" {
				t.Errorf("status = %v, want approved", fs[0].(map[string]any)["status"])
			}
		}
	})
}

// registerWithTimetable registers a user, gives them one timetable entry, and
// sets their visibility. Returns (userID, token).
func registerWithTimetable(t *testing.T, r *gin.Engine, email, visibility string) (string, string) {
	t.Helper()
	id, token := registerAndToken(t, r, email, "password123")
	w := authReq(t, r, http.MethodPost, "/api/v1/timetables", token, map[string]any{
		"class_id": "cls-eng1",
	})
	if w.Code != http.StatusCreated {
		t.Fatalf("seed timetable: status = %d, body = %s", w.Code, w.Body.String())
	}
	w = authReq(t, r, http.MethodPatch, "/api/v1/me/visibility", token, map[string]any{
		"timetable_visibility": visibility,
	})
	if w.Code != http.StatusOK {
		t.Fatalf("set visibility: status = %d, body = %s", w.Code, w.Body.String())
	}
	return id, token
}

// TestTimetableVisibility — GET /friends/:id/timetable 公開認可 (仕様書 5.5)
func TestTimetableVisibility(t *testing.T) {
	r := newTestApp(t)

	// viewers
	juniorID, juniorTok := registerAndToken(t, r, "ab25400@gm.tsuda.ac.jp", "password123") // ab 2025
	_ = juniorID
	_, seniorTok := registerAndToken(t, r, "ab23400@gm.tsuda.ac.jp", "password123") // ab 2023
	_, otherDeptTok := registerAndToken(t, r, "cs24400@gm.tsuda.ac.jp", "password123")

	get := func(token, ownerID string) int {
		return authReq(t, r, http.MethodGet, "/api/v1/friends/"+ownerID+"/timetable", token, nil).Code
	}

	t.Run("private は本人以外403", func(t *testing.T) {
		ownerID, ownerTok := registerWithTimetable(t, r, "ab24410@gm.tsuda.ac.jp", "private")
		if c := get(juniorTok, ownerID); c != http.StatusForbidden {
			t.Errorf("junior: status = %d, want 403", c)
		}
		if c := get(ownerTok, ownerID); c != http.StatusOK {
			t.Errorf("self: status = %d, want 200", c)
		}
	})

	t.Run("all は誰でも200", func(t *testing.T) {
		ownerID, _ := registerWithTimetable(t, r, "ab24411@gm.tsuda.ac.jp", "all")
		if c := get(otherDeptTok, ownerID); c != http.StatusOK {
			t.Errorf("status = %d, want 200", c)
		}
	})

	t.Run("juniors は同学科後輩のみ申請なしで200", func(t *testing.T) {
		ownerID, _ := registerWithTimetable(t, r, "ab24412@gm.tsuda.ac.jp", "juniors")
		if c := get(juniorTok, ownerID); c != http.StatusOK {
			t.Errorf("junior: status = %d, want 200", c)
		}
		if c := get(seniorTok, ownerID); c != http.StatusForbidden {
			t.Errorf("senior: status = %d, want 403", c)
		}
		if c := get(otherDeptTok, ownerID); c != http.StatusForbidden {
			t.Errorf("other dept: status = %d, want 403", c)
		}
	})

	t.Run("friends は承認後のみ200", func(t *testing.T) {
		ownerID, ownerTok := registerWithTimetable(t, r, "ab24413@gm.tsuda.ac.jp", "friends")
		// before friendship: other dept user denied
		if c := get(otherDeptTok, ownerID); c != http.StatusForbidden {
			t.Errorf("pre-friend: status = %d, want 403", c)
		}
		// owner requests other-dept user, who approves
		w := authReq(t, r, http.MethodPost, "/api/v1/friends/request", ownerTok, map[string]any{
			"addressee_id": friendIDFromToken(t, r, otherDeptTok),
		})
		var resp map[string]any
		json.Unmarshal(w.Body.Bytes(), &resp)
		fid := resp["id"].(string)
		authReq(t, r, http.MethodPatch, "/api/v1/friends/"+fid, otherDeptTok, map[string]any{
			"status": "approved",
		})
		if c := get(otherDeptTok, ownerID); c != http.StatusOK {
			t.Errorf("post-friend: status = %d, want 200", c)
		}
	})
}

// friendIDFromToken returns the user id behind a token via GET /me.
func friendIDFromToken(t *testing.T, r *gin.Engine, token string) string {
	t.Helper()
	w := authReq(t, r, http.MethodGet, "/api/v1/me", token, nil)
	var resp map[string]any
	json.Unmarshal(w.Body.Bytes(), &resp)
	return resp["id"].(string)
}
