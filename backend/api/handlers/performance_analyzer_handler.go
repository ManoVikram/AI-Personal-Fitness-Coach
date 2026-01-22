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

func PerformanceAnalyzerHandler(services *services.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Step 1 - Get the user ID from JWT (set by auth middleware)
		userID, exists := c.Get("user_id")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
			return
		}

		// Step 2 - Get the user profile from DB
		userProfile, err := repository.GetUserProfile(c.Request.Context(), userID.(string))
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "User profile not found. Please create a profile."})
			return
		}

		// Step 3 - Get the workout logs from DB
		workoutLogs, err := repository.GetWorkoutLogs(c.Request.Context(), userID.(string), 10)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to fetch workout logs: %v", err.Error())})
			return
		}

		// Step 4 - Convert workout logs to protobuf format
		var protobufWorkoutLogs []*pb.WorkoutLog
		for _, workoutLog := range workoutLogs {
			var protobufExerciseLogs []*pb.ExerciseLog
			for _, exerciseLog := range workoutLog.ExerciseLogs {
				protobufExerciseLogs = append(protobufExerciseLogs, &pb.ExerciseLog{
					Name:         exerciseLog.Name,
					RepsPerSet:   exerciseLog.RepsPerSet,
					WeightPerSet: exerciseLog.WeightPerSet,
					Notes:        exerciseLog.Notes,
				})
			}

			protobufWorkoutLogs = append(protobufWorkoutLogs, &pb.WorkoutLog{
				LogId:        workoutLog.LogID,
				Date:         workoutLog.Date,
				ExerciseLogs: protobufExerciseLogs,
				DurationMins: workoutLog.DurationMins,
				Notes:        workoutLog.Notes,
			})
		}

		// Step 4 - Prepared the gRPC request
		gRPCRequest := &pb.ProgressRequest{
			UserId:      userID.(string),
			WorkoutLogs: protobufWorkoutLogs,
			UserProfile: &pb.UserProfile{
				UserId:       userID.(string),
				Name:         userProfile.Name,
				Age:          userProfile.Age,
				FitnessGoal:  userProfile.FitnessGoal,
				FitnessLevel: userProfile.FitnessGoal,
				Equipment:    userProfile.Equipment,
				Gender:       userProfile.Gender,
			},
		}

		// Step 5 - Call the gRPC method to get progress insights
		gRPCResponse, err := services.ProgressAnalyzerClient.AnalyzeProgress(c.Request.Context(), gRPCRequest)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Unable to process the request at the moment: %v", err.Error())})
			return
		}

		// Step 6 - Convert the gRPC response to HTTP response
		insights := make([]models.Insight, 0, len(gRPCResponse.Insights))
		for _, insight := range gRPCResponse.Insights {
			insights = append(insights, models.Insight{
				Category:    insight.Category,
				Observation: insight.Category,
				Impact:      insight.Impact,
			})
		}

		response := models.InsightResponse{
			Summary:         gRPCResponse.Summary,
			Insights:        insights,
			Recommendations: gRPCResponse.Recommendations,
		}

		c.JSON(http.StatusOK, response)
	}
}
