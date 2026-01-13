"""
Standalone test script for AI services
"""
import grpc
from proto import coach_pb2, coach_pb2_grpc


def test_coach_chat():
    """Test the CoachChat service"""
    print("=" * 50)
    print("\n🧪 Testing CoachChat Service...\n")
    print("=" * 50)
    
    # Connect to the gRPC server
    channel = grpc.insecure_channel('localhost:50051')
    stub = coach_pb2_grpc.CoachChatServiceStub(channel)
    
    # Create a user profile
    profile = coach_pb2.UserProfile(
        user_id="test_user_123",
        name="Alex",
        age=28,
        fitness_goal="build_muscle",
        fitness_level="intermediate",
        equipment=["dumbbells", "pull_up_bar", "resistance_bands"]
    )
    
    # Simulate a conversation
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
    
    for i, conv in enumerate(conversations, 1):
        print(f"\n💬 Message {i}:")
        print(f"User: {conv['message']}")
        
        # Create request
        request = coach_pb2.ChatRequest(
            user_id="test_user_123",
            message=conv['message'],
            user_profile=profile,
            chat_history=conv['history']
        )
        
        # Call the service
        try:
            response = stub.SendMessage(request)
            print(f"\n🤖 Coach: {response.message}")
            print(f"📊 Tokens used: {response.tokens_used}")
        except grpc.RpcError as e:
            print(f"❌ Error: {e.code()} - {e.details()}")
            return False
    
    print("\n✅ CoachChat test passed!")
    return True

def test_workout_generator():
    """Test the WorkoutGenerator service"""
    print("=" * 50)
    print("\n🧪 Testing WorkoutGenerator Service...\n")
    print("=" * 50)
    
    # Connect to the gRPC server
    channel = grpc.insecure_channel('localhost:50051')
    stub = coach_pb2_grpc.WorkoutGeneratorServiceStub(channel)
    
    # Create a user profile
    profile = coach_pb2.UserProfile(
        user_id="test_user_123",
        name="Alex",
        age=28,
        fitness_goal="build_muscle",
        fitness_level="intermediate",
        equipment=["dumbbells", "pull_up_bar", "resistance_bands"]
    )
    
    # Request a workout
    request = coach_pb2.WorkoutRequest(
        user_id="test_user_123",
        user_profile=profile,
        workout="upper_body"
    )
    
    print(f"\n📋 Requesting: {request.workout} workout")
    print(f"Goal: {profile.fitness_goal}")
    print(f"Equipment: {', '.join(profile.equipment)}")
    
    try:
        response = stub.GenerateWorkout(request)
        
        print(f"\n🏋️ Generated Workout:")
        print(f"Focus: {response.focus}")
        print(f"Duration: {response.total_duration_mins} mins")
        print(f"Difficulty: {response.difficulty}")
        print(f"\nExercises ({len(response.exercises)}):")
        
        for i, ex in enumerate(response.exercises, 1):
            print(f"\n{i}. {ex.name}")
            print(f"   Sets: {ex.sets} x {ex.reps} reps")
            print(f"   Rest: {ex.rest_seconds}s")
            print(f"   Notes: {ex.notes}")
        
        print("\n✅ WorkoutGenerator test passed!")
        return True
        
    except grpc.RpcError as e:
        print(f"❌ Error: {e.code()} - {e.details()}")
        return False

def main():
    """Run all tests"""
    print("🚀 Starting AI Services Tests")
    print()
    print("Available tests:")
    print("1. CoachChat (port 50051)")
    print("2. WorkoutGenerator (port 50051)")
    print()
    print("Start the servers you want to test:")
    print("  Terminal 1: python services/coach_chat.py")
    print("  Terminal 2: python services/workout_generator.py")
    print()
    
    test_choice = input("Which test? (1=chat, 2=workout, all=both): ").strip().lower()
    
    # Run tests
    tests_passed = 0
    tests_total = 0
    
    if test_choice in ['1', 'all']:
        tests_total += 1
        if test_coach_chat():
            tests_passed += 1
    
    if test_choice in ['2', 'all']:
        tests_total += 1
        if test_workout_generator():
            tests_passed += 1
    
    # Summary
    print("\n" + "=" * 50)
    print(f"Tests passed: {tests_passed}/{tests_total}")
    
    if tests_passed == tests_total:
        print("🎉 All tests passed! Services are working!")
    else:
        print("⚠️ Some tests failed. Check the errors above.")

if __name__ == "__main__":
    main()