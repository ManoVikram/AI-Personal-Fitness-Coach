package models

type ExerciseLog struct {
	Name         string
	RepsPerSet   []int32
	WeightPerSet []float32
	Notes        string
}
