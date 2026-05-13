import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseService {
  SupabaseService._();

  static Future<void> init() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static String? get currentUserId => client.auth.currentUser?.id;

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) {
    return client.auth.signUp(
      email: email,
      password: password,
      data: fullName == null || fullName.trim().isEmpty ? null : {'full_name': fullName.trim()},
    );
  }

  static Future<void> resetPassword(String email) {
    return client.auth.resetPasswordForEmail(
      email,
      redirectTo: AppConfig.authRedirectUrl,
    );
  }

  static Future<bool> signInWithGoogle() {
    return client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConfig.authRedirectUrl,
    );
  }

  static Future<void> signOut() => client.auth.signOut();
}

