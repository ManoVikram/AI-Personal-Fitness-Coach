package handlers

import (
	"fmt"
	"net/http"

	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/models"
	pb "github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/proto"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/repository"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/services"
	"github.com/gin-gonic/gin"
)

func WorkoutGeneratorHandler(services *services.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Step 1 - Get the user ID from JWT (set by auth middleware)
		userID, ok := c.Get("user_id")
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
			return
		}

		// Step 2 - Unmarshall the request body
		var request models.WorkoutRequest
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

		// Step 4 - Prepare the gRPC request
		gRPCRequest := pb.WorkoutRequest{
			UserId: userID.(string),
			UserProfile: &pb.UserProfile{
				UserId:       userID.(string),
				Name:         userProfile.Name,
				Age:          userProfile.Age,
				FitnessGoal:  userProfile.FitnessGoal,
				FitnessLevel: userProfile.FitnessLevel,
				Equipment:    userProfile.Equipment,
				Gender:       userProfile.Gender,
			},
			Workout: request.Workout,
		}

		// Step 5 - Call the gRPC method to get a workout plan
		gRPCResponse, err := services.WorkoutGeneratorClient.GenerateWorkout(c.Request.Context(), &gRPCRequest)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Unable to process the request at the moment: %v", err.Error())})
			return
		}

		// Step 6 - Convert the gRPC response to HTTP response
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
