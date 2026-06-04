package main

import (
	"database/sql"
	"encoding/csv"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"

	_ "modernc.org/sqlite"
)

func main() {
	csvPath := flag.String("csv", "./data/teacher_emails_2026.csv", "path to teacher emails CSV")
	dbPath := flag.String("db", "./umetter.db", "path to SQLite database")
	flag.Parse()

	db, err := sql.Open("sqlite", *dbPath)
	if err != nil {
		log.Fatalf("open db: %v", err)
	}
	defer db.Close()

	if err := ensureTable(db); err != nil {
		log.Fatalf("ensure table: %v", err)
	}

	file, err := os.Open(*csvPath)
	if err != nil {
		log.Fatalf("open csv: %v", err)
	}
	defer file.Close()

	reader := csv.NewReader(file)
	reader.FieldsPerRecord = -1

	rows, err := reader.ReadAll()
	if err != nil {
		log.Fatalf("read csv: %v", err)
	}

	headerIndex := -1
	emailCol := -1
	nameCol := -1

	for i, row := range rows {
		for j, col := range row {
			col = strings.TrimSpace(col)
			if col == "連絡先メールアドレス" {
				headerIndex = i
				emailCol = j
			}
			if col == "氏名" {
				nameCol = j
			}
		}
		if headerIndex != -1 {
			break
		}
	}

	if headerIndex == -1 || emailCol == -1 {
		log.Fatal("email column not found: 連絡先メールアドレス")
	}

	inserted := 0
	skipped := 0

	for _, row := range rows[headerIndex+1:] {
		if emailCol >= len(row) {
			skipped++
			continue
		}

		email := normalizeEmail(row[emailCol])
		if email == "" {
			skipped++
			continue
		}

		name := ""
		if nameCol >= 0 && nameCol < len(row) {
			name = strings.TrimSpace(row[nameCol])
		}

		ok, err := insertTeacherEmail(db, email, name)
		if err != nil {
			log.Fatalf("insert teacher email: %v", err)
		}
		if ok {
			inserted++
		} else {
			skipped++
		}
	}

	fmt.Printf("import finished: inserted=%d skipped=%d\n", inserted, skipped)
}

func ensureTable(db *sql.DB) error {
	_, err := db.Exec(`
		CREATE TABLE IF NOT EXISTS teacher_allowed_emails (
			email      TEXT NOT NULL PRIMARY KEY,
			name       TEXT NOT NULL DEFAULT '',
			source     TEXT NOT NULL DEFAULT 'manual',
			created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
		);
	`)
	return err
}

func insertTeacherEmail(db *sql.DB, email string, name string) (bool, error) {
	result, err := db.Exec(
		`INSERT OR IGNORE INTO teacher_allowed_emails (email, name, source)
		 VALUES (?, ?, 'official_2026')`,
		email,
		name,
	)
	if err != nil {
		return false, err
	}

	affected, err := result.RowsAffected()
	if err != nil {
		return false, err
	}

	return affected > 0, nil
}

func normalizeEmail(raw string) string {
	email := strings.TrimSpace(raw)
	email = strings.TrimPrefix(email, "mailto:")
	email = strings.ToLower(email)

	if email == "" {
		return ""
	}

	if !strings.Contains(email, "@") {
		return ""
	}

	return email
}
