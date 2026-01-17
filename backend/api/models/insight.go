package models

type Insight struct {
	Category    string `json:"category"`
	Observation string `json:"observation"`
	Impact      string `json:"impact"`
}
