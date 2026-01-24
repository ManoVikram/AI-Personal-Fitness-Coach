package handlers

import (
	"net/http"

	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/repository"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/services"
	"github.com/gin-gonic/gin"
)

// GetProfileHandler retrieves a user's profile
func GetProfileHandler(services *services.Services) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Step 1 - Get user ID from JWT (set by auth middleware)
		userID, exists := c.Get("user_id")
		if !exists {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
			return
		}

		// Step 2 - Get user profile from DB
		userProfile, err := repository.GetUserProfile(c.Request.Context(), userID.(string))
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "User profile not found. Please create a profile."})
			return
		}

		c.JSON(http.StatusOK, userProfile)
	}
}
