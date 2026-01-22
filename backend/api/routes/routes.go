package routes

import (
	"net/http"

	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/handlers"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/middleware"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/services"
	"github.com/gin-gonic/gin"
)

func RegisterRoutes(server *gin.Engine, services *services.Services) {
	// GET request for API health check (no auth required)
	server.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"status":  "healthy",
			"service": "fitness-coach-api",
		})
	})

	// API v1 routes
	v1 := server.Group("/api/v1")

	// Protected routes (requires authentication)
	protected := v1.Group("")
	protected.Use(middleware.AuthMiddleware())
	{
		// POST request to chat with AI coach
		protected.POST("/chat", handlers.CoachChatHandler(services))

		// POST request to generate workout plan
		protected.POST("/workout/generate", handlers.WorkoutGeneratorHandler(services))

		// POST request to analyze the progress and generate insights
		protected.GET("/insights", handlers.PerformanceAnalyzerHandler(services))
	}
}
