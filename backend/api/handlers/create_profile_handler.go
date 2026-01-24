package handlers

import (
	"fmt"
	"net/http"

	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/models"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/repository"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/services"
	"github.com/gin-gonic/gin"
)

// CreateProfileHandler creates or updates a user's profile
func CreateProfileHandler(services *services.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Step 1 - Get user ID from JWT (set by auth middleware)
		userID, exists := c.Get("user_id")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
			return
		}

		// Step 2 - Unmarshall the request body
		var request models.UserProfileRequest
		err := c.ShouldBindJSON(&request)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": fmt.Sprintf("Invalid requst body: %v", err.Error())})
			return
		}

		// Step 3 - Prepare the user profile model object
		userProfile := &models.UserProfile{
			UserID:       userID.(string),
			Name:         request.Name,
			Age:          request.Age,
			FitnessGoal:  request.FitnessGoal,
			FitnessLevel: request.FitnessLevel,
			Equipment:    request.Equipment,
			Gender:       request.Gender,
		}

		// Step 3 - Try to update the profile first. If failed, try to create the profile.
		err = repository.UpdateUserProfile(c.Request.Context(), userProfile)
		if err != nil {
			err = repository.CreateUserProfile(c.Request.Context(), userProfile)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": fmt.Sprintf("Failed to save profile: %v", err.Error())})
				return
			}
		}

		c.JSON(http.StatusOK, gin.H{
			"message": "User profile saved successfully",
			"profile": userProfile,
		})
	}
}
