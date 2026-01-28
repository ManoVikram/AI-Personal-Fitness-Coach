import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  static const String route = "/auth";

  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final AuthService authService = ref.watch(authServiceProvider);

      // This will open the browser for OAuth
      // It doesn't return success/failure - browser opens or error is thrown
      await authService.signInWithGoogle();

      debugPrint("✅ Browser opened for Google login");
      // If success, authStateProvider will automatically trigger navigation
      // via the App widget (app.dart) watching the auth state
    } catch (error) {
      // Only show error if OAuth flow failed to start
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to start sign in: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/images/auth-screen-image.png",
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: SafeArea(
              minimum: EdgeInsets.only(bottom: 20.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FilledButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: FilledButton.styleFrom(
                    padding: EdgeInsets.all(16),
                    backgroundColor: Colors.white,
                    shape: StadiumBorder(),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 36.0,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/google-logo.svg",
                              height: 36.0,
                            ),
                            SizedBox(width: 16.0),
                            Text(
                              "Continue with Google",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
