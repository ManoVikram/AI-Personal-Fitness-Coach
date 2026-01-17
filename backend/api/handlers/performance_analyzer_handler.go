package handlers

import (
	"fmt"
	"net/http"

	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/models"
	pb "github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/proto"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/services"
	"github.com/gin-gonic/gin"
)

// Mock workout logs for testing
var mockWorkoutLogs = []*pb.WorkoutLog{
	{
		LogId: "log-1",
		Date:  "2026-01-10",
		ExerciseLogs: []*pb.ExerciseLog{
			{
				Name:         "Push-ups",
				RepsPerSet:   []int32{12, 10, 8},
				WeightPerSet: []float32{},
				Notes:        "Form felt good",
			},
			{
				Name:         "Dumbbell Curls",
				RepsPerSet:   []int32{10, 10, 8},
				WeightPerSet: []float32{10.0, 10.0, 10.0},
			},
		},
		DurationMins: 45,
		Notes:        "Good session",
	},
	{
		LogId: "log-2",
		Date:  "2026-01-13",
		ExerciseLogs: []*pb.ExerciseLog{
			{
				Name:         "Push-ups",
				RepsPerSet:   []int32{15, 12, 10},
				WeightPerSet: []float32{},
				Notes:        "Stronger today!",
			},
			{
				Name:         "Dumbbell Curls",
				RepsPerSet:   []int32{12, 10, 10},
				WeightPerSet: []float32{12.5, 12.5, 10.0},
				Notes:        "Increased weight",
			},
		},
		DurationMins: 40,
	},
}

func PerformanceAnalyzerHandler(services *services.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Step 1 - Get the user ID from the URL path params
		userID := c.Param("user_id")

		// Step 2 - Get the workout logs from DB

		// Step 3 - Get the user profile from DB

		// Step 4 - Prepared the gRPC request
		gRPCRequest := &pb.ProgressRequest{
			UserId:      userID,
			WorkoutLogs: mockWorkoutLogs,
			UserProfile: mockUserProfile,
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
