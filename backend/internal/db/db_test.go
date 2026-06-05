package db

import (
	"path/filepath"
	"testing"

	"github.com/irj0927/umetter/internal/config"
)

// TestMigrateIdempotent ensures opening the same file-backed DB twice does not
// re-run already-applied migrations (ALTER TABLE ADD COLUMN would otherwise
// fail with "duplicate column name" on the second startup).
func TestMigrateIdempotent(t *testing.T) {
	dbPath := filepath.Join(t.TempDir(), "umetter_test.db")
	cfg := &config.Config{DBDriver: "sqlite", DBPath: dbPath}

	first, err := Open(cfg)
	if err != nil {
		t.Fatalf("first open: %v", err)
	}
	first.Close()

	second, err := Open(cfg)
	if err != nil {
		t.Fatalf("second open (migrations not idempotent): %v", err)
	}
	defer second.Close()

	// New columns from 004 must exist and be queryable.
	if _, err := second.Exec(`INSERT INTO classes (id, class_code, name, day_of_week, period, semester) VALUES ('t1', 'TC101', 'Test', 1, 1, 'first')`); err != nil {
		t.Fatalf("insert with new columns: %v", err)
	}

	var applied int
	if err := second.QueryRow(`SELECT COUNT(*) FROM schema_migrations`).Scan(&applied); err != nil {
		t.Fatalf("count schema_migrations: %v", err)
	}
	if applied < 4 {
		t.Errorf("applied migrations = %d, want >= 4", applied)
	}
}
