import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/theme_switcher.dart';
import '../repositories/repositories.dart';
import '../repositories/user_repository.dart';

/// Dark theme preference: applied instantly, cached in shared_preferences
/// (right theme from app launch) and saved to `user.dark_theme`.
/// Database writes are debounced and serialized: rapid toggles result in at
/// most one write of the final value.
class ThemeService {
  /// Built on first save, so that a debug scenario's fake is used
  static UserRepository? _userRepository;

  static Timer? _saveTimer;
  static Future<void> _saving = Future.value();
  static bool? _lastSavedDarkTheme;

  /// Once the user toggled in this session, the local choice is the newest:
  /// a profile read racing with the save must not revert it
  static bool _toggledThisSession = false;

  /// Applies the cached preference. Call once at startup, before runApp.
  static Future<void> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool(AppConstants.darkThemeKey);
    if (dark != null) _apply(dark);
  }

  /// Applies the preference stored in db (e.g. after loading the profile),
  /// unless the user already toggled it in this session
  static Future<void> applyUserPreference(bool dark) async {
    if (_toggledThisSession) return;
    _lastSavedDarkTheme = dark;
    _apply(dark);
    await _cache(dark);
  }

  /// Toggle from the profile: applies now, saves to db after a short delay
  static Future<void> setDarkTheme(bool dark) async {
    _toggledThisSession = true;
    _apply(dark);
    await _cache(dark);

    _saveTimer?.cancel();
    _saveTimer = Timer(AppConstants.darkThemeSaveDebounce, () {
      _saving = _saving.then((_) => _save(dark));
    });
  }

  static Future<void> _save(bool dark) async {
    // Toggled back to the saved value, or a newer value is on its way
    if (dark == _lastSavedDarkTheme || _isDark != dark) return;
    try {
      await (_userRepository ??= Repositories.user()).patchDarkTheme(dark);
      _lastSavedDarkTheme = dark;
    } catch (e) {
      // Kept locally (cache): saved again on the next toggle
    }
  }

  /// On sign-out: the next account's preference must be applied
  static void reset() {
    _saveTimer?.cancel();
    _userRepository = null;
    _toggledThisSession = false;
    _lastSavedDarkTheme = null;
  }

  static bool get _isDark => ThemeSwitcher.themeMode.value == ThemeMode.dark;

  static void _apply(bool dark) => ThemeSwitcher.toggleTheme(dark);

  static Future<void> _cache(bool dark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.darkThemeKey, dark);
  }
}
