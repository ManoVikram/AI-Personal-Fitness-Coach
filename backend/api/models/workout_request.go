package models

type WorkoutRequest struct {
	Workout string `json:"workout" binding:"required"`
}
