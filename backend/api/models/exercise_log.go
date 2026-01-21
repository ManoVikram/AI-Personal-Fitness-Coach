package models

type ExerciseLog struct {
	Name         string
	RepsPerSet   []int32
	WeightPerSet []int32
	Notes        string
}
