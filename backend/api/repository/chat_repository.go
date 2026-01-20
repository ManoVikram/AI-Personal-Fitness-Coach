package repository

import (
	"context"

	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/db"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/models"
)

// GetChatHistory retrieves last N chat messages for a user
func GetChatHistory(ctx context.Context, userID string, limit int) ([]models.ChatMessage, error) {
	query := `
	SELECT role, content, timestamp
	FROM chat_messages
	WHERE user_id = $1
	ORDER BY created_at DESC
	LIMIT $2;
	`

	rows, err := db.Pool.Query(ctx, query, userID, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var messages []models.ChatMessage

	for rows.Next() {
		var message models.ChatMessage

		err := rows.Scan(
			&message.Role,
			&message.Content,
			&message.Timestamp,
		)
		if err != nil {
			return nil, err
		}

		messages = append(messages, message)
	}

	for i, j := 0, len(messages)-1; i < j; i, j = i+1, j-1 {
		messages[i], messages[j] = messages[j], messages[i]
	}

	return messages, nil
}
