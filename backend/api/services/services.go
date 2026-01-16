package services

import pb "github.com/ManoVikram/AI-Personal-Fitness-Coach/backend/api/proto"

type Services struct {
	CoachChatClient        pb.CoachChatServiceClient
	WorkoutGeneratorClient pb.WorkoutGeneratorServiceClient
	ProgressAnalyzerClient pb.ProgressAnalyzerServiceClient
}
