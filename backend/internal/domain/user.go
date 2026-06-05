package domain

import (
	"errors"
	"regexp"
	"strconv"
)

var emailRe = regexp.MustCompile(`^([a-z]+)(\d{2})\d+@gm\.tsuda\.ac\.jp$`)

// Timetable visibility tiers.
const (
	VisibilityPrivate = "private"
	VisibilityFriends = "friends"
	VisibilityJuniors = "juniors"
	VisibilityAll     = "all"
)

// IsValidVisibility reports whether v is one of the allowed visibility tiers.
func IsValidVisibility(v string) bool {
	switch v {
	case VisibilityPrivate, VisibilityFriends, VisibilityJuniors, VisibilityAll:
		return true
	default:
		return false
	}
}

// CanViewTimetable decides whether viewer may read owner's timetable, based on
// owner's visibility tier (仕様書 5.5「縦の繋がり自動承認」).
//   - owner viewing self: always allowed
//   - all: anyone
//   - private: no one but self
//   - friends: only a mutually-approved friend
//   - juniors: an approved friend, OR a same-department junior
//     (same department and a later admission year) without a friend request
func CanViewTimetable(owner, viewer *User, approvedFriend bool) bool {
	if owner.ID == viewer.ID {
		return true
	}
	switch owner.TimetableVisibility {
	case VisibilityAll:
		return true
	case VisibilityPrivate:
		return false
	case VisibilityFriends:
		return approvedFriend
	case VisibilityJuniors:
		if approvedFriend {
			return true
		}
		return owner.Department == viewer.Department && viewer.AdmissionYear > owner.AdmissionYear
	default:
		return false
	}
}

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
