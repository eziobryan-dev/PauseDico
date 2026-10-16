import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/onboarding_service.dart';
import 'auth_screen.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'reset_password_screen.dart';

/// Routes on the auth state: sign in screen, home screen, or the new password
/// screen when the app is opened from a password reset email
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<AuthState> _subscription;
  bool _isRecoveringPassword = false;

  /// Error raised while completing a sign-in from a link (Google, email
  /// confirmation…), shown on the sign in screen instead of failing silently
  String? _authError;

  /// null while the cached flag is being read
  bool? _onboardingDone;

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    OnboardingService.isDone().then((done) {
      if (mounted) setState(() => _onboardingDone = done);
    });
    _subscription = _client.auth.onAuthStateChange.listen(
      (state) {
        if (!mounted) return;
        setState(() {
          _authError = null;
          if (state.event == AuthChangeEvent.passwordRecovery) {
            _isRecoveringPassword = true;
          } else if (state.event == AuthChangeEvent.signedOut) {
            _isRecoveringPassword = false;
          }
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _authError = error is AuthException
              ? 'Connexion impossible : ${error.message}'
              : 'Connexion impossible. Réessaie.';
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_client.auth.currentSession == null) {
      return AuthScreen(linkErrorMessage: _authError);
    }
    if (_isRecoveringPassword) {
      return ResetPasswordScreen(
        onDone: () => setState(() => _isRecoveringPassword = false),
      );
    }
    final onboardingDone = _onboardingDone;
    if (onboardingDone == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (!onboardingDone) return OnboardingScreen(onDone: _finishOnboarding);
    return const HomeScreen();
  }

  Future<void> _finishOnboarding() async {
    setState(() => _onboardingDone = true);
    await OnboardingService.markDone();
  }
}
