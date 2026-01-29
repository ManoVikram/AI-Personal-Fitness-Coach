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
          options.headers["Content-Type"] = "application/json";
          options.headers["Authorization"] = "Bearer $_accessToken";
          handler.next(options);
        },
      ),
    );
  }
}
