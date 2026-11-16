import 'package:flutter/material.dart';

import '../models/alphabet_tier_model.dart';
import 'bookmark_assembly_animation.dart';
import 'reveal_step_view.dart';

/// Reveal overlay step: 7 fragments assemble into a bookmark. The text and
/// the button appear once the animation is over.
class BookmarkAssembledStep extends StatefulWidget {
  final AlphabetTier tier;
  final VoidCallback onContinue;

  const BookmarkAssembledStep({super.key, required this.tier, required this.onContinue});

  @override
  State<BookmarkAssembledStep> createState() => _BookmarkAssembledStepState();
}

class _BookmarkAssembledStepState extends State<BookmarkAssembledStep> {
  bool _isAssembled = false;

  @override
  Widget build(BuildContext context) {
    return RevealStepView(
      title: 'Vous avez assemblé un ${widget.tier.bookmarkName} !',
      titleBelowArt: true,
      art: BookmarkAssemblyAnimation(
        tier: widget.tier,
        onDone: () {
          if (mounted) setState(() => _isAssembled = true);
        },
      ),
      caption: 'Utilise-le dans ton Alphadex pour débloquer une lettre.',
      onContinue: _isAssembled ? widget.onContinue : null,
    );
  }
}
