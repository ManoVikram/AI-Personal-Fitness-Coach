import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/screens/auth_screen.dart';
import '../../../auth/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [];

  @override
  Widget build(BuildContext context) {
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
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: "Chat",
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: "Workout",
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: "Insights",
          ),
        ],
      ),
    );
  }
}
