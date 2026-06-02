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

func (r *Repository) CreatePost(post *domain.Post) error {
	_, err := r.db.Exec(
		`INSERT INTO posts
			(id, author_id, post_type, category, body, attachment_url, is_pinned)
		 VALUES (?, ?, ?, ?, ?, ?, ?)`,
		post.ID,
		post.AuthorID,
		post.PostType,
		post.Category,
		post.Body,
		post.AttachmentURL,
		boolToInt(post.IsPinned),
	)
	if err != nil {
		return fmt.Errorf("create post: %w", err)
	}
	return nil
}

func (r *Repository) ListPosts(category string) ([]domain.PublicPost, error) {
	query := `SELECT id, post_type, category, body, attachment_url, is_pinned, created_at
	          FROM posts`
	args := []any{}

	if category != "" && category != "all" {
		query += ` WHERE category = ?`
		args = append(args, category)
	}

	query += ` ORDER BY created_at DESC`

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, fmt.Errorf("list posts: %w", err)
	}
	defer rows.Close()

	posts := []domain.PublicPost{}
	for rows.Next() {
		var p domain.PublicPost
		var isPinned int

		if err := rows.Scan(
			&p.ID,
			&p.PostType,
			&p.Category,
			&p.Body,
			&p.AttachmentURL,
			&isPinned,
			&p.CreatedAt,
		); err != nil {
			return nil, fmt.Errorf("scan post: %w", err)
		}

		p.IsPinned = isPinned == 1
		posts = append(posts, p)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate posts: %w", err)
	}

	return posts, nil
}

func (r *Repository) GetPostByID(id string) (*domain.Post, error) {
	row := r.db.QueryRow(
		`SELECT id, author_id, post_type, category, body, attachment_url, is_pinned, created_at
		 FROM posts
		 WHERE id = ?`,
		id,
	)

	var p domain.Post
	var isPinned int

	err := row.Scan(
		&p.ID,
		&p.AuthorID,
		&p.PostType,
		&p.Category,
		&p.Body,
		&p.AttachmentURL,
		&isPinned,
		&p.CreatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("scan post: %w", err)
	}

	p.IsPinned = isPinned == 1
	return &p, nil
}

func (r *Repository) CreateReport(report *domain.Report) error {
	_, err := r.db.Exec(
		`INSERT INTO reports
			(id, post_id, reporter_id, reason)
		 VALUES (?, ?, ?, ?)`,
		report.ID,
		report.PostID,
		report.ReporterID,
		report.Reason,
	)
	if err != nil {
		return fmt.Errorf("create report: %w", err)
	}
	return nil
}

func boolToInt(v bool) int {
	if v {
		return 1
	}
	return 0
}
