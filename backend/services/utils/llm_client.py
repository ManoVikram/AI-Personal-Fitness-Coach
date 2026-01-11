from dotenv import load_dotenv
from langchain_openai import ChatOpenAI


load_dotenv()

class LLMClient:
    @staticmethod
    def get_chat_assistant(temperature=0.7, model="gpt-4o-mini"):
        """
        Get a configured chat model

        Args:
            temperature: 0.0 (deterministic) to 1.0 (creative)
            model: "gpt-40-mini", "gpt-5", etc
        """
        return ChatOpenAI(
            model=model,
            temperature=temperature,
            timeout=30
        )
    
    @staticmethod
    def get_structured_model(model="gpt-4o-mini"):
        """
        Get a model for structured output (lower temperature)

        Used for workout generation, etc.
        """
        return LLMClient.get_chat_assistant(temperature=0.3, model=model)