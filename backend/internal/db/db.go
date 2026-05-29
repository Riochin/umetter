package db

import (
	"database/sql"
	_ "embed"
	"fmt"

	"github.com/irj0927/umetter/internal/config"
	_ "modernc.org/sqlite"
)

//go:embed migrations/001_init.sql
var initSQL string

func Open(cfg *config.Config) (*sql.DB, error) {
	if cfg.DBDriver != "sqlite" {
		return nil, fmt.Errorf("db.Open only handles sqlite; got %q", cfg.DBDriver)
	}

	db, err := sql.Open("sqlite", cfg.DBPath)
	if err != nil {
		return nil, fmt.Errorf("open sqlite: %w", err)
	}

	// Prevent concurrent-write BUSY errors with modernc.org/sqlite
	db.SetMaxOpenConns(1)

	if err := migrate(db); err != nil {
		return nil, fmt.Errorf("migrate: %w", err)
	}

	return db, nil
}

func migrate(db *sql.DB) error {
	if _, err := db.Exec(initSQL); err != nil {
		return err
	}
	return nil
}
