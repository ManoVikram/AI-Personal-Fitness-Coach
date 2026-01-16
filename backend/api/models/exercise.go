package models

type Exercise struct {
	Name        string `json:"name"`
	Sets        int32  `json:"sets"`
	Resps       string `json:"resps"`
	RestSeconds int32  `json:"restSeconds"`
	Notes       string `json:"notes"`
}
