package domain_test

import (
	"testing"

	"github.com/irj0927/umetter/internal/domain"
)

func TestParseEmail(t *testing.T) {
	tests := []struct {
		name    string
		email   string
		dept    string
		year    int
		wantErr bool
	}{
		{"standard 2文字学科", "ab24001@gm.tsuda.ac.jp", "ab", 2024, false},
		{"1文字学科", "a26001@gm.tsuda.ac.jp", "a", 2026, false},
		{"3文字学科", "pol25001@gm.tsuda.ac.jp", "pol", 2025, false},
		{"年度 00", "cs00001@gm.tsuda.ac.jp", "cs", 2000, false},
		{"年度 99", "cs99001@gm.tsuda.ac.jp", "cs", 2099, false},
		{"ドメイン不一致", "ab24001@gmail.com", "", 0, true},
		{"学科コードなし（数字始まり）", "24001@gm.tsuda.ac.jp", "", 0, true},
		{"空文字", "", "", 0, true},
		{"大文字学科", "AB24001@gm.tsuda.ac.jp", "", 0, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			dept, year, err := domain.ParseEmail(tt.email)
			if (err != nil) != tt.wantErr {
				t.Fatalf("ParseEmail(%q) error = %v, wantErr = %v", tt.email, err, tt.wantErr)
			}
			if err != nil {
				return
			}
			if dept != tt.dept {
				t.Errorf("dept = %q, want %q", dept, tt.dept)
			}
			if year != tt.year {
				t.Errorf("year = %d, want %d", year, tt.year)
			}
		})
	}
}
