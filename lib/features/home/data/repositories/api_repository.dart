import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../core/config/constants.dart';

class ApiRepository {
  final Dio dio;
  final String _accessToken;

  ApiRepository(this._accessToken)
    : dio = Dio(BaseOptions(baseUrl: Constants.backendURL)) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers.addAll({
            "Content-Type": "application/json",
            "Authorization": "Bearer $_accessToken",
          });
          handler.next(options);
        },
      ),
    );
  }

  // POST /api/v1/chat
  Future<Map<String, dynamic>> sendChatMessage(String message) async {
    try {
      log("📤 Sending chat message to: ${dio.options.baseUrl}/chat");

      final Response response = await dio.post(
        "/chat",
        data: {"message": message},
      );

      log("📥 Response status: ${response.statusCode}");

      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      log("❌ Dio error sending chat message: ${error.message}");
      log("❌ Resonse: ${error.response?.data}");
      rethrow;
    } catch (error) {
      log("❌ Error sending chat message: $error");
      rethrow;
    }
  }

  // POST /api/v1/workouts/generate
  Future<Map<String, dynamic>> generateWorkout(String workoutType) async {
    try {
      log("📤 Generating workout: ${dio.options.baseUrl}/workouts/generate");

      final Response response = await dio.post(
        "/workouts/generate",
        data: {"workout": workoutType},
      );

      log("📥 Response status: ${response.statusCode}");

      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      log("❌ Dio error generating workout: ${error.message}");
      log("❌ Resonse: ${error.response?.data}");
      rethrow;
    } catch (error) {
      log("❌ Error generating workout: $error");
      rethrow;
    }
  }

  // GET /api/v1/insights
  Future<Map<String, dynamic>> getInsights() async {
    try {
      log("📤 Fetching insights: ${dio.options.baseUrl}/insights");

      final Response response = await dio.get("/insights");

      log("📥 Response status: ${response.statusCode}");

      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      log("❌ Dio error getting insights: ${error.message}");
      log("❌ Resonse: ${error.response?.data}");
      rethrow;
    } catch (error) {
      log("❌ Error gertting insights: $error");
      rethrow;
    }
  }

  // POST /api/v1/profile (Create/Update)
  Future<Map<String, dynamic>> saveProfile({
    required String name,
    required int age,
    required String fitnessGoal,
    required String fitnessLevel,
    required List<String> equipment,
    String? gender,
  }) async {
    try {
      log("📤 Saving profile: ${dio.options.baseUrl}/profile");

      final Response response = await dio.post(
        "/profile",
        data: {
          "name": name,
          "age": age,
          "fitnessGoal": fitnessGoal,
          "fitnessLevel": fitnessLevel,
          "equipment": equipment,
          "gender": gender,
        },
      );

      log("📤 Response status: ${response.statusCode}");

      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      log("❌ Dio error saving profile: $error");
      log("❌ Resonse: ${error.response?.data}");
      rethrow;
    } catch (error) {
      log("❌ Error saving profile: $error");
      rethrow;
    }
  }

  // Get /api/v1/profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      log("📤 Fetching profile: ${dio.options.baseUrl}/profile");

      final Response response = await dio.get("/profile");

      log("📤 Response status: ${response.statusCode}");

      return response.data as Map<String, dynamic>;
    } on DioException catch (error) {
      log("❌ Dio error fetching profile: $error");
      log("❌ Resonse: ${error.response?.data}");
      rethrow;
    } catch (error) {
      log("❌ Error fetching profile: $error");
      rethrow;
    }
  }
}
