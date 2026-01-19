package models

type UserProfile struct {
	UserID       string
	Name         string
	Age          int32
	FitnessGoal  string
	FitnessLevel string
	Equipment    []string
	Gender       string
}
