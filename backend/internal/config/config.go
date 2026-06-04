package config

import (
	"fmt"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	DBDriver       string
	DBPath         string
	D1AccountID    string
	D1DatabaseID   string
	D1APIToken     string
	JWTSecret      string
	JWTExpireHours int
	Port           string

	EmailDebug bool
	SMTPHost   string
	SMTPPort   string
	SMTPUser   string
	SMTPPass   string
	SMTPFrom   string
}

func Load() (*Config, error) {
	_ = godotenv.Load()

	expireHours := 720
	if s := os.Getenv("JWT_EXPIRE_HOURS"); s != "" {
		v, err := strconv.Atoi(s)
		if err != nil {
			return nil, fmt.Errorf("invalid JWT_EXPIRE_HOURS: %w", err)
		}
		expireHours = v
	}

	driver := os.Getenv("DB_DRIVER")
	if driver == "" {
		driver = "sqlite"
	}

	dbPath := os.Getenv("DB_PATH")
	if dbPath == "" {
		dbPath = "./umetter.db"
	}

	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return nil, fmt.Errorf("JWT_SECRET must be set")
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	emailDebug := true
	if s := os.Getenv("EMAIL_DEBUG"); s != "" {
		v, err := strconv.ParseBool(s)
		if err != nil {
			return nil, fmt.Errorf("invalid EMAIL_DEBUG: %w", err)
		}
		emailDebug = v
	}

	smtpPort := os.Getenv("SMTP_PORT")
	if smtpPort == "" {
		smtpPort = "587"
	}

	smtpFrom := os.Getenv("SMTP_FROM")
	if smtpFrom == "" {
		smtpFrom = os.Getenv("SMTP_USER")
	}

	return &Config{
		DBDriver:       driver,
		DBPath:         dbPath,
		D1AccountID:    os.Getenv("D1_ACCOUNT_ID"),
		D1DatabaseID:   os.Getenv("D1_DATABASE_ID"),
		D1APIToken:     os.Getenv("D1_API_TOKEN"),
		JWTSecret:      secret,
		JWTExpireHours: expireHours,
		Port:           port,

		EmailDebug: emailDebug,
		SMTPHost:   os.Getenv("SMTP_HOST"),
		SMTPPort:   smtpPort,
		SMTPUser:   os.Getenv("SMTP_USER"),
		SMTPPass:   os.Getenv("SMTP_PASS"),
		SMTPFrom:   smtpFrom,
	}, nil
}
