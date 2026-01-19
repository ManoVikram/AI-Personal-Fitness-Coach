package db

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"
)

var Pool *pgxpool.Pool

// Connect initializes database connection pool
func Connect() error {
	// Step 1 - Get the database URL from environment file
	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		return fmt.Errorf("DATABASE_URL is not set in environment")
	}

	// Step 2 - Parse the database URL to get the config
	config, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		return fmt.Errorf("Unable to parse DATABASE_URL: %v", err.Error())
	}

	// Step 3 - Configure the connection pool
	config.MaxConns = 10
	config.MinConns = 2

	// Step 4 - Create connection pool
	pool, err := pgxpool.NewWithConfig(context.Background(), config)
	if err != nil {
		return fmt.Errorf("Unable to create connection pool: %v", err.Error())
	}

	// Step 5 - Ping and test the connection
	if err := pool.Ping(context.Background()); err != nil {
		return fmt.Errorf("Unable to ping database: %v", err.Error())
	}

	// Step 6 - Assign connection pool to the global pool
	Pool = pool
	log.Println("✅ Connected to PostgreSQL database")

	return nil
}

// Close closes the database connection pool
func Close() {
	if Pool != nil {
		Pool.Close()
		log.Println("👋 Database connection closed")
	}
}
