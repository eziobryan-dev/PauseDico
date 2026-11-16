import 'package:flutter/material.dart';

import '../../models/alphabet_tier_model.dart';

/// Colors of the Alphadex tiers (letters, bookmarks, fragments)
abstract class TierColors {
  static const _gold = [
    Color(0xFFB8860B),
    Color(0xFFFFD700),
    Color(0xFFFFF8DC),
    Color(0xFFFFD700),
    Color(0xFFB8860B),
  ];

  static const _emerald = [
    Color(0xFF046307),
    Color(0xFF2ECC71),
    Color(0xFFD5FFE4),
    Color(0xFF2ECC71),
    Color(0xFF046307),
  ];

  /// Dark → light → dark: a shiny metal / gem band
  static List<Color> shine(AlphabetTier tier) =>
      tier == AlphabetTier.gold ? _gold : _emerald;

  static Color main(AlphabetTier tier) => shine(tier)[1];

  static Color dark(AlphabetTier tier) => shine(tier)[0];
}
