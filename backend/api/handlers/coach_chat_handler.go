package handlers

import (
	"fmt"
	"net/http"
	"time"

	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/models"
	pb "github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/proto"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/repository"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/services"
	"github.com/gin-gonic/gin"
)

func CoachChatHandler(services *services.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Step 1 - Get the user ID from JWT (set by auth middleware)
		userID, exists := c.Get("user_id")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
			return
		}

		// Step 2 - Unmarshall the request body
		var request models.ChatRequest
		if err := c.ShouldBindJSON(&request); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("Invalid request body: %v", err.Error())})
			return
		}

		// Step 3 - Get user profile from DB
		userProfile, err := repository.GetUserProfile(c.Request.Context(), userID.(string))
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "User profile not found. Please create a profile."})
			return
		}

		// Step 4 - Get the chat history from DB
		chatHistory, err := repository.GetChatHistory(c.Request.Context(), userID.(string), 10)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to fetch chat history: %s", err.Error())})
			return
		}

		// Step 5 - Convert chat history to protobuf format
		var protobufChatHistory []*pb.ChatMessage
		for _, message := range chatHistory {
			protobufChatHistory = append(protobufChatHistory, &pb.ChatMessage{
				Role:      message.Role,
				Content:   message.Content,
				Timestamp: message.Timestamp,
			})
		}

		// Step 6 - Prepare the gRPC request
		gRPCRequest := &pb.ChatRequest{
			UserId:  userID.(string),
			Message: request.Message,
			UserProfile: &pb.UserProfile{
				UserId:       userID.(string),
				Name:         userProfile.Name,
				Age:          userProfile.Age,
				FitnessGoal:  userProfile.FitnessGoal,
				FitnessLevel: userProfile.FitnessGoal,
				Equipment:    userProfile.Equipment,
				Gender:       userProfile.Gender,
			},
			ChatHistory: protobufChatHistory,
		}

		// Step 7 - Call the gRPC method to get a chat response
		gRPCResponse, err := services.CoachChatClient.SendMessage(c.Request.Context(), gRPCRequest)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Unable to process request at the moment: %v", err.Error())})
			return
		}

		// Step 8 - Save the user message to DB
		userMessage := models.ChatMessage{
			Role:      "user",
			Content:   request.Message,
			Timestamp: time.Now().Format(time.RFC3339),
		}
		if err := repository.SaveChatMessage(c.Request.Context(), userID.(string), userMessage, 0); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to save user message: %v", err.Error())})
			return
		}

		// Step 9 - Save assistant message to DB
		assistantMessage := models.ChatMessage{
			Role:      "assistant",
			Content:   gRPCRequest.Message,
			Timestamp: time.Now().Format(time.RFC3339),
		}
		if err := repository.SaveChatMessage(c.Request.Context(), userID.(string), assistantMessage, gRPCResponse.TokensUsed); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to save assistant message: %v", err.Error())})
			return
		}

		// Step 10 - Convert the gRPC resposne to HTTP response
		response := models.ChatResponse{
			Message:    gRPCResponse.Message,
			TokensUsed: gRPCResponse.TokensUsed,
		}

		c.JSON(http.StatusOK, response)
	}
}
