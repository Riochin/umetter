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
	"github.com/irj0927/umetter/internal/middleware"
	"github.com/irj0927/umetter/internal/repository"
	"golang.org/x/crypto/bcrypt"
)

type AuthHandler struct {
	repo repository.Repository
	cfg  *config.Config
}

func NewAuthHandler(repo repository.Repository, cfg *config.Config) *AuthHandler {
	return &AuthHandler{repo: repo, cfg: cfg}
}

type registerRequest struct {
	Email       string `json:"email"        binding:"required,email"`
	Password    string `json:"password"     binding:"required,min=8"`
	DisplayName string `json:"display_name"`
}

type loginRequest struct {
	Email    string `json:"email"    binding:"required,email"`
	Password string `json:"password" binding:"required"`
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

func (h *AuthHandler) Register(c *gin.Context) {
	var req registerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if !strings.HasSuffix(req.Email, "@gm.tsuda.ac.jp") {
		c.JSON(http.StatusBadRequest, gin.H{"error": "email must be a @gm.tsuda.ac.jp address"})
		return
	}

	dept, year, err := domain.ParseEmail(req.Email)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	existing, err := h.repo.GetUserByEmail(req.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if existing != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "email already registered"})
		return
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	user := &domain.User{
		ID:                  uuid.New().String(),
		Email:               req.Email,
		PasswordHash:        string(hash),
		Department:          dept,
		AdmissionYear:       year,
		DisplayName:         req.DisplayName,
		Role:                "student",
		TimetableVisibility: "friends",
	}

	if err := h.repo.CreateUser(user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	token, err := h.issueJWT(user)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	c.JSON(http.StatusCreated, authResponse{Token: token, User: toSafeUser(user)})
}

func (h *AuthHandler) Login(c *gin.Context) {
	var req loginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	user, err := h.repo.GetUserByEmail(req.Email)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	// Return 401 regardless of whether email exists to prevent enumeration
	if user == nil || bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)) != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
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
