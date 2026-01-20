package repository

import (
	"context"
	"fmt"

	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/db"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/models"
	"github.com/jackc/pgx/v5"
)

// GetUserProfile fetches a user's profile from database
func GetUserProfile(ctx context.Context, userID string) (*models.UserProfile, error) {
	query := `
		SELECT id, name, age, fitness_goal, fitness_level, equipment, gender
		FROM user_profiles
		WHERE id = $1;
	`

	var profile models.UserProfile

	rows, err := db.Pool.Query(ctx, query, userID)
	rows.Scan(
		&profile.UserID,
		&profile.Name,
		&profile.Age,
		&profile.FitnessGoal,
		&profile.FitnessLevel,
		&profile.Equipment,
		&profile.Gender,
	)

	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, fmt.Errorf("User profile not found")
		}
		return nil, err
	}

	return &profile, nil
}

// CreateUserProfile creates a new user profile
func CreateUserProfile(ctx context.Context, profile *models.UserProfile) error {
	query := `
		INSERT INTO user_profiles (id, name, age, fitness_goal, fitness_level, equipment, gender)
		VALUES ($1, $2, $3, $4, $5, $6, $7);
	`

	_, err := db.Pool.Exec(ctx, query,
		profile.UserID,
		profile.Name,
		profile.Age,
		profile.FitnessGoal,
		profile.FitnessLevel,
		profile.Equipment,
		profile.Gender,
	)

	return err
}

// UpdateUserProfile updates and existing user profile
func UpdateUserProfile(ctx context.Context, profile *models.UserProfile) error {
	query := `
		UPDATE user_profiles
		SET name = $2, age = $3, fitness_goal = $4, fitness_level = $5, equipment = $6, gender = $7
		WHERE id = $1;
	`

	result, err := db.Pool.Exec(ctx, query,
		&profile.UserID,
		&profile.Name,
		&profile.Age,
		&profile.FitnessGoal,
		&profile.FitnessLevel,
		&profile.Equipment,
		&profile.Gender,
	)

	if err != nil {
		return err
	}

	if result.RowsAffected() == 0 {
		return fmt.Errorf("User profile not found")
	}

	return nil
}
