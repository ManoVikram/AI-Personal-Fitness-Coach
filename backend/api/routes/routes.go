package routes

import (
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/handlers"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/services"
	"github.com/gin-gonic/gin"
)

func RegisterRoutes(server *gin.Engine, services *services.Services) {
	v1 := server.Group("/api/v1")
	{
		// POST request to chat with AI coach
		v1.POST("/chat", handlers.CoachChatHandler(services))
	}
}
