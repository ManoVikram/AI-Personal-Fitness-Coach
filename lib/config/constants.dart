class Constants {
  static const String supabaseProjectID = String.fromEnvironment(
    "SUPABASE_PROJECT_ID",
  );
  static const String supabasePublishableKey = String.fromEnvironment(
    "SUPABASE_PUBLISHABLE_KEY",
  );
  static const String supabaseSecretKey = String.fromEnvironment(
    "SUPABASE_SECRET_KEY",
  );

  static const String backendURL =
      "http://${String.fromEnvironment('HTTP_HOST')}:${String.fromEnvironment('HTTP_PORT')}";
}
