from concurrent.futures import ThreadPoolExecutor
import logging
import os
from dotenv import load_dotenv
import grpc
from proto import coach_pb2, coach_pb2_grpc

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class CoachChatService(coach_pb2_grpc.CoachChatServiceServicer):
    def __init__(self):
        pass

def serve():
    # Step 1 - Load the environment variables
    load_dotenv()
    assert os.getenv("OPENAI_API_KEY"), "OPENAI_API_KEY is not set in the environment variables."

    # Step 2 - Created the gRPC server
    server = grpc.server(thread_pool=ThreadPoolExecutor(max_workers=10))

    # Step 3 - Register the service to the server
    coach_pb2_grpc.add_CoachChatServiceServicer_to_server(servicer=CoachChatService(), server=server)

    # Step 4 - Bind the server to a port
    grpc_port = os.getenv("GRPC_PORT", 50051)
    server.add_insecure_port(f"[::]:{grpc_port}")

    # Step 5 - Start the server
    server.start()
    logger.info(f"🚀 Python gRPC server is running on port {grpc_port}")

    # Step 6 - Keep the server running and wait for termination
    server.wait_for_termination()

if __name__ == "__main__":
    serve()