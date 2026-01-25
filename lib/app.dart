import 'package:flutter/material.dart';

import 'features/auth/presentation/screens/auth_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Oh Fit",
      debugShowCheckedModeBanner: false,
      initialRoute: AuthScreen.route,
      routes: {AuthScreen.route: (_) => const AuthScreen()},
    );
  }
}
