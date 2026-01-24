package models

type UserProfileRequest struct {
	Name         string   `json:"name" binding:"required"`
	Age          int32    `json:"age" binding:"required,min=13,max=120"`
	FitnessGoal  string   `json:"fitnessGoal" binding:"required"`
	FitnessLevel string   `json:"fitnessLevel" binding:"required"`
	Equipment    []string `json:"equipment"`
	Gender       string   `json:"gender"`
}
