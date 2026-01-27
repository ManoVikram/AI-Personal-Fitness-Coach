import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  // Runtime values from .env file
  static String get supabaseProjectID =>
      dotenv.env["SUPABASE_PROJECT_ID"] ?? "";
  static String get supabaseProjectURL =>
      dotenv.env["SUPABASE_PROJECT_URL"] ?? "";
  static String get supabasePublishableKey =>
      dotenv.env["SUPABASE_PUBLISHABLE_KEY"] ?? "";
  static String get supabaseSecretKey =>
      dotenv.env["SUPABASE_SECRET_KEY"] ?? "";
  static String get supabaseJWKSURL => dotenv.env["SUPABASE_JWKS_URL"] ?? "";

  static String get httpHost => dotenv.env["HTTP_HOST"] ?? "localhost";
  static String get httpPort => dotenv.env["HTTP_PORT"] ?? "8080";

  static String get backendURL => "http://$httpHost:$httpPort/api/v1";
}
