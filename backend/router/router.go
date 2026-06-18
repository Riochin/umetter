package router

import (
	"github.com/gin-gonic/gin"
	"github.com/irj0927/umetter/internal/config"
	"github.com/irj0927/umetter/internal/handler"
	"github.com/irj0927/umetter/internal/middleware"
	"github.com/irj0927/umetter/internal/repository"
)

func New(repo repository.Repository, cfg *config.Config) *gin.Engine {
	r := gin.Default()

	v1 := r.Group("/api/v1")

	authH := handler.NewAuthHandler(repo, cfg)
	auth := v1.Group("/auth")
	auth.POST("/register", authH.Register)
	auth.POST("/login", authH.Login)
	auth.POST("/verify-email", authH.VerifyEmail)

	meH := handler.NewMeHandler(repo)
	postH := handler.NewPostHandler(repo)
	classH := handler.NewClassHandler(repo)
	timetableH := handler.NewTimetableHandler(repo)
	friendH := handler.NewFriendHandler(repo)

	protected := v1.Group("")
	protected.Use(middleware.JWTAuth(cfg.JWTSecret))
	protected.GET("/me", meH.GetMe)
	protected.PATCH("/me/visibility", meH.UpdateVisibility)
	protected.GET("/posts", postH.ListPosts)
	protected.POST("/posts", postH.CreatePost)
	protected.POST("/posts/:id/report", postH.ReportPost)

	protected.GET("/classes", classH.Search)
	protected.POST("/timetables", timetableH.Create)
	protected.GET("/timetables", timetableH.List)
	protected.PATCH("/timetables/:id", timetableH.Update)

	protected.POST("/friends/request", friendH.Request)
	protected.GET("/friends", friendH.List)
	protected.PATCH("/friends/:id", friendH.Respond)
	protected.GET("/friends/:id/timetable", friendH.GetTimetable)

	return r
}
