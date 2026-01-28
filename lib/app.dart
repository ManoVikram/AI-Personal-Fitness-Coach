import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/home/presentation/screens/home_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state to determine which screen to show
    final AsyncValue<AuthState> authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: "Oh Fit",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (state) {
          // Navigate the user to HomeScreen if logged in
          if (state.session != null) {
            return const HomeScreen();
          }
          // Navigate the user to AuthScreen if not logged in
          return AuthScreen();
        },
        error: (error, stackTrace) => AuthScreen(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
    );
  }
}
