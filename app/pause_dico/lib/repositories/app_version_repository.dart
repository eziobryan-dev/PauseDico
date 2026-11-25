import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/app_constants.dart';

class AppVersionRepository {
  final SupabaseClient _client;

  AppVersionRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Minimum build number allowed on [platform] ('android' / 'ios'), null
  /// when none is set. Readable before sign-in.
  Future<int?> getMinBuild(String platform) async {
    final response = await _client
        .from(AppConstants.appVersionPolicyTable)
        .select('min_build')
        .eq('platform', platform)
        .maybeSingle();
    return response?['min_build'] as int?;
  }
}
