package models

type WorkoutPlan struct {
	Day               string     `json:"day"`
	Focus             string     `json:"focus"`
	Exercises         []Exercise `json:"exercises"`
	TotalDurationMins int32      `json:"totalDurationMins"`
	Difficulty        string     `json:"difficulty"`
}
