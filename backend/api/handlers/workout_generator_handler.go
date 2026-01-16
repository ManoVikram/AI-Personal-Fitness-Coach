package handlers

import (
	"fmt"
	"net/http"

	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/models"
	pb "github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/proto"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/services"
	"github.com/gin-gonic/gin"
)

func WorkoutGeneratorHandler(services *services.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Step 1 - Unmarshall the request body
		var request models.WorkoutRequest

		if err := c.ShouldBindJSON(&request); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("Invalid request body: %v", err.Error())})
			return
		}

		// Step 2 - Get user profile from DB

		// Step 3 - Prepare the gRPC request
		gRPCRequest := pb.WorkoutRequest{
			UserId:      request.UserID,
			UserProfile: mockUserProfile,
			Workout:     request.Workout,
		}

		// Step 4 - Call the gRPC method to get a workout plan
		gRPCResponse, err := services.WorkoutGeneratorClient.GenerateWorkout(c.Request.Context(), &gRPCRequest)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Unable to process the request at the moment: %v", err.Error())})
			return
		}

		// Step 5 - Convert the gRPC response to HTTP response
		exercises := make([]models.Exercise, 0, len(gRPCResponse.Exercises))
		for _, exercise := range gRPCResponse.Exercises {
			exercises = append(exercises, models.Exercise{
				Name:        exercise.Name,
				Sets:        exercise.Sets,
				Resps:       exercise.Reps,
				RestSeconds: exercise.RestSeconds,
				Notes:       exercise.Notes,
			})
		}

		response := models.WorkoutPlan{
			Day:               gRPCResponse.Day,
			Focus:             gRPCResponse.Focus,
			Exercises:         exercises,
			TotalDurationMins: gRPCResponse.TotalDurationMins,
			Difficulty:        gRPCResponse.Difficulty,
		}

		c.JSON(http.StatusOK, response)
	}
}
