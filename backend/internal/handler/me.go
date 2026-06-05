package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/irj0927/umetter/internal/domain"
	"github.com/irj0927/umetter/internal/repository"
)

type MeHandler struct {
	repo repository.Repository
}

func NewMeHandler(repo repository.Repository) *MeHandler {
	return &MeHandler{repo: repo}
}

func (h *MeHandler) GetMe(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	user, err := h.repo.GetUserByID(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if user == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	c.JSON(http.StatusOK, toSafeUser(user))
}

type updateVisibilityRequest struct {
	TimetableVisibility string `json:"timetable_visibility" binding:"required"`
}

// UpdateVisibility — PATCH /me/visibility  公開範囲変更
func (h *MeHandler) UpdateVisibility(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	var req updateVisibilityRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if !domain.IsValidVisibility(req.TimetableVisibility) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid timetable_visibility"})
		return
	}

	user, err := h.repo.GetUserByID(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if user == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	user.TimetableVisibility = req.TimetableVisibility
	if err := h.repo.UpdateUser(user); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	c.JSON(http.StatusOK, toSafeUser(user))
}
