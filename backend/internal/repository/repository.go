package repository

import "github.com/irj0927/umetter/internal/domain"

// Repository is the interface all handlers depend on.
// Sprint 3/4 will embed PostRepository, FriendshipRepository, etc.
type Repository interface {
	CreateUser(user *domain.User) error
	GetUserByEmail(email string) (*domain.User, error)
	GetUserByID(id string) (*domain.User, error)
	UpdateUser(user *domain.User) error

	CreatePost(post *domain.Post) error
	ListPosts(category string) ([]domain.PublicPost, error)
	GetPostByID(id string) (*domain.Post, error)
	CreateReport(report *domain.Report) error

	IsTeacherAllowedEmail(email string) (bool, error)
	SaveEmailVerificationCode(email string, codeHash string, expiresAt string) error
	GetEmailVerificationCodeHash(email string) (string, string, error)
	MarkEmailVerified(email string) error
	IsEmailVerified(email string) (bool, error)

	// Classes & timetables
	SearchClasses(keyword string) ([]domain.Class, error)
	GetClassByID(id string) (*domain.Class, error)
	CreateTimetableEntry(entry *domain.UserTimetable) error
	ListTimetable(userID string) ([]domain.TimetableEntry, error)
	GetTimetableEntryByID(id string) (*domain.UserTimetable, error)
	UpdateTimetableEntry(entry *domain.UserTimetable) error

	// Friendships
	CreateFriendship(f *domain.Friendship) error
	GetFriendshipByID(id string) (*domain.Friendship, error)
	UpdateFriendshipStatus(id, status string) error
	ListFriendships(userID string) ([]domain.Friendship, error)
	GetApprovedFriendship(userA, userB string) (*domain.Friendship, error)
}
