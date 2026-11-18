import 'package:flutter/material.dart';

import '../core/utils/context_extensions.dart';
import '../core/utils/time_picker_helpers.dart';
import '../models/user_game_profile_model.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/repositories.dart';
import '../repositories/user_game_profile_repository.dart';
import '../repositories/user_repository.dart';
import '../services/ad_service.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../widgets/definitions_credit.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/level_card.dart';
import '../widgets/notification_toggle_card.dart';
import '../widgets/theme_toggle_card.dart';
import '../widgets/username_card.dart';
import '../widgets/screen_title.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final UserRepository _userRepository = Repositories.user();
  final AuthRepository _authRepository = Repositories.auth();
  final UserGameProfileRepository _gameProfileRepository =
      Repositories.gameProfile();
  final TextEditingController _usernameController = TextEditingController();

  UserModel? _user;
  UserGameProfileModel? _gameProfile;
  bool _isLoading = true;
  bool _isEditingUsername = false;
  bool _isSavingUsername = false;
  bool _notificationEnabled = false;
  bool _isSavingNotification = false;
  bool _isDeletingAccount = false;

  /// Europe (RGPD): the user must be able to change their ad consent
  bool _privacyOptionsRequired = false;

  TimeOfDay get _notifTime => _user?.notifTime ?? NotificationService.defaultTime;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final profile = await _userRepository.getUser();
    final gameProfile = await _gameProfileRepository.getProfile();
    final notificationEnabled = await _loadNotificationEnabled();
    final privacyOptionsRequired = await AdService.isPrivacyOptionsRequired();
    if (!mounted) return;

    setState(() {
      _user = profile;
      _gameProfile = gameProfile;
      _notificationEnabled = notificationEnabled;
      _privacyOptionsRequired = privacyOptionsRequired;
      if (profile != null) {
        _usernameController.text = profile.username;
      }
      _isLoading = false;
    });
  }

  Future<void> _saveUsername() async {
    final user = _user;
    if (user == null) return;

    final newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) {
      context.showSnackBar('Le nom d\'utilisateur ne peut pas être vide.');
      return;
    }

    setState(() => _isSavingUsername = true);

    try {
      await _userRepository.patchUsername(user.id, newUsername);
      if (!mounted) return;
      setState(() {
        _user = user.copyWith(username: newUsername);
        _isEditingUsername = false;
      });
      context.showSnackBar('Nom d\'utilisateur mis à jour !');
    } catch (e) {
      if (mounted) context.showSnackBar('Erreur lors de la mise à jour.');
    } finally {
      if (mounted) setState(() => _isSavingUsername = false);
    }
  }

  /// Cached flag, turned off if the permission was revoked in the OS settings
  Future<bool> _loadNotificationEnabled() async {
    if (!await NotificationService.isEnabled()) return false;
    if (await NotificationService.hasPermission()) return true;
    await NotificationService.disableDaily();
    return false;
  }

  /// On: the switch flips right away, then turns back off if the permission
  /// is refused or the time picker is cancelled.
  Future<void> _toggleNotification(bool enable) async {
    setState(() {
      _isSavingNotification = true;
      _notificationEnabled = enable;
    });

    var enabled = false;
    try {
      if (!enable) {
        await NotificationService.disableDaily();
      } else if (!await NotificationService.requestPermission()) {
        if (mounted) {
          context.showSnackBar('Autorise les notifications pour activer le rappel.');
        }
      } else if (mounted) {
        enabled = await _pickAndScheduleTime();
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Impossible de modifier le rappel.');
    } finally {
      if (mounted) {
        setState(() {
          _notificationEnabled = enabled;
          _isSavingNotification = false;
        });
      }
    }
  }

  /// Opens the native time picker, then schedules the reminder and saves the
  /// time in db. Returns false if the user cancelled.
  Future<bool> _pickAndScheduleTime() async {
    final user = _user;
    if (user == null) return false;

    final time = await TimePickerHelpers.pickTime(context, _notifTime);
    if (time == null) return false;

    await NotificationService.enableDaily(time);
    await _userRepository.patchNotifTime(user.id, time);
    if (mounted) setState(() => _user = user.copyWith(notifTime: time));
    return true;
  }

  Future<void> _changeNotificationTime() async {
    setState(() => _isSavingNotification = true);
    try {
      await _pickAndScheduleTime();
    } catch (e) {
      if (mounted) context.showSnackBar('Impossible de modifier le rappel.');
    } finally {
      if (mounted) setState(() => _isSavingNotification = false);
    }
  }

  /// The reminder and the theme belong to the signed-in user
  Future<void> _resetLocalUserState() async {
    await NotificationService.disableDaily();
    ThemeService.reset();
  }

  Future<void> _handleSignOut() async {
    await _resetLocalUserState();
    await _authRepository.signOut();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _handleDeleteAccount() async {
    if (!await DeleteAccountDialog.show(context)) return;

    setState(() => _isDeletingAccount = true);
    try {
      await _authRepository.deleteAccount();
      await _resetLocalUserState();
      if (!mounted) return;
      context.showSnackBar('Votre compte a été supprimé.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeletingAccount = false);
      context.showSnackBar('Impossible de supprimer le compte. Réessaie plus tard.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const ScreenTitle('Profil'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = _user;
    if (user == null) {
      return const Center(child: Text('Impossible de charger le profil.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          if (_gameProfile case final gameProfile?) ...[
            LevelCard(profile: gameProfile),
            const SizedBox(height: 20),
          ],
          UsernameCard(
            username: user.username,
            controller: _usernameController,
            isEditing: _isEditingUsername,
            isSaving: _isSavingUsername,
            onEdit: () => setState(() => _isEditingUsername = true),
            onSave: _saveUsername,
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email),
              title: Text(user.email),
            ),
          ),
          const SizedBox(height: 20),
          const ThemeToggleCard(),
          const SizedBox(height: 20),
          NotificationToggleCard(
            enabled: _notificationEnabled,
            time: _notifTime,
            isBusy: _isSavingNotification,
            onChanged: _toggleNotification,
            onTimeTap: _changeNotificationTime,
          ),
          if (_privacyOptionsRequired) ...[
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Confidentialité des publicités'),
                trailing: const Icon(Icons.chevron_right),
                onTap: AdService.showPrivacyOptions,
              ),
            ),
          ],
          const SizedBox(height: 60),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: _handleSignOut,
            icon: const Icon(Icons.logout),
            label: const Text('Se déconnecter'),
          ),
          const SizedBox(height: 12),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: _isDeletingAccount ? null : _handleDeleteAccount,
            child: _isDeletingAccount
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Supprimer mon compte'),
          ),
          const SizedBox(height: 32),
          const DefinitionsCredit(),
        ],
      ),
    );
  }
}
