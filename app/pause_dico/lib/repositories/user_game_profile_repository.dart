import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/date_helpers.dart';
import '../models/reward_summary_model.dart';
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

  /// Whether a rewarded ad can still give a skip today (once a day, and only
  /// below the stock cap)
  Future<bool> canClaimAdSkip(DateTime today) async {
    final response = await _client.rpc(
      AppConstants.canClaimAdSkipRpc,
      params: {'p_date': DateHelpers.toIsoDateString(today)},
    );
    return response as bool? ?? false;
  }

  /// Unlocks a locked letter of the current Alphadex tier with a bookmark
  Future<RewardSummaryModel> useBookmark(DateTime today, String letter) async {
    final response = await _client.rpc(
      AppConstants.useBookmarkRpc,
      params: {'p_date': DateHelpers.toIsoDateString(today), 'p_letter': letter},
    );
    return RewardSummaryModel.fromJson(response as Map<String, dynamic>);
  }

  /// Grants the skip of a rewarded ad the user just watched
  Future<RewardSummaryModel> claimAdSkip(DateTime today) async {
    final response = await _client.rpc(
      AppConstants.claimAdSkipRpc,
      params: {'p_date': DateHelpers.toIsoDateString(today)},
    );
    return RewardSummaryModel.fromJson(response as Map<String, dynamic>);
  }
}
