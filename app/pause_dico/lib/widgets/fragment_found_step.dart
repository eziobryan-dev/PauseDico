import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_constants.dart';
import '../models/alphabet_tier_model.dart';
import 'bookmark_art.dart';
import 'reveal_step_view.dart';

/// Reveal overlay step: a bookmark fragment was found
class FragmentFoundStep extends StatefulWidget {
  final AlphabetTier tier;
  final int count;

  /// Fragments now held, or null when they were just assembled into a bookmark
  final int? fragmentsHeld;
  final VoidCallback onContinue;

  const FragmentFoundStep({
    super.key,
    required this.tier,
    required this.count,
    required this.fragmentsHeld,
    required this.onContinue,
  });

  @override
  State<FragmentFoundStep> createState() => _FragmentFoundStepState();
}

class _FragmentFoundStepState extends State<FragmentFoundStep> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final held = widget.fragmentsHeld;
    return RevealStepView(
      title: widget.count > 1
          ? 'Vous avez trouvé ${widget.count} fragments de marque-page '
              '${widget.tier.masculine} !'
          : 'Vous avez trouvé un ${widget.tier.fragmentName} !',
      art: BookmarkArt.fragment(tier: widget.tier, size: 120),
      caption: held == null
          ? null
          : '$held / ${AppConstants.fragmentsPerBookmark} fragments',
      onContinue: widget.onContinue,
    );
  }
}
