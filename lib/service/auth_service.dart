import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  final SupabaseClient supabase;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String role,
    String? developerName,
    String? displayName,
  }) {
    return supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'role': role,
        if (developerName != null) 'developer_name': developerName,
        if (displayName != null) 'display_name': displayName,
      },
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => supabase.auth.signOut();

  Session? get currentSession => supabase.auth.currentSession;

  String? get currentRole =>
      supabase.auth.currentUser?.userMetadata?['role'] as String?;

  String? get currentDeveloperName =>
      supabase.auth.currentUser?.userMetadata?['developer_name'] as String?;
}
