package models

type ChatRequest struct {
	UserID  string `json:"userID" binding:"required"`
	Message string `json:"message" binding:"required"`
}
