package sqlite

import (
	"database/sql"
	"errors"
	"fmt"

	"github.com/irj0927/umetter/internal/domain"
)

type Repository struct {
	db *sql.DB
}

func NewRepository(db *sql.DB) *Repository {
	return &Repository{db: db}
}

func (r *Repository) CreateUser(user *domain.User) error {
	_, err := r.db.Exec(
		`INSERT INTO users
			(id, email, password_hash, department, admission_year, display_name, role, timetable_visibility)
		 VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
		user.ID, user.Email, user.PasswordHash,
		user.Department, user.AdmissionYear, user.DisplayName,
		user.Role, user.TimetableVisibility,
	)
	if err != nil {
		return fmt.Errorf("create user: %w", err)
	}
	return nil
}

func (r *Repository) GetUserByEmail(email string) (*domain.User, error) {
	row := r.db.QueryRow(
		`SELECT id, email, password_hash, department, admission_year,
		        display_name, role, timetable_visibility, created_at
		 FROM users WHERE email = ?`, email,
	)
	return scanUser(row)
}

func (r *Repository) GetUserByID(id string) (*domain.User, error) {
	row := r.db.QueryRow(
		`SELECT id, email, password_hash, department, admission_year,
		        display_name, role, timetable_visibility, created_at
		 FROM users WHERE id = ?`, id,
	)
	return scanUser(row)
}

func (r *Repository) UpdateUser(user *domain.User) error {
	_, err := r.db.Exec(
		`UPDATE users SET display_name = ?, timetable_visibility = ? WHERE id = ?`,
		user.DisplayName, user.TimetableVisibility, user.ID,
	)
	if err != nil {
		return fmt.Errorf("update user: %w", err)
	}
	return nil
}

func scanUser(row *sql.Row) (*domain.User, error) {
	u := &domain.User{}
	err := row.Scan(
		&u.ID, &u.Email, &u.PasswordHash,
		&u.Department, &u.AdmissionYear, &u.DisplayName,
		&u.Role, &u.TimetableVisibility, &u.CreatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("scan user: %w", err)
	}
	return u, nil
}
