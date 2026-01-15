import logging
from typing import List, Literal
from proto import coach_pb2, coach_pb2_grpc
from utils.llm_client import LLMClient
from langchain_core.output_parsers import PydanticOutputParser
from pydantic import BaseModel, Field

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class InsightModel(BaseModel):
    category: str = Field(description="Insight category like strength_trend, consistency, recovery")
    observation: str = Field(description="Specific observation backed by workout data")
    impact: Literal["positive", "neutral", "needs_attention"]

class InsightResponseModel(BaseModel):
    summary: str = Field(description="Insights summary after progress analysis")
    insights: List[InsightModel] = Field(description="All the insights from the LLM")
    recommendations: List[str] = Field(description="Actionable advices to reach the goal")

class ProgressAnalyzerService(coach_pb2_grpc.ProgressAnalyzerServiceServicer):
    def __init__(self):
        super().__init__()
        self.llm = LLMClient.get_creative_model()
        self.parser = PydanticOutputParser(pydantic_object=InsightResponseModel)

    def _build_progress_analyzer_prompt(self, profile, workout_summary, workout_count):
        """
        Build a prompt for progress analysis
        """
        prompt = f"""You are analyzing workout progress for a fitness client.

        Client Profile:
        - Name: {profile.name}
        - Goal: {profile.fitness_goal}
        - Current Level: {profile.fitness_level}

        {workout_summary}

        Analyze this data and provide insights in the following categories:

        1. STRENGTH TRENDS
        - Are they getting stronger? (compare weights/reps over time)
        - Which exercises show best progress?
        - Any plateaus?

        2. CONSISTENCY
        - How regular are their workouts?
        - Workout frequency patterns
        - Any concerning gaps?

        3. VOLUME & RECOVERY
        - Are they training with appropriate volume?
        - Signs of overtraining or undertraining?
        - Rest day patterns

        4. RECOMMENDATIONS
        - Specific actionable advice (3-5 items)
        - What to change or continue
        - Next steps to reach their goal

        IMPORTANT: Respond ONLY with valid JSON matching this exact format:
        {self.parser.get_format_instructions()}

        Be specific with numbers, dates, and exercises. Reference actual data.
        
        Do not include any markdown formatting, explanations, or text outside the JSON.
        """

        return prompt

    def _summarize_workouts(self, workout_logs):
        """
        Converts the workout logs into readable summary
        """
        if not workout_logs:
            return "No workout data available."
        
        summary = [f"Workout History ({len(workout_logs)} workouts):\n\n"]

        for log in workout_logs:
            summary.append(f"Date: {log.date} | {log.duration_mins} mins\n")

            for exercise in log.exercise_logs:
                # Format: "Push-ups: 3 sets [12, 10, 8 reps] @ [0, 0, 0 kg]"
                reps_per_set = ", ".join(str(reps) for reps in exercise.reps_per_set)

                if exercise.weight_per_set:
                    weight_per_set = ", ".join(str(weight) for weight in exercise.weight_per_set)

                    summary.append(f" - {exercise.name}: {len(exercise.reps_per_set)} [{reps_per_set} reps] @ [{weight_per_set} kg]\n")
                else:
                    summary.append(f" - {exercise.name}: {len(exercise.reps_per_set)} [{reps_per_set} reps] @ [bodyweight]\n")

                if exercise.notes:
                    summary.append(f"Notes:\n{exercise.notes}\n")

        return "\n".join(summary)

    def AnalyzeProgress(self, request, context):
        # Step 1 - Convert the workout logs into readable format
        workout_summary = self._summarize_workouts(request.workout_logs)

        # Step 2 - Build the progress analyzer prompt
        prompt = self._build_progress_analyzer_prompt(profile=request.user_profile, workout_summary=workout_summary, workout_count=len(request.workout_logs))

        # Step 3 - Get the response from the LLM
        response = self.llm.invoke(input=prompt)

        # Step 4 - Parse the LLM response to Pydantic model
        insights = self.parser.parse(response.content)

        # Step 5 - Convert the Pydantic model to protobuf format
        insights_list = [
            coach_pb2.Insight(
                category=insight.category,
                observation=insight.observation,
                impact=insight.impact
            )
            for insight in insights.insights
        ]

        grpc_response = coach_pb2.InsightResponse(
            summary=insights.summary,
            insights=insights_list,
            recommendations=insights.recommendations   
        )

        # Step 6 - Return the gRPC response
        return grpc_response