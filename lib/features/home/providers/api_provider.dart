import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;

import '../../auth/providers/auth_provider.dart';
import '../data/repositories/api_repository.dart';

final Provider<ApiRepository?> apiRepository = Provider<ApiRepository?>((ref) {
  final AuthService authService = ref.watch(authServiceProvider);
  final String? accessToken = authService.accessToken;

  if (accessToken == null) {
    return null;
  }

  return ApiRepository(accessToken);
});
