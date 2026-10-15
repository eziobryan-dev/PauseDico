import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/date_helpers.dart';
import '../models/user_model.dart';

class UserRepository {
  final SupabaseClient _client;

  UserRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetches profile metadata from the 'user' table for the logged-in user
  Future<UserModel?> getUser() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return null;

    final response = await _client
        .from(AppConstants.userTable)
        .select()
        .eq('id', currentUser.id)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  /// Updates the dark theme preference of the logged-in user
  Future<void> patchDarkTheme(bool darkTheme) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) return;

    await _client
        .from(AppConstants.userTable)
        .update({'dark_theme': darkTheme})
        .eq('id', currentUser.id);
  }

  /// Updates the daily notification time in the 'user' table
  Future<void> patchNotifTime(String userId, TimeOfDay time) async {
    await _client
        .from(AppConstants.userTable)
        .update({'notif_time': DateHelpers.toTimeString(time)})
        .eq('id', userId);
  }

  /// Updates the username in the 'user' table
  Future<void> patchUsername(String userId, String newUsername) async {
    await _client
        .from(AppConstants.userTable)
        .update({'username': newUsername})
        .eq('id', userId);
  }
}