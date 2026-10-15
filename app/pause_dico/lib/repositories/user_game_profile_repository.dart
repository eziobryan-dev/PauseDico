import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_constants.dart';
import '../models/user_game_profile_model.dart';

class UserGameProfileRepository {
  final SupabaseClient _client;

  UserGameProfileRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Fetches the game profile (level, xp, skip tokens…) of the logged-in user
  Future<UserGameProfileModel?> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from(AppConstants.userGameProfileTable)
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserGameProfileModel.fromJson(response);
  }
}
