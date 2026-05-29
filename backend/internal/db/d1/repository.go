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

func (r *Repository) CreateUser(_ *domain.User) error          { return errNotImplemented }
func (r *Repository) GetUserByEmail(_ string) (*domain.User, error) { return nil, errNotImplemented }
func (r *Repository) GetUserByID(_ string) (*domain.User, error)    { return nil, errNotImplemented }
func (r *Repository) UpdateUser(_ *domain.User) error          { return errNotImplemented }
