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

      final response = await dio.post("/chat", data: {"message": message});

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
}
