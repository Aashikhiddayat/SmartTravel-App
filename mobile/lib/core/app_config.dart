class AppConfig {
  static const bool demoMode = bool.fromEnvironment('DEMO_MODE', defaultValue: true);
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000');
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String offlineMapStyleUrl = String.fromEnvironment('OFFLINE_MAP_STYLE_URL');

  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}

