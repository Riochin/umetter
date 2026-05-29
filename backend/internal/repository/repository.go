package repository

import "github.com/irj0927/umetter/internal/domain"

// Repository is the interface all handlers depend on.
// Sprint 3/4 will embed PostRepository, FriendshipRepository, etc.
type Repository interface {
	CreateUser(user *domain.User) error
	GetUserByEmail(email string) (*domain.User, error)
	GetUserByID(id string) (*domain.User, error)
	UpdateUser(user *domain.User) error
}
