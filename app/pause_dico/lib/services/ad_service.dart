import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/app_environment.dart';

/// Google AdMob: consent (UMP, required in Europe) and the home banner.
/// Never throws: without consent or network, the app simply shows no ads.
class AdService {
  /// True once consent is gathered and the SDK started: ads can be requested
  static final ValueNotifier<bool> isReady = ValueNotifier(false);

  static bool _initStarted = false;

  static String get bannerUnitId => Platform.isIOS
      ? AppConstants.admobBannerIos
      : AppConstants.admobBannerAndroid;

  /// Shows the consent form if needed (first launch in Europe), then starts
  /// the SDK. Called once the user is on the home screen.
  static Future<void> init() async {
    if (AppEnvironment.simulated) {
      isReady.value = true;
      return;
    }
    if (_initStarted) return;
    _initStarted = true;
    try {
      await _gatherConsent();
      await _startIfAllowed();
    } catch (e) {
      // No ads this session
    }
  }

  static Future<void> _gatherConsent() {
    final done = Completer<void>();
    void complete([Object? _]) {
      if (!done.isCompleted) done.complete();
    }

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired(complete),
      complete,
    );
    return done.future;
  }

  static Future<void> _startIfAllowed() async {
    if (isReady.value) return;
    if (!await ConsentInformation.instance.canRequestAds()) return;
    await MobileAds.instance.initialize();
    isReady.value = true;
  }

  /// The user must be able to change their consent (from the profile)
  static Future<bool> isPrivacyOptionsRequired() async {
    if (AppEnvironment.simulated) return false;
    try {
      return await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (e) {
      return false;
    }
  }

  static Future<void> showPrivacyOptions() async {
    final done = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm((_) => done.complete());
    await done.future;
    await _startIfAllowed();
  }
}
