import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/constants/app_constants.dart';

/// Google AdMob: consent (UMP, required in Europe), banner and rewarded ads.
/// Never throws: without consent or network, the app simply shows no ads.
class AdService {
  /// True once consent is gathered and the SDK started: ads can be requested
  static final ValueNotifier<bool> isReady = ValueNotifier(false);

  static bool _initStarted = false;

  static String get bannerUnitId => Platform.isIOS
      ? AppConstants.admobBannerIos
      : AppConstants.admobBannerAndroid;

  static String get rewardedUnitId => Platform.isIOS
      ? AppConstants.admobRewardedIos
      : AppConstants.admobRewardedAndroid;

  /// Shows the consent form if needed (first launch in Europe), then starts
  /// the SDK. Called once the user is on the home screen.
  static Future<void> init() async {
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

  /// Loads and shows a rewarded ad. True only if the user watched it until
  /// the reward was granted.
  static Future<bool> showRewardedAd() async {
    if (!isReady.value) return false;
    final ad = await _loadRewardedAd();
    if (ad == null) return false;

    final closed = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        closed.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        closed.complete(false);
      },
    );
    await ad.show(onUserEarnedReward: (_, _) => earned = true);
    return closed.future;
  }

  static Future<RewardedAd?> _loadRewardedAd() {
    final loaded = Completer<RewardedAd?>();
    RewardedAd.load(
      adUnitId: rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: loaded.complete,
        onAdFailedToLoad: (_) => loaded.complete(null),
      ),
    );
    return loaded.future;
  }
}
