package main

import (
	"log"

	"github.com/irj0927/umetter/internal/config"
	"github.com/irj0927/umetter/internal/db"
	"github.com/irj0927/umetter/internal/db/d1"
	"github.com/irj0927/umetter/internal/db/sqlite"
	"github.com/irj0927/umetter/internal/repository"
	"github.com/irj0927/umetter/router"
)

func main() {
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("config: %v", err)
	}

	var repo repository.Repository
	switch cfg.DBDriver {
	case "d1":
		repo = d1.NewRepository(cfg)
	default:
		sqlDB, err := db.Open(cfg)
		if err != nil {
			log.Fatalf("db: %v", err)
		}
		repo = sqlite.NewRepository(sqlDB)
	}

	r := router.New(repo, cfg)
	log.Printf("starting server on :%s (db=%s)", cfg.Port, cfg.DBDriver)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatalf("server: %v", err)
	}
}
