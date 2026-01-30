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

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
          "Failed to send message: ${response.statusCode} - ${response.data}",
        );
      }
    } on DioException catch (error) {
      log("❌ Dio error sending chat message: ${error.message}");
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
        "/workouts/geenrate",
        data: {"workout": workoutType},
      );

      log("📥 Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Failed to generate workout: ${response.statusCode}");
      }
    } on DioException catch (error) {
      log("❌ Dio error generating workout: ${error.message}");
      rethrow;
    } catch (error) {
      log("Error generating workout: $error");
      rethrow;
    }
  }

  // GET /api/v1/insights
  Future<Map<String, dynamic>> getInsights() async {
    try {
      log("📤 Fetching insights: ${dio.options.baseUrl}/insights");

      final Response response = await dio.get("/insights");

      log("📥 Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Failed to get insights: ${response.statusCode}");
      }
    } on DioException catch (error) {
      log("❌ Dio error getting insights: ${error.message}");
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

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Failed to save profile: ${response.statusCode}");
      }
    } on DioException catch (error) {
      log("❌ Dio error saving profile: $error");
      rethrow;
    } catch (error) {
      log("❌ Error saving profile: $error");
      rethrow;
    }
  }
}
