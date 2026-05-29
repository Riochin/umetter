package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
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
