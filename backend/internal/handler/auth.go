package handler

import (
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/irj0927/umetter/internal/config"
	"github.com/irj0927/umetter/internal/domain"
	"github.com/irj0927/umetter/internal/mailer"
	"github.com/irj0927/umetter/internal/middleware"
	"github.com/irj0927/umetter/internal/repository"
	"golang.org/x/crypto/bcrypt"
)

type AuthHandler struct {
	repo   repository.Repository
	cfg    *config.Config
	mailer *mailer.Mailer
}

func NewAuthHandler(repo repository.Repository, cfg *config.Config) *AuthHandler {
	return &AuthHandler{
		repo: repo,
		cfg:  cfg,
		mailer: &mailer.Mailer{
			SMTPHost: cfg.SMTPHost,
			SMTPPort: cfg.SMTPPort,
			SMTPUser: cfg.SMTPUser,
			SMTPPass: cfg.SMTPPass,
			From:     cfg.SMTPFrom,
			Debug:    cfg.EmailDebug,
		},
	}
}

type registerRequest struct {
	Email       string `json:"email" binding:"required,email"`
	Password    string `json:"password" binding:"required,min=8"`
	DisplayName string `json:"display_name"`
}

type loginRequest struct {
	Email    string `json:"email" binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

type verifyEmailRequest struct {
	Email string `json:"email" binding:"required,email"`
	Code  string `json:"code" binding:"required"`
}

type authResponse struct {
	Token string   `json:"token"`
	User  safeUser `json:"user"`
}

type safeUser struct {
	ID                  string `json:"id"`
	Email               string `json:"email"`
	Department          string `json:"department"`
	AdmissionYear       int    `json:"admission_year"`
	DisplayName         string `json:"display_name"`
	Role                string `json:"role"`
	TimetableVisibility string `json:"timetable_visibility"`
}

func toSafeUser(u *domain.User) safeUser {
	return safeUser{
		ID:                  u.ID,
		Email:               u.Email,
		Department:          u.Department,
		AdmissionYear:       u.AdmissionYear,
		DisplayName:         u.DisplayName,
		Role:                u.Role,
		TimetableVisibility: u.TimetableVisibility,
	}
}

func normalizeEmail(email string) string {
	return strings.ToLower(strings.TrimSpace(email))
}

func (h *AuthHandler) Register(c *gin.Context) {
	var req registerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	email := normalizeEmail(req.Email)

	dept := ""
	year := 0
	role := "student"

	parsedDept, parsedYear, parseErr := domain.ParseEmail(email)
	if parseErr == nil {
		dept = parsedDept
		year = parsedYear
	} else {
		allowed, err := h.repo.IsTeacherAllowedEmail(email)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
			return
		}
		if !allowed {
			c.JSON(http.StatusBadRequest, gin.H{"error": "email must be a valid student email or allowed teacher email"})
			return
		}

		role = "faculty"
		dept = "faculty"
		year = 0
	}

	existing, err := h.repo.GetUserByEmail(email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if existing != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "email already registered"})
		return
	}

	passwordHash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	user := &domain.User{
		ID:                  uuid.New().String(),
		Email:               email,
		PasswordHash:        string(passwordHash),
		Department:          dept,
		AdmissionYear:       year,
		DisplayName:         req.DisplayName,
		Role:                role,
		TimetableVisibility: "friends",
	}

	if err := h.repo.CreateUser(user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	code, err := domain.GenerateVerificationCode()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	codeHash, err := bcrypt.GenerateFromPassword([]byte(code), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	expiresAt := time.Now().Add(10 * time.Minute).UTC().Format(time.RFC3339)

	if err := h.repo.SaveEmailVerificationCode(email, string(codeHash), expiresAt); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	if err := h.mailer.SendVerificationCode(email, code); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to send verification email"})
		return
	}

	resp := gin.H{
		"message": "verification code sent",
		"email":   email,
	}

	if h.cfg.EmailDebug {
		resp["debug_code"] = code
	}

	c.JSON(http.StatusAccepted, resp)
}

func (h *AuthHandler) VerifyEmail(c *gin.Context) {
	var req verifyEmailRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	email := normalizeEmail(req.Email)

	codeHash, expiresAtStr, err := h.repo.GetEmailVerificationCodeHash(email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if codeHash == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "verification code not found"})
		return
	}

	expiresAt, err := time.Parse(time.RFC3339, expiresAtStr)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if time.Now().UTC().After(expiresAt) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "verification code expired"})
		return
	}

	if bcrypt.CompareHashAndPassword([]byte(codeHash), []byte(req.Code)) != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid verification code"})
		return
	}

	if err := h.repo.MarkEmailVerified(email); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	user, err := h.repo.GetUserByEmail(email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if user == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	token, err := h.issueJWT(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	c.JSON(http.StatusOK, authResponse{Token: token, User: toSafeUser(user)})
}

func (h *AuthHandler) Login(c *gin.Context) {
	var req loginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	email := normalizeEmail(req.Email)

	user, err := h.repo.GetUserByEmail(email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	// Return 401 regardless of whether email exists to prevent enumeration.
	if user == nil || bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)) != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	verified, err := h.repo.IsEmailVerified(email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if !verified {
		c.JSON(http.StatusForbidden, gin.H{"error": "email not verified"})
		return
	}

	token, err := h.issueJWT(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	c.JSON(http.StatusOK, authResponse{Token: token, User: toSafeUser(user)})
}

func (h *AuthHandler) issueJWT(user *domain.User) (string, error) {
	exp := time.Now().Add(time.Duration(h.cfg.JWTExpireHours) * time.Hour)
	claims := &middleware.Claims{
		RegisteredClaims: jwt.RegisteredClaims{
			Subject:   user.ID,
			ExpiresAt: jwt.NewNumericDate(exp),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
		Role: user.Role,
	}
	return jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString([]byte(h.cfg.JWTSecret))
}
