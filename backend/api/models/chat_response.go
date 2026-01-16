package models

type ChatResponse struct {
	Message    string `json:"message"`
	TokensUsed int32  `json:"tokensUsed"`
}
