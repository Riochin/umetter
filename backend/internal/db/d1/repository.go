package d1

import (
	"errors"

	"github.com/irj0927/umetter/internal/config"
	"github.com/irj0927/umetter/internal/domain"
)

// Repository is a stub. Sprint 4 will implement D1 REST API calls.
type Repository struct {
	cfg *config.Config
}

func NewRepository(cfg *config.Config) *Repository {
	return &Repository{cfg: cfg}
}

var errNotImplemented = errors.New("D1 repository not implemented yet (Sprint 4)")

func (r *Repository) CreateUser(_ *domain.User) error               { return errNotImplemented }
func (r *Repository) GetUserByEmail(_ string) (*domain.User, error) { return nil, errNotImplemented }
func (r *Repository) GetUserByID(_ string) (*domain.User, error)    { return nil, errNotImplemented }
func (r *Repository) UpdateUser(_ *domain.User) error               { return errNotImplemented }

func (r *Repository) CreatePost(_ *domain.Post) error {
	return errNotImplemented
}

func (r *Repository) ListPosts(_ string) ([]domain.PublicPost, error) {
	return nil, errNotImplemented
}

func (r *Repository) GetPostByID(_ string) (*domain.Post, error) {
	return nil, errNotImplemented
}

func (r *Repository) CreateReport(_ *domain.Report) error {
	return errNotImplemented
}

func (r *Repository) IsTeacherAllowedEmail(_ string) (bool, error) {
	return false, errNotImplemented
}

func (r *Repository) SaveEmailVerificationCode(_ string, _ string, _ string) error {
	return errNotImplemented
}

func (r *Repository) GetEmailVerificationCodeHash(_ string) (string, string, error) {
	return "", "", errNotImplemented
}

func (r *Repository) MarkEmailVerified(_ string) error {
	return errNotImplemented
}

func (r *Repository) IsEmailVerified(_ string) (bool, error) {
	return false, errNotImplemented
}

func (r *Repository) SearchClasses(_ string) ([]domain.Class, error) { return nil, errNotImplemented }
func (r *Repository) GetClassByID(_ string) (*domain.Class, error)   { return nil, errNotImplemented }

func (r *Repository) CreateTimetableEntry(_ *domain.UserTimetable) error { return errNotImplemented }

func (r *Repository) ListTimetable(_ string) ([]domain.TimetableEntry, error) {
	return nil, errNotImplemented
}

func (r *Repository) GetTimetableEntryByID(_ string) (*domain.UserTimetable, error) {
	return nil, errNotImplemented
}

func (r *Repository) UpdateTimetableEntry(_ *domain.UserTimetable) error { return errNotImplemented }

func (r *Repository) CreateFriendship(_ *domain.Friendship) error { return errNotImplemented }

func (r *Repository) GetFriendshipByID(_ string) (*domain.Friendship, error) {
	return nil, errNotImplemented
}

func (r *Repository) UpdateFriendshipStatus(_, _ string) error { return errNotImplemented }

func (r *Repository) ListFriendships(_ string) ([]domain.Friendship, error) {
	return nil, errNotImplemented
}

func (r *Repository) GetApprovedFriendship(_, _ string) (*domain.Friendship, error) {
	return nil, errNotImplemented
}
