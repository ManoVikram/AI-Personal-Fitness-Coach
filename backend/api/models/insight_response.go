package models

type InsightResponse struct {
	Summary         string    `json:"summary"`
	Insights        []Insight `json:"insights"`
	Recommendations []string  `json:"recommendations"`
}
