import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

/// Remembers (on the device) whether the welcome screens were seen
abstract class OnboardingService {
  static Future<bool> isDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.onboardingDoneKey) ?? false;
  }

  static Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingDoneKey, true);
  }
}
