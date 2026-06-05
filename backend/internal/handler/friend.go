package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/irj0927/umetter/internal/domain"
	"github.com/irj0927/umetter/internal/repository"
)

type FriendHandler struct {
	repo repository.Repository
}

func NewFriendHandler(repo repository.Repository) *FriendHandler {
	return &FriendHandler{repo: repo}
}

type friendRequestBody struct {
	AddresseeID string `json:"addressee_id" binding:"required"`
}

type friendRespondBody struct {
	Status string `json:"status" binding:"required"`
}

// Request — POST /friends/request  友達申請
func (h *FriendHandler) Request(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	var req friendRequestBody
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if req.AddresseeID == userID {
		c.JSON(http.StatusBadRequest, gin.H{"error": "cannot friend yourself"})
		return
	}

	addressee, err := h.repo.GetUserByID(req.AddresseeID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if addressee == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	friendship := &domain.Friendship{
		ID:          uuid.New().String(),
		RequesterID: userID,
		AddresseeID: req.AddresseeID,
		Status:      domain.FriendshipPending,
	}

	if err := h.repo.CreateFriendship(friendship); err != nil {
		// UNIQUE(requester_id, addressee_id) violation → request already sent
		c.JSON(http.StatusConflict, gin.H{"error": "friend request already exists"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"id": friendship.ID})
}

// Respond — PATCH /friends/:id  承認/拒否（addressee のみ可）
func (h *FriendHandler) Respond(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	id := c.Param("id")

	var req friendRespondBody
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	if req.Status != domain.FriendshipApproved && req.Status != domain.FriendshipRejected {
		c.JSON(http.StatusBadRequest, gin.H{"error": "status must be 'approved' or 'rejected'"})
		return
	}

	friendship, err := h.repo.GetFriendshipByID(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if friendship == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "friend request not found"})
		return
	}
	if friendship.AddresseeID != userID {
		c.JSON(http.StatusForbidden, gin.H{"error": "only the addressee can respond"})
		return
	}
	if friendship.Status != domain.FriendshipPending {
		c.JSON(http.StatusConflict, gin.H{"error": "request already resolved"})
		return
	}

	if err := h.repo.UpdateFriendshipStatus(id, req.Status); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": req.Status})
}

// List — GET /friends  自分が関与する友達関係一覧（status付き）
func (h *FriendHandler) List(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	friendships, err := h.repo.ListFriendships(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"friendships": friendships})
}

// GetTimetable — GET /friends/:userId/timetable  公開範囲チェック付き友達時間割閲覧
func (h *FriendHandler) GetTimetable(c *gin.Context) {
	viewerID := c.MustGet("userID").(string)
	ownerID := c.Param("id")

	owner, err := h.repo.GetUserByID(ownerID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if owner == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	viewer, err := h.repo.GetUserByID(viewerID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if viewer == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
		return
	}

	approved := false
	if owner.ID != viewer.ID {
		f, err := h.repo.GetApprovedFriendship(viewerID, ownerID)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
			return
		}
		approved = f != nil
	}

	if !domain.CanViewTimetable(owner, viewer, approved) {
		c.JSON(http.StatusForbidden, gin.H{"error": "not authorized to view this timetable"})
		return
	}

	entries, err := h.repo.ListTimetable(ownerID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"timetable": entries})
}
