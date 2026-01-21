package models

type WorkoutLog struct {
	UserID       string
	LogID        string
	Date         string
	ExerciseLogs []ExerciseLog
	DurationMins int32
	Notes        string
}
