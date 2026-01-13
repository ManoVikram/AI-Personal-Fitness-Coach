import logging
from typing import List
from proto import coach_pb2, coach_pb2_grpc
from utils.llm_client import LLMClient
from langchain_core.output_parsers import PydanticOutputParser
from pydantic import BaseModel, Field
import grpc

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


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
    exercises: List[ExerciseModel] = Field(description="Details of the exercise")
    total_duration_mins: int = Field(description="Total duration of the workout in minutes", ge=15, le=120)
    difficulty: str = Field(description="Difficulty level of the workout (ex: Beginner, Intermediate, Advanced)")

class WorkoutGeneratorService(coach_pb2_grpc.WorkoutGeneratorServiceServicer):
    def __init__(self):
        super().__init__()
        self.llm = LLMClient.get_structured_model()
        self.parser = PydanticOutputParser(pydantic_object=WorkoutPlanModel)

    def _build_workout_generation_prompt(self, profile: coach_pb2.UserProfile, workout: str):
        """
        Build a prompt for workout generation
        """
        equipment_list = ", ".join(profile.equipment) if profile.equipment else "bodyweight only"

        fitness_goal_strategies = {
            "build_muscle": "Focus on hypertrophy (8-12 reps), compound movements, progressive overload",
            "lose_weight": "Mix of strength and cardio, higher reps (12-15), circuit-style training",
            "general_fitness": "Balanced approach, functional movements, varied rep ranges",
            "increase_strength": "Lower reps (4-6), heavy weights, compound lifts, longer rest",
            "improve_endurance": "Higher reps (15-20), shorter rest, conditioning work"
        }

        strategy = fitness_goal_strategies.get(profile.fitness_goal, fitness_goal_strategies["general_fitness"])

        prompt = f"""You are an expert personal trainer creating a workout plan.

        Client Profile:
        - Fitness Goal: {profile.fitness_goal}
        - Current Level: {profile.fitness_level}
        - Available Equipment: {equipment_list}
        - Workout Type Requested: {workout}

        Training Strategy:
        {strategy}

        Instructions:
        1. Create a {workout} workout suitable for a {profile.fitness_level} level
        2. Only use exercises possible with: {equipment_list}
        3. Include 5-8 exercises with proper progression
        4. Provide clear form notes for each exercise
        5. Set appropriate rest times based on intensity
        6. Ensure total workout is 30-60 minutes

        IMPORTANT: Respond ONLY with valid JSON matching this exact format:
        {self.parser.get_format_instructions()}

        Do not include any markdown formatting, explanations, or text outside the JSON.
        """

        return prompt

    def GenerateWorkout(self, request, context):
        try:
            # Step 1 - Build the workout generation prompt
            prompt = self._build_workout_generation_prompt(profile=request.user_profile, workout=request.workout)

            # Step 2 - Get the response from the LLM
            response = self.llm.invoke(input=prompt)

            # Step 3 - Convert the structured LLM response to Pydantic model
            workout_plan = self.parser.parse(response.content)

            # Step 4 - Convert the Pydantic model to protobuf format
            exercises = [
                coach_pb2.Exercise(
                    name=exercise.name,
                    sets=exercise.sets,
                    reps=exercise.reps,
                    rest_seconds=exercise.rest_seconds,
                    notes=exercise.notes
                )
                for exercise in workout_plan.exercises
            ]

            grpc_response = coach_pb2.WorkoutPlan(
                day=workout_plan.day,
                focus=workout_plan.focus,
                exercise=exercises,
                total_duration_mins=workout_plan.total_duration_mins,
                difficulty=workout_plan.difficulty
            )

            # Step 5 - Return the gRPC response
            return grpc_response
        except Exception as error:
            context.set_code(grpc.StatusCode.INTERNAL)
            error_details = f"Error generating workout plan: {str(error)}"
            context.set_details(error_details)
            logger.error(error_details)

            return coach_pb2.WorkoutPlan(
                day="",
                focus="",
                exercises=[],
                total_duration_mins=0,
                difficulty=""
            )