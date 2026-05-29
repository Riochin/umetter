package domain

import (
	"errors"
	"regexp"
	"strconv"
)

var emailRe = regexp.MustCompile(`^([a-z]+)(\d{2})\d+@gm\.tsuda\.ac\.jp$`)

// ParseEmail extracts department code and 4-digit admission year.
// "ab24123@gm.tsuda.ac.jp" → ("ab", 2024, nil)
func ParseEmail(email string) (dept string, year int, err error) {
	m := emailRe.FindStringSubmatch(email)
	if m == nil {
		return "", 0, errors.New("email must match pattern [dept][YY][num]@gm.tsuda.ac.jp")
	}
	twoDigit, _ := strconv.Atoi(m[2])
	return m[1], 2000 + twoDigit, nil
}

type User struct {
	ID                  string `json:"id"`
	Email               string `json:"email"`
	PasswordHash        string `json:"-"`
	Department          string `json:"department"`
	AdmissionYear       int    `json:"admission_year"`
	DisplayName         string `json:"display_name"`
	Role                string `json:"role"`
	TimetableVisibility string `json:"timetable_visibility"`
	CreatedAt           string `json:"created_at"`
}
