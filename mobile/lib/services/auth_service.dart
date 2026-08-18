import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_config.dart';

class AuthService {
  Future<String> signIn(String email, String password) async {
    if (AppConfig.demoMode) return 'demo-user';
    final response = await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
    final session = response.session;
    if (session == null) throw Exception('Sign-in did not return a session');
    return session.accessToken;
  }

  Future<void> signUp(String email, String password, String name) async {
    if (AppConfig.demoMode) return;
    await Supabase.instance.client.auth.signUp(email: email, password: password, data: {'name': name});
  }

  Future<void> resetPassword(String email) async {
    if (AppConfig.demoMode) return;
    await Supabase.instance.client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    if (!AppConfig.demoMode) await Supabase.instance.client.auth.signOut();
  }
}
