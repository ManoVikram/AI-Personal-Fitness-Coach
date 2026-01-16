package models

type WorkoutRequest struct {
	UserID  string `json:"userID" binding:"required"`
	Workout string `json:"workout" binding:"required"`
}
