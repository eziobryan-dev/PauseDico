import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/constants/app_constants.dart';
import '../repositories/app_version_repository.dart';

/// Forced updates: the server stores the minimum build per platform
/// (app_version_policy); an older installed build must update to continue.
abstract class AppUpdateService {
  static String get _platform => Platform.isIOS ? 'ios' : 'android';

  /// Launch is never held longer than this by the check
  static const Duration _timeout = Duration(seconds: 3);

  /// True when the installed build is older than the server minimum. Never
  /// blocks on error (offline, table unreachable…) nor in debug builds.
  static Future<bool> isUpdateRequired({AppVersionRepository? repository}) async {
    if (kDebugMode) return false;
    try {
      final minBuild = await (repository ?? AppVersionRepository())
          .getMinBuild(_platform)
          .timeout(_timeout);
      if (minBuild == null) return false;
      final info = await PackageInfo.fromPlatform();
      final build = int.tryParse(info.buildNumber) ?? 0;
      return build < minBuild;
    } catch (e) {
      return false;
    }
  }

  /// Opens the app's store page
  static Future<void> openStore() async {
    await launchUrl(
      Uri.parse(AppConstants.playStoreUrl),
      mode: LaunchMode.externalApplication,
    );
  }
}
