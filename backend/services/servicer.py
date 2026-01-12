import logging
from utils.llm_client import LLMClient
from proto import coach_pb2, coach_pb2_grpc

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class CoachChatService(coach_pb2_grpc.CoachChatServiceServicer):
    def __init__(self):
        super().__init__()
        self.llm = LLMClient.get_creative_model()

    def _build_system_prompt(self, profile: coach_pb2.UserProfile):
        """
        Build a personalized system prompt based on the user's profile
        """
        equipment_list = ", ".join(profile.equipment) if profile.equipment else "bodyweight only"

        prompt = f"""You are an experienced, motivating fitness coach with certifications in personal training and sports science.

        Your client's profile:
        - Name: {profile.name}
        - Age: {profile.age}
        - Fitness Goal: {profile.fitness_goal}
        - Current Level: {profile.fitness_level}
        - Available Equipment: {equipment_list}

        Your coaching style:
        - Encouraging and supportive, never judgmental
        - Practical and actionable advice
        - Reference scientific principles when relevant
        - Ask clarifying questions when needed
        - Remember their goals and equipment in your advice

        Guidelines:
        - Keep responses conversational but informative
        - If they ask about exercises, consider their equipment
        - If they mention pain/injury, suggest seeing a professional
        - Celebrate their wins, encourage through setbacks
        - Don't give medical advice - you're a fitness coach, not a doctor

        Be their coach, not just an information bot. Build rapport.
        """
        
        return prompt

    def SendMessage(self, request, context):
        try:
            pass
        except Exception as error:
            pass 