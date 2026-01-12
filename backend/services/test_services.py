"""
Standalone test script for AI services
"""
import grpc
from proto import coach_pb2, coach_pb2_grpc


def test_coach_chat():
    """Test the CoachChatService service"""
    print("=" * 50)
    print("\n🧪 Testing CoachChatService...\n")
    print("=" * 50)
    
    # Step 1 - Connect to the gRPC server
    channel = grpc.insecure_channel('localhost:50051')
    stub = coach_pb2_grpc.CoachChatServiceStub(channel)
    
    # Step 2 - Create a user profile
    profile = coach_pb2.UserProfile(
        user_id="test_user_123",
        name="Kelsier",
        age=28,
        fitness_goal="build_muscle",
        fitness_level="intermediate",
        equipment=["dumbbells", "pull_up_bar", "resistance_bands"]
    )
    
    # Step 3 - Simulate a conversation
    conversations = [
        {
            "message": "Hey coach! I want to build bigger arms. What should I focus on?",
            "history": []
        },
        {
            "message": "I only have dumbbells and a pull-up bar at home. Can I still make progress?",
            "history": [
                coach_pb2.ChatMessage(
                    role="user",
                    content="Hey coach! I want to build bigger arms. What should I focus on?",
                    timestamp="2026-01-12T10:00:00Z"
                ),
                coach_pb2.ChatMessage(
                    role="assistant",
                    content="Great goal! Building bigger arms involves targeting both biceps and triceps...",
                    timestamp="2026-01-12T10:00:05Z"
                )
            ]
        }
    ]
    
    # Step 4 - Iterate through the conversations and test the service 
    for i, conv in enumerate(conversations, 1):
        print(f"\n💬 Message {i}:")
        print(f"User: {conv['message']}")
        
        # Step 4.1 - Create request
        request = coach_pb2.ChatRequest(
            user_id="test_user_123",
            message=conv['message'],
            user_profile=profile,
            chat_history=conv['history']
        )
        
        # Step 4.2 - Call the service
        try:
            response = stub.SendMessage(request)
            print(f"\n🤖 Coach: {response.message}")
            print(f"📊 Tokens used: {response.tokens_used}")
        except grpc.RpcError as e:
            print(f"❌ Error: {e.code()} - {e.details()}")
            return False
    
    print("\n✅ CoachChat test passed!")
    return True


def main():
    """Run all tests"""
    print("🚀 Starting AI Services Tests")
    print("Make sure the gRPC server is running!")
    print("Run: python services/coach_chat.py")
    print()
    
    input("Press Enter when server is ready...")
    
    # Run tests
    tests_passed = 0
    tests_total = 1
    
    if test_coach_chat():
        tests_passed += 1
    
    # Summary
    print("\n" + "=" * 50)
    print(f"Tests passed: {tests_passed}/{tests_total}")
    
    if tests_passed == tests_total:
        print("🎉 All tests passed! Service is working!")
    else:
        print("⚠️ Some tests failed. Check the errors above.")


if __name__ == "__main__":
    main()