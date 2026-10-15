import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_constants.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Returns the current active Supabase Auth user
  User? get currentUser => _client.auth.currentUser;

  /// Sign up with Email and Password. Returns false when the email must be
  /// confirmed first (no session yet).
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
      emailRedirectTo: AppConstants.authRedirectUrl,
    );
    return response.session != null;
  }

  /// Sign in with Email and Password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with Google OAuth
  Future<bool> signInWithGoogle() {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AppConstants.authRedirectUrl,
    );
  }

  /// Sends a reset link by email. The link opens the app on a
  /// password recovery session (AuthChangeEvent.passwordRecovery).
  Future<void> sendPasswordReset(String email) {
    return _client.auth.resetPasswordForEmail(
      email,
      redirectTo: AppConstants.passwordResetRedirectUrl,
    );
  }

  /// Sets a new password for the current (recovery) session
  Future<void> updatePassword(String password) async {
    await _client.auth.updateUser(UserAttributes(password: password));
  }

  /// Sign Out
  Future<void> signOut() => _client.auth.signOut();
}
