import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: Constants.supabaseProjectURL,
    anonKey: Constants.supabasePublishableKey,
  );

  if (kDebugMode) {
    debugPrint("=== Supabase Configuration ===");
    debugPrint("Project ID: ${Constants.supabaseProjectID}");
    debugPrint("Project URL: ${Constants.supabaseProjectURL}");
    debugPrint(
      "Publishable Key: ${Constants.supabasePublishableKey.substring(0, 20)}...",
    );
    debugPrint("Redirect URL: ${Constants.supabaseProjectID}://login-callback");
    debugPrint("============================");
  }

  runApp(ProviderScope(child: const App()));
}
