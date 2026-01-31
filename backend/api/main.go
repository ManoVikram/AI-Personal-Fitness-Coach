package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/db"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/middleware"
	pb "github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/proto"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/routes"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/services"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "*")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(http.StatusNoContent)
			return
		}

		c.Next()
	}
}

func main() {
	// Step 1 - Load the environment variables
	godotenv.Load("../../.env")

	gRPCServer := os.Getenv("GRPC_HOST")
	gRPCPort := os.Getenv("GRPC_PORT")
	gRPCAddress := gRPCServer + ":" + gRPCPort

	httpServer := os.Getenv("HTTP_HOST")
	httpPort := os.Getenv("HTTP_PORT")

	if gRPCServer == "" || gRPCPort == "" || httpServer == "" || httpPort == "" {
		log.Fatalf("⚠️ One or more required environment variables are not set (GRPC_SERVER=%q, GRPC_PORT=%q, HTTP_SERVER=%q, HTTP_PORT=%q)", gRPCServer, gRPCPort, httpServer, httpPort)
		return
	}

	// Step 2 - Connect to the DB
	if err := db.Connect(); err != nil {
		log.Fatalf("❌ Failed to connect to database: %v", err.Error())
		return
	}
	defer db.Close()

	// Step 3 - Initialize JWKS cache for JWT verification
	ctx := context.Background()
	if err := middleware.InitJWKS(ctx); err != nil {
		log.Fatalf("❌ Failed to initialize JWKS: %v", err.Error())
	}
	log.Println("✅ JWKS cache initialized")

	// Step 4 - Connect to the gRPC server
	connection, err := grpc.NewClient(gRPCAddress, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("❌ Could not connect to gRPC server at %s: %v", gRPCAddress, err.Error())
		return
	}
	defer connection.Close()

	log.Printf("✅ Connected to Python gRPC services at %s", gRPCAddress)

	// Step 5 - Create the gRPC clients
	coachChatClient := pb.NewCoachChatServiceClient(connection)
	workoutGeneratorClient := pb.NewWorkoutGeneratorServiceClient(connection)
	progressAnalyzerClient := pb.NewProgressAnalyzerServiceClient(connection)

	// Step 6 - Initialize the services with the gRPC clients
	services := &services.Services{
		CoachChatClient:        coachChatClient,
		WorkoutGeneratorClient: workoutGeneratorClient,
		ProgressAnalyzerClient: progressAnalyzerClient,
	}

	// Step 7 - Initialize and set up the Gin server
	server := gin.Default()

	// Step 8 - Add CORS middleware
	server.Use(corsMiddleware())

	// Step 9 - Register the routes
	routes.RegisterRoutes(server, services)

	// Step 10 - Start the Gin server
	log.Printf("🚀 Server running on %s:%s", httpServer, httpPort)
	log.Fatal(server.Run(":" + httpPort))
}
