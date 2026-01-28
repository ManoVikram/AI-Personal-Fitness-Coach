import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/screens/auth_screen.dart';
import '../../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Oh Fit"),
        centerTitle: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == "logout") {
                final AuthService authService = ref.watch(authServiceProvider);
                await authService.signOut();

                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                } else if (value == "profile") {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Profile editing coming soon!"),
                      ),
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "profile",
                child: Row(
                  children: [
                    const Icon(Icons.person, size: 20.0),
                    const SizedBox(width: 12.0),
                    Text(user?.email ?? "Profile"),
                  ],
                ),
              ),
              PopupMenuItem(
                child: Row(
                  children: [Icon(Icons.logout, size: 20.0, color: Colors.red)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
