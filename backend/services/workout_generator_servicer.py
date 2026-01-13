from proto import coach_pb2_grpc
from utils.llm_client import LLMClient
from langchain_core.output_parsers import PydanticOutputParser
from pydantic import BaseModel, Field

class ExerciseModel(BaseModel):
    """
    Exercise details structure
    """
    name: str = Field(description="Exercise name (Ex: 'Push-ups', 'Dumbbell Curls')")
    sets: int = Field(description="Number of sets", ge=1, le=10)
    reps: str = Field(description="eps per set (e.g., '8-12', '15-20', 'to failure')")
    rest_seconds: int = Field(description="Rest time between sets in seconds", ge=30, le=300)
    notes: str = Field(description="Form tips, modifications, or targeting info")

class WorkoutPlanModel(BaseModel):
    """
    Workout plan structure
    """
    day: str = Field(description="Day of the week for the workout (ex: Monday, etc.)")
    focus: str = Field(description="Focus area of the workout (ex: Upper Body, Cardio, etc.)")
    exercise: ExerciseModel = Field(description="Details of the exercise")
    total_duration_mins: int = Field(description="Total duration of the workout in minutes", ge=15, le=120)
    difficulty: str = Field(description="Difficulty level of the workout (ex: Beginner, Intermediate, Advanced)")

class WorkoutGeneratorService(coach_pb2_grpc.WorkoutGeneratorServiceServicer):
    def __init__(self):
        super().__init__()
        self.llm = LLMClient.get_structured_model()
        self.parser = PydanticOutputParser(pydantic_object=WorkoutPlanModel)

    def GenerateWorkout(self, request, context):
        # Step 1 - Build the workout generation prompt
        prompt = ""