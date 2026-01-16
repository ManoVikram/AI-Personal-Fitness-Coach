package main

import (
	"log"
	"os"

	pb "github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/proto"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/routes"
	"github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/services"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	// Step 1 - Load the environment variables
	godotenv.Load()

	gRPCServer := os.Getenv("GRPC_HOST")
	gRPCPort := os.Getenv("GRPC_PORT")
	gRPCAddress := gRPCServer + ":" + gRPCPort

	httpServer := os.Getenv("HTTP_HOST")
	httpPort := os.Getenv("HTTP_PORT")

	if gRPCServer == "" || gRPCPort == "" || httpServer == "" || httpPort == "" {
		log.Fatalf("One or more required environment variables are not set (GRPC_SERVER=%q, GRPC_PORT=%q, HTTP_SERVER=%q, HTTP_PORT=%q)", gRPCServer, gRPCPort, httpServer, httpPort)
		return
	}

	// Step 2 - Connect to the gRPC server
	connection, err := grpc.NewClient(gRPCAddress, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("Could not connect to gRPC server at %s: %v", gRPCAddress, err.Error())
		return
	}
	defer connection.Close()

	// Step 3 - Create the gRPC clients
	coachChatClient := pb.NewCoachChatServiceClient(connection)
	workoutGeneratorClient := pb.NewWorkoutGeneratorServiceClient(connection)
	progressAnalyzerClient := pb.NewProgressAnalyzerServiceClient(connection)

	// Step 4 - Initialize the services with the gRPC clients
	services := &services.Services{
		CoachChatClient:        coachChatClient,
		WorkoutGeneratorClient: workoutGeneratorClient,
		ProgressAnalyzerClient: progressAnalyzerClient,
	}

	// Step 5 - Initialize and set up the Gin server
	server := gin.Default()

	// Step 6 - Register the routes
	routes.RegisterRoutes(server, services)

	// Step 7 - Start the Gin server
	log.Fatal(server.Run(":" + httpPort))
}
