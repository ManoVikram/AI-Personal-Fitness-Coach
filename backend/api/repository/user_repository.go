package repository

import (
	"context"
	"fmt"

	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/db"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/models"
	"github.com/jackc/pgx/v5"
)

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
