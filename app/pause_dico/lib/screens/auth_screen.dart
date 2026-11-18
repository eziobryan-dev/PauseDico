import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/auth_repository.dart';
import '../repositories/repositories.dart';
import '../widgets/app_logo.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/error_banner.dart';
import '../widgets/gradient_title.dart';
import '../widgets/info_banner.dart';

/// Sign in / sign up screen. Navigation after success is handled by
/// AuthGate (auth state changes).
class AuthScreen extends StatefulWidget {
  /// Error from completing a sign-in link (Google, email confirmation…)
  final String? linkErrorMessage;

  const AuthScreen({super.key, this.linkErrorMessage});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthRepository _repository = Repositories.auth();

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _infoMessage;

  @override
  void initState() {
    super.initState();
    _errorMessage = widget.linkErrorMessage;
  }

  @override
  void didUpdateWidget(AuthScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final linkError = widget.linkErrorMessage;
    if (linkError != null && linkError != oldWidget.linkErrorMessage) {
      setState(() {
        _isLoading = false;
        _infoMessage = null;
        _errorMessage = linkError;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  /// Runs an auth action while handling loading and error states
  Future<void> _runAuthAction(
    Future<void> Function() action, {
    required String fallbackError,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    try {
      await action();
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = fallbackError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    await _runAuthAction(
      () async {
        if (!_isSignUp) {
          await _repository.signInWithEmail(email: email, password: password);
          return;
        }
        final signedIn = await _repository.signUpWithEmail(
          email: email,
          password: password,
          username: _usernameController.text.trim(),
        );
        // Email confirmation required: no session until the link is opened
        if (!signedIn && mounted) {
          setState(() {
            _isSignUp = false;
            _infoMessage =
                'Compte créé ! Confirme ton adresse grâce au lien reçu par email, '
                'puis connecte-toi.';
          });
        }
      },
      fallbackError: 'Une erreur est survenue.',
    );
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      setState(() {
        _infoMessage = null;
        _errorMessage = 'Saisis ton adresse email ci-dessus.';
      });
      return;
    }

    await _runAuthAction(
      () async {
        await _repository.sendPasswordReset(email);
        if (mounted) {
          setState(() => _infoMessage =
              'Un email pour réinitialiser ton mot de passe a été envoyé.');
        }
      },
      fallbackError: "Impossible d'envoyer l'email.",
    );
  }

  Future<void> _submitGoogleAuth() {
    return _runAuthAction(
      _repository.signInWithGoogle,
      fallbackError: 'Erreur lors de la connexion Google.',
    );
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _errorMessage = null;
      _infoMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppLogo(size: 96)),
                const SizedBox(height: 20),
                Center(
                  child: GradientTitle(
                    style: theme.textTheme.displaySmall
                        ?.copyWith(letterSpacing: -0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Votre dose quotidienne de vocabulaire',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                if (_errorMessage != null) ...[
                  ErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 20),
                ],
                if (_infoMessage != null) ...[
                  InfoBanner(message: _infoMessage!),
                  const SizedBox(height: 20),
                ],

                if (_isSignUp) ...[
                  AuthTextField(
                    controller: _usernameController,
                    label: 'Nom d\'utilisateur',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                AuthTextField(
                  controller: _emailController,
                  label: 'Adresse email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Email invalide' : null,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Mot de passe',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.length < 6 ? '6 caractères minimum' : null,
                ),
                if (!_isSignUp)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : _sendPasswordReset,
                      child: const Text('Mot de passe oublié ?'),
                    ),
                  ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _isLoading ? null : _submitEmailAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isSignUp ? 'S\'inscrire' : 'Se connecter',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _submitGoogleAuth,
                  icon: const Icon(Icons.g_mobiledata, size: 28),
                  label: const Text('Continuer avec Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: _toggleMode,
                  child: Text(
                    _isSignUp
                        ? 'Déjà un compte ? Se connecter'
                        : 'Pas de compte ? Créer un compte',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
