package models

type UserProfile struct {
	UserID       string   `json:"userID"`
	Name         string   `json:"name"`
	Age          int32    `json:"age"`
	FitnessGoal  string   `json:"fitnessGoal"`
	FitnessLevel string   `json:"fitnessLevel"`
	Equipment    []string `json:"equipment"`
	Gender       string   `json:"gender"`
}
