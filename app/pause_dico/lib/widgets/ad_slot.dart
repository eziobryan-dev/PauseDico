import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';

/// Adaptive banner anchored at the bottom of the screen (full width, height
/// chosen by Google, at most 15% of the screen). Takes no space until an ad
/// is loaded, nor when ads are unavailable (no consent, no network).
class AdSlot extends StatefulWidget {
  const AdSlot({super.key});

  @override
  State<AdSlot> createState() => _AdSlotState();
}

class _AdSlotState extends State<AdSlot> {
  BannerAd? _ad;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    AdService.isReady.addListener(_onAdsReady);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onAdsReady();
  }

  @override
  void dispose() {
    AdService.isReady.removeListener(_onAdsReady);
    _ad?.dispose();
    super.dispose();
  }

  void _onAdsReady() {
    if (AdService.isReady.value && _ad == null && mounted) _load();
  }

  Future<void> _load() async {
    final width = MediaQuery.sizeOf(context).width.truncate();
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted || _ad != null) return;

    _ad = BannerAd(
      size: size,
      adUnitId: AdService.bannerUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_isLoaded || ad == null) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
