import logging
from proto import coach_pb2_grpc
from utils.llm_client import LLMClient

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ProgressAnalyzerService(coach_pb2_grpc.ProgressAnalyzerServiceServicer):
    def __init__(self):
        super.__init__()
        self.llm = LLMClient.get_creative_model()

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

        Format your response as:

        SUMMARY:
        [2-3 sentence overall assessment]

        INSIGHTS:
        - Category: strength_trend | Impact: positive/neutral/needs_attention
        Observation: [what you noticed]

        - Category: consistency | Impact: positive/neutral/needs_attention
        Observation: [what you noticed]

        [continue for all insights]

        RECOMMENDATIONS:
        1. [specific actionable advice]
        2. [specific actionable advice]
        3. [specific actionable advice]

        Be specific with numbers, dates, and exercises. Reference actual data."""

        return prompt

    def _summarize_workouts(self, workout_logs):
        """
        Converts the workout logs into readable summary
        """
        if not workout_logs:
            return "No workout data available."
        
        summary = [f"Workout History ({len(workout_logs.exercise_logs)} workouts):\n\n"]

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

                if log.notes:
                    summary.append(f"Notes:\n{log.notes}\n")

        return "\n".join(summary)

    def AnalyzeProgress(self, request, context):
        # Step 1 - Convert the workout logs into readable format
        workout_summary = self._summarize_workouts(request.workout_logs)

        # Step 2 - Build the progress analyzer prompt
        prompt = self._build_progress_analyzer_prompt(profile=request.user_profile, workout_summary=workout_summary, workout_count=len(request.workout_logs))