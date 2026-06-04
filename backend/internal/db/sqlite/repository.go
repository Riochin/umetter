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

func (r *Repository) IsTeacherAllowedEmail(email string) (bool, error) {
	var exists int
	err := r.db.QueryRow(
		`SELECT 1 FROM teacher_allowed_emails WHERE email = ? LIMIT 1`,
		email,
	).Scan(&exists)

	if errors.Is(err, sql.ErrNoRows) {
		return false, nil
	}
	if err != nil {
		return false, fmt.Errorf("check teacher allowed email: %w", err)
	}
	return true, nil
}

func (r *Repository) SaveEmailVerificationCode(email string, codeHash string, expiresAt string) error {
	_, err := r.db.Exec(
		`INSERT INTO email_verification_codes (email, code_hash, purpose, expires_at)
		 VALUES (?, ?, 'register', ?)
		 ON CONFLICT(email) DO UPDATE SET
		     code_hash = excluded.code_hash,
		     expires_at = excluded.expires_at,
		     created_at = strftime('%Y-%m-%dT%H:%M:%SZ','now')`,
		email,
		codeHash,
		expiresAt,
	)
	if err != nil {
		return fmt.Errorf("save email verification code: %w", err)
	}
	return nil
}

func (r *Repository) GetEmailVerificationCodeHash(email string) (string, string, error) {
	var codeHash string
	var expiresAt string

	err := r.db.QueryRow(
		`SELECT code_hash, expires_at
		 FROM email_verification_codes
		 WHERE email = ?`,
		email,
	).Scan(&codeHash, &expiresAt)

	if errors.Is(err, sql.ErrNoRows) {
		return "", "", nil
	}
	if err != nil {
		return "", "", fmt.Errorf("get email verification code: %w", err)
	}
	return codeHash, expiresAt, nil
}

func (r *Repository) MarkEmailVerified(email string) error {
	_, err := r.db.Exec(
		`INSERT INTO verified_emails (email, verified_at)
		 VALUES (?, strftime('%Y-%m-%dT%H:%M:%SZ','now'))
		 ON CONFLICT(email) DO UPDATE SET
		     verified_at = excluded.verified_at`,
		email,
	)
	if err != nil {
		return fmt.Errorf("mark email verified: %w", err)
	}

	_, err = r.db.Exec(`DELETE FROM email_verification_codes WHERE email = ?`, email)
	if err != nil {
		return fmt.Errorf("delete email verification code: %w", err)
	}

	return nil
}

func (r *Repository) IsEmailVerified(email string) (bool, error) {
	var exists int
	err := r.db.QueryRow(
		`SELECT 1 FROM verified_emails WHERE email = ? LIMIT 1`,
		email,
	).Scan(&exists)

	if errors.Is(err, sql.ErrNoRows) {
		return false, nil
	}
	if err != nil {
		return false, fmt.Errorf("check email verified: %w", err)
	}
	return true, nil
}
