class AppConfig {
  static const String appName = 'RapiKas';
  static const String appTagline = 'Catat uang, rapikan hidup.';

  // Ganti dengan data project Supabase Anda.
  // Untuk production, sebaiknya gunakan env/config aman.
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';

  static const String defaultCurrency = 'IDR';

  // Custom URL scheme untuk callback OAuth Google di Android.
  // Samakan dengan AndroidManifest intent-filter jika Google login diaktifkan.
  static const String authRedirectUrl = 'io.supabase.rapikas://login-callback/';

  static bool get isSupabaseConfigured =>
      supabaseUrl.startsWith('https://') &&
      !supabaseUrl.contains('your-project') &&
      supabaseAnonKey.isNotEmpty &&
      supabaseAnonKey != 'your-anon-key';
}

