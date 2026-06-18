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

// ---------------------------------------------------------------------------
// Classes & timetables
// ---------------------------------------------------------------------------

func (r *Repository) SearchClasses(keyword string) ([]domain.Class, error) {
	query := `SELECT id, class_code, name, teacher_name, day_of_week, period, room,
	                 term, semester, level, credits, remarks, is_canceled
	          FROM classes`
	args := []any{}

	if keyword != "" {
		query += ` WHERE name LIKE ? OR teacher_name LIKE ?`
		like := "%" + keyword + "%"
		args = append(args, like, like)
	}

	query += ` ORDER BY day_of_week, period`

	rows, err := r.db.Query(query, args...)
	if err != nil {
		return nil, fmt.Errorf("search classes: %w", err)
	}
	defer rows.Close()

	classes := []domain.Class{}
	for rows.Next() {
		c, err := scanClass(rows)
		if err != nil {
			return nil, err
		}
		classes = append(classes, *c)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate classes: %w", err)
	}
	return classes, nil
}

func (r *Repository) GetClassByID(id string) (*domain.Class, error) {
	row := r.db.QueryRow(
		`SELECT id, class_code, name, teacher_name, day_of_week, period, room,
		        term, semester, level, credits, remarks, is_canceled
		 FROM classes WHERE id = ?`, id,
	)
	c, err := scanClass(row)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return c, nil
}

// scanClass scans a class row from either *sql.Row or *sql.Rows.
func scanClass(s interface{ Scan(...any) error }) (*domain.Class, error) {
	var c domain.Class
	var isCanceled int
	if err := s.Scan(
		&c.ID, &c.ClassCode, &c.Name, &c.TeacherName,
		&c.DayOfWeek, &c.Period, &c.Room,
		&c.Term, &c.Semester, &c.Level, &c.Credits, &c.Remarks, &isCanceled,
	); err != nil {
		return nil, err
	}
	c.IsCanceled = isCanceled == 1
	return &c, nil
}

func (r *Repository) CreateTimetableEntry(e *domain.UserTimetable) error {
	_, err := r.db.Exec(
		`INSERT INTO user_timetables
			(id, user_id, class_id, memo, count_present, count_absent, count_late, created_at)
		 VALUES (?, ?, ?, ?, ?, ?, ?, strftime('%Y-%m-%dT%H:%M:%SZ','now'))`,
		e.ID, e.UserID, e.ClassID, e.Memo,
		e.CountPresent, e.CountAbsent, e.CountLate,
	)
	if err != nil {
		return fmt.Errorf("create timetable entry: %w", err)
	}
	return nil
}

func (r *Repository) ListTimetable(userID string) ([]domain.TimetableEntry, error) {
	rows, err := r.db.Query(
		`SELECT t.id, c.id, c.class_code, c.name, c.teacher_name, c.day_of_week, c.period,
		        c.room, c.term, c.semester, c.level, c.credits, c.remarks, c.is_canceled,
		        t.memo, t.count_present, t.count_absent, t.count_late, t.created_at
		 FROM user_timetables t
		 JOIN classes c ON c.id = t.class_id
		 WHERE t.user_id = ?
		 ORDER BY c.day_of_week, c.period`, userID,
	)
	if err != nil {
		return nil, fmt.Errorf("list timetable: %w", err)
	}
	defer rows.Close()

	entries := []domain.TimetableEntry{}
	for rows.Next() {
		var e domain.TimetableEntry
		var isCanceled int
		if err := rows.Scan(
			&e.ID, &e.ClassID, &e.ClassCode, &e.Name, &e.TeacherName, &e.DayOfWeek, &e.Period,
			&e.Room, &e.Term, &e.Semester, &e.Level, &e.Credits, &e.Remarks, &isCanceled,
			&e.Memo, &e.CountPresent, &e.CountAbsent, &e.CountLate, &e.CreatedAt,
		); err != nil {
			return nil, fmt.Errorf("scan timetable entry: %w", err)
		}
		e.IsCanceled = isCanceled == 1
		entries = append(entries, e)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate timetable: %w", err)
	}
	return entries, nil
}

