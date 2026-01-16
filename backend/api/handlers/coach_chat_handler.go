package handlers

import (
	"fmt"
	"net/http"
	"time"

	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/models"
	pb "github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/proto"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/services"
	"github.com/gin-gonic/gin"
)

var (
	mockUserProfile = &pb.UserProfile{
		UserId:       "test-user-123",
		Name:         "John Doe",
		Age:          28,
		FitnessGoal:  "build_muscle",
		FitnessLevel: "intermediate",
		Equipment:    []string{"dumbbells", "pull_up_bar"},
		Gender:       "Male",
	}

	mockChatHistory = []*pb.ChatMessage{
		{
			Role:      "user",
			Content:   "Hi coach! I'm ready to get started.",
			Timestamp: time.Now().Add(-5 * time.Minute).Format(time.RFC3339),
		},
		{
			Role:      "assistant",
			Content:   "Great! Let's build some muscle together. What questions do you have?",
			Timestamp: time.Now().Add(-4 * time.Minute).Format(time.RFC3339),
		},
	}
)

func CoachChatHandler(services *services.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Step 1 - Unmarshall the request body
		var request models.ChatRequest

		if err := c.ShouldBindJSON(&request); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("Invalid request body: %v", err.Error())})
			return
		}

		// Step 2 - Get user profile from DB

		// Step 3 - Get the chat history from DB

		// Step 4 - Prepare the gRPC request
		gRPCRequest := &pb.ChatRequest{
			UserId:      request.UserID,
			Message:     request.Message,
			UserProfile: mockUserProfile,
			ChatHistory: mockChatHistory,
		}

		// Step 5 - Call the gRPC method to get a chat response
		gRPCResponse, err := services.CoachChatClient.SendMessage(c.Request.Context(), gRPCRequest)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Unable to process request at the moment: %v", err.Error())})
			return
		}

		// Step 6 - Convert the gRPC resposne to HTTP response
		response := models.ChatResponse{
			Message:    gRPCResponse.Message,
			TokensUsed: gRPCResponse.TokensUsed,
		}

		// Step 7 - Save the user message and AI response to DB

		c.JSON(http.StatusOK, response)
	}
}
