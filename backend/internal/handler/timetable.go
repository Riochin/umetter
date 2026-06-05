package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/irj0927/umetter/internal/domain"
	"github.com/irj0927/umetter/internal/repository"
)

type TimetableHandler struct {
	repo repository.Repository
}

func NewTimetableHandler(repo repository.Repository) *TimetableHandler {
	return &TimetableHandler{repo: repo}
}

type createTimetableRequest struct {
	ClassID string `json:"class_id" binding:"required"`
	Memo    string `json:"memo"`
}

type updateTimetableRequest struct {
	Memo         *string `json:"memo"`
	CountPresent *int    `json:"count_present"`
	CountAbsent  *int    `json:"count_absent"`
	CountLate    *int    `json:"count_late"`
}

// Create — POST /timetables  自分の時間割に授業を登録
func (h *TimetableHandler) Create(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	var req createTimetableRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	class, err := h.repo.GetClassByID(req.ClassID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if class == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "class not found"})
		return
	}

	entry := &domain.UserTimetable{
		ID:      uuid.New().String(),
		UserID:  userID,
		ClassID: req.ClassID,
		Memo:    req.Memo,
	}

	if err := h.repo.CreateTimetableEntry(entry); err != nil {
		// UNIQUE(user_id, class_id) violation → already registered
		c.JSON(http.StatusConflict, gin.H{"error": "class already registered"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"id": entry.ID})
}

// List — GET /timetables  自分の時間割一覧
func (h *TimetableHandler) List(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	entries, err := h.repo.ListTimetable(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"timetable": entries})
}

// Update — PATCH /timetables/:id  出欠カウント・メモ更新
func (h *TimetableHandler) Update(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	id := c.Param("id")

	var req updateTimetableRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	entry, err := h.repo.GetTimetableEntryByID(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if entry == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "timetable entry not found"})
		return
	}
	if entry.UserID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "not your timetable entry"})
		return
	}

	if req.Memo != nil {
		entry.Memo = *req.Memo
	}
	if req.CountPresent != nil {
		entry.CountPresent = *req.CountPresent
	}
	if req.CountAbsent != nil {
		entry.CountAbsent = *req.CountAbsent
	}
	if req.CountLate != nil {
		entry.CountLate = *req.CountLate
	}

	if err := h.repo.UpdateTimetableEntry(entry); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "updated"})
}
