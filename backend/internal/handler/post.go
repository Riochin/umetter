package handler

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/irj0927/umetter/internal/domain"
	"github.com/irj0927/umetter/internal/repository"
)

type PostHandler struct {
	repo repository.Repository
}

func NewPostHandler(repo repository.Repository) *PostHandler {
	return &PostHandler{repo: repo}
}

type createPostRequest struct {
	Body          string `json:"body" binding:"required,max=280"`
	Category      string `json:"category"`
	AttachmentURL string `json:"attachment_url"`
}

type reportPostRequest struct {
	Reason string `json:"reason" binding:"required"`
}

func (h *PostHandler) ListPosts(c *gin.Context) {
	category := c.Query("category")

	posts, err := h.repo.ListPosts(category)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"posts": posts})
}

func (h *PostHandler) CreatePost(c *gin.Context) {
	userID := c.MustGet("userID").(string)

	var req createPostRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	category := req.Category
	if category == "" {
		category = "all"
	}

	post := &domain.Post{
		ID:            uuid.New().String(),
		AuthorID:      userID,
		PostType:      0,
		Category:      category,
		Body:          req.Body,
		AttachmentURL: req.AttachmentURL,
		IsPinned:      false,
	}

	if err := h.repo.CreatePost(post); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"id": post.ID})
}

func (h *PostHandler) ReportPost(c *gin.Context) {
	userID := c.MustGet("userID").(string)
	postID := c.Param("id")

	var req reportPostRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	post, err := h.repo.GetPostByID(postID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "internal error"})
		return
	}
	if post == nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "post not found"})
		return
	}

	report := &domain.Report{
		ID:         uuid.New().String(),
		PostID:     postID,
		ReporterID: userID,
		Reason:     req.Reason,
	}

	if err := h.repo.CreateReport(report); err != nil {
		c.JSON(http.StatusConflict, gin.H{"error": "report already exists or invalid"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "reported"})
}