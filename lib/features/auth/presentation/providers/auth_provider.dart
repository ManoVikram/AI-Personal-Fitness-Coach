import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/constants.dart';

// Supabase client provider
final Provider<SupabaseClient> supabaseClientProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

// Auth state provider (stream - auto-updates when auth changes)
final StreamProvider<AuthState> authStateProvider = StreamProvider<AuthState>((
  ref,
) {
  final SupabaseClient supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange;
});

// Current user provider
final Provider<User?> currentUserProvider = Provider<User?>((ref) {
  final AsyncValue<AuthState> authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session?.user,
    error: (error, stackTrace) => null,
    loading: () => null,
  );
});

// Auth service provider
final Provider<AuthService> authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(supabaseClientProvider)),
);

// Auth service class
class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get current session (includes JWT)
  Session? get currentSession => _supabase.auth.currentSession;

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: "${Constants.supabaseProjectID}://login-callback",
      );
      return true;
    } catch (error) {
      log("Sign in error: $error");
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get JWT token for API calls
  String? get accessToken => currentSession?.accessToken;
}
