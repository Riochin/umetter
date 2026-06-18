package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/irj0927/umetter/internal/repository"
)

type ClassHandler struct {
	repo repository.Repository
}

func NewClassHandler(repo repository.Repository) *ClassHandler {
	return &ClassHandler{repo: repo}
}

// Search — GET /classes?keyword=  授業名・教員名で部分一致検索
func (h *ClassHandler) Search(c *gin.Context) {
	keyword := c.Query("keyword")

	classes, err := h.repo.SearchClasses(keyword)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"classes": classes})
}
