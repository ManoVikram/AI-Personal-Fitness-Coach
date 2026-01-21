package repository

import (
	"context"

	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/db"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/models"
)

// GetWorkoutLogs retrieves last N workout logs for a user
func GetWorkoutLogs(ctx context.Context, userID string, limit int) ([]models.WorkoutLog, error) {
	query := `
	SELECT id, date, duration_mins, notes, created_at
	FROM workout_logs
	WHERE user_id = $1
	ORDER BY date DESC
	LIMIT $2;
	`

	rows, err := db.Pool.Query(ctx, query, userID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var workoutLogs []models.WorkoutLog
	for rows.Next() {
		var workoutLog models.WorkoutLog
		var createdAt string

		err := rows.Scan(&workoutLog.LogID, &workoutLog.Date, &workoutLog.DurationMins, &workoutLog.Notes, &createdAt)
		if err != nil {
			return nil, err
		}

		workoutLog.UserID = userID
		workoutLog.ExerciseLogs, err = getExerciseLogsForWorkout(ctx, workoutLog.LogID)
		if err != nil {
			return nil, err
		}

		workoutLogs = append(workoutLogs, workoutLog)
	}

	return workoutLogs, nil
}

// getExercisesForWorkout retrieves exercises for a specific workout
func getExerciseLogsForWorkout(ctx context.Context, workoutID string) ([]models.ExerciseLog, error) {
	query := `
	SELECT name, reps_per_set, weight_per_set, notes
	FROM exercise_logs
	WHERE workout_log_id = $1
	ORDER BY created_at;
	`

	rows, err := db.Pool.Query(ctx, query, workoutID)
	if err != nil {
		return nil, err
	}

	var exerciseLogs []models.ExerciseLog
	for rows.Next() {
		var exerciseLog models.ExerciseLog

		err := rows.Scan(&exerciseLog.Name, &exerciseLog.RepsPerSet, &exerciseLog.WeightPerSet, &exerciseLog.Notes)
		if err != nil {
			return nil, err
		}

		exerciseLogs = append(exerciseLogs, exerciseLog)
	}

	return exerciseLogs, nil
}
