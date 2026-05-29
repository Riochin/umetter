package middleware_test

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/irj0927/umetter/internal/middleware"
)

const testSecret = "test-secret-middleware"

func makeToken(t *testing.T, subject, role string, expired bool) string {
	t.Helper()
	exp := time.Now().Add(time.Hour)
	if expired {
		exp = time.Now().Add(-time.Hour)
	}
	claims := &middleware.Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   subject,
			ExpiresAt: jwt.NewNumericDate(exp),
		},
		Role: role,
	}
	tok, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString([]byte(testSecret))
	if err != nil {
		t.Fatal(err)
	}
	return tok
}

func newTestRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.GET("/protected", middleware.JWTAuth(testSecret), func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"userID": c.MustGet("userID"),
			"role":   c.MustGet("role"),
		})
	})
	return r
}

func TestJWTAuth(t *testing.T) {
	r := newTestRouter()

	tests := []struct {
		name       string
		authHeader string
		wantStatus int
	}{
		{"Authorizationヘッダーなし", "", http.StatusUnauthorized},
		{"Bearerプレフィックスなし", "Token abc", http.StatusUnauthorized},
		{"不正なトークン文字列", "Bearer invalid.token.here", http.StatusUnauthorized},
		{"期限切れトークン", "Bearer " + makeToken(t, "u1", "student", true), http.StatusUnauthorized},
		{"別シークレットで署名", "Bearer " + func() string {
			claims := &middleware.Claims{
				RegisteredClaims: jwt.RegisteredClaims{
					Subject:   "u1",
					ExpiresAt: jwt.NewNumericDate(time.Now().Add(time.Hour)),
				},
			}
			tok, _ := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString([]byte("wrong-secret"))
			return tok
		}(), http.StatusUnauthorized},
		{"有効なトークン", "Bearer " + makeToken(t, "u1", "student", false), http.StatusOK},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req := httptest.NewRequest(http.MethodGet, "/protected", nil)
			if tt.authHeader != "" {
				req.Header.Set("Authorization", tt.authHeader)
			}
			w := httptest.NewRecorder()
			r.ServeHTTP(w, req)
			if w.Code != tt.wantStatus {
				t.Errorf("status = %d, want %d", w.Code, tt.wantStatus)
			}
		})
	}
}

func TestJWTAuthContextValues(t *testing.T) {
	r := newTestRouter()
	token := makeToken(t, "user-id-123", "admin", false)

	req := httptest.NewRequest(http.MethodGet, "/protected", nil)
	req.Header.Set("Authorization", "Bearer "+token)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("status = %d, want 200", w.Code)
	}
}