func (r *Repository) GetTimetableEntryByID(id string) (*domain.UserTimetable, error) {
	row := r.db.QueryRow(
		`SELECT id, user_id, class_id, memo, count_present, count_absent, count_late, created_at
		 FROM user_timetables WHERE id = ?`, id,
	)
	var e domain.UserTimetable
	err := row.Scan(
		&e.ID, &e.UserID, &e.ClassID, &e.Memo,
		&e.CountPresent, &e.CountAbsent, &e.CountLate, &e.CreatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("scan timetable entry: %w", err)
	}
	return &e, nil
}

func (r *Repository) UpdateTimetableEntry(e *domain.UserTimetable) error {
	_, err := r.db.Exec(
		`UPDATE user_timetables
		 SET memo = ?, count_present = ?, count_absent = ?, count_late = ?
		 WHERE id = ?`,
		e.Memo, e.CountPresent, e.CountAbsent, e.CountLate, e.ID,
	)
	if err != nil {
		return fmt.Errorf("update timetable entry: %w", err)
	}
	return nil
}

// ---------------------------------------------------------------------------
// Friendships
// ---------------------------------------------------------------------------

func (r *Repository) CreateFriendship(f *domain.Friendship) error {
	_, err := r.db.Exec(
		`INSERT INTO friendships (id, requester_id, addressee_id, status, updated_at)
		 VALUES (?, ?, ?, ?, strftime('%Y-%m-%dT%H:%M:%SZ','now'))`,
		f.ID, f.RequesterID, f.AddresseeID, f.Status,
	)
	if err != nil {
		return fmt.Errorf("create friendship: %w", err)
	}
	return nil
}

func (r *Repository) GetFriendshipByID(id string) (*domain.Friendship, error) {
	row := r.db.QueryRow(
		`SELECT id, requester_id, addressee_id, status, created_at, updated_at
		 FROM friendships WHERE id = ?`, id,
	)
	return scanFriendship(row)
}

func (r *Repository) UpdateFriendshipStatus(id, status string) error {
	_, err := r.db.Exec(
		`UPDATE friendships SET status = ?, updated_at = strftime('%Y-%m-%dT%H:%M:%SZ','now') WHERE id = ?`, status, id,
	)
	if err != nil {
		return fmt.Errorf("update friendship status: %w", err)
	}
	return nil
}

func (r *Repository) ListFriendships(userID string) ([]domain.Friendship, error) {
	rows, err := r.db.Query(
		`SELECT id, requester_id, addressee_id, status, created_at, updated_at
		 FROM friendships
		 WHERE requester_id = ? OR addressee_id = ?
		 ORDER BY created_at DESC`, userID, userID,
	)
	if err != nil {
		return nil, fmt.Errorf("list friendships: %w", err)
	}
	defer rows.Close()

	friendships := []domain.Friendship{}
	for rows.Next() {
		var f domain.Friendship
		if err := rows.Scan(
			&f.ID, &f.RequesterID, &f.AddresseeID, &f.Status, &f.CreatedAt, &f.UpdatedAt,
		); err != nil {
			return nil, fmt.Errorf("scan friendship: %w", err)
		}
		friendships = append(friendships, f)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("iterate friendships: %w", err)
	}
	return friendships, nil
}

func (r *Repository) GetApprovedFriendship(userA, userB string) (*domain.Friendship, error) {
	row := r.db.QueryRow(
		`SELECT id, requester_id, addressee_id, status, created_at, updated_at
		 FROM friendships
		 WHERE status = 'approved'
		   AND ((requester_id = ? AND addressee_id = ?)
		     OR (requester_id = ? AND addressee_id = ?))`,
		userA, userB, userB, userA,
	)
	return scanFriendship(row)
}

func scanFriendship(row *sql.Row) (*domain.Friendship, error) {
	var f domain.Friendship
	err := row.Scan(
		&f.ID, &f.RequesterID, &f.AddresseeID, &f.Status, &f.CreatedAt, &f.UpdatedAt,
	)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("scan friendship: %w", err)
	}
	return &f, nil
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
