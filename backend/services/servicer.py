import logging

import grpc
from langchain.messages import AIMessage, HumanMessage, SystemMessage
from proto import coach_pb2, coach_pb2_grpc
from utils.llm_client import LLMClient

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
    
    def _create_chat_history(self, chat_history):
        """
        Convert protobuf ChatMessage objects to LangChain messages
        """
        messages = []
        for message in chat_history:
            if message.role == "user":
                messages.append(HumanMessage(content=message.content))
            elif message.role == "assistant":
                messages.append(AIMessage(content=message.content))

        return messages

    def SendMessage(self, request, context):
        try:
            # Step 1 - Build the system prompt
            system_prompt = self._build_system_prompt(request.user_profile)

            # Step 2 - Convert chat history to LangChain messages format
            messages = [SystemMessage(content=system_prompt)]
            messages.extend(self._create_chat_history(chat_history=request.chat_history))

            # Step 3 - Add the new user message
            messages.append(HumanMessage(content=request.message))

            # Step 4 - Get the response from the LLM
            response = self.llm.invoke(messages=messages)

            # Step 5 - Return the response as ChatResponse
            return coach_pb2.ChatResponse(
                message=response.content,
                tokens_used=response.usage_metadata.total_tokens
            )
        except Exception as error:
            context.set_code(grpc.StatusCode.INTERNAL)
            error_details = f"Error processing response: {str(error)}"
            context.set_details(error_details)
            logger.error(error_details)
            
            return coach_pb2.ChatResponse(
                message="",
                tokens_used=0
            )