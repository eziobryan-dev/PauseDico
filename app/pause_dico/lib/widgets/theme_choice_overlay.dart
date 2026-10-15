import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/daily_word_choice_model.dart';
import '../models/daily_word_reveal_model.dart';
import 'error_banner.dart';
import 'pop_in.dart';
import 'theme_choice_tag.dart';

/// Non-dismissible blurred screen showing the 3 candidate themes at 25%, 50%
/// and 75% of the screen height. It opens right away with a spinner while the
/// themes load, then the tags pop in. Picking one reveals its word and closes
/// the overlay with the result.
class ThemeChoiceOverlay extends StatefulWidget {
  final Future<List<DailyWordChoiceModel>> Function() loadChoices;
  final Future<DailyWordRevealModel> Function(int wordId) onPick;

  const ThemeChoiceOverlay({
    super.key,
    required this.loadChoices,
    required this.onPick,
  });

  static Future<DailyWordRevealModel?> show(
    BuildContext context, {
    required Future<List<DailyWordChoiceModel>> Function() loadChoices,
    required Future<DailyWordRevealModel> Function(int wordId) onPick,
  }) {
    return showGeneralDialog<DailyWordRevealModel>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, _) =>
          ThemeChoiceOverlay(loadChoices: loadChoices, onPick: onPick),
    );
  }

  @override
  State<ThemeChoiceOverlay> createState() => _ThemeChoiceOverlayState();
}

class _ThemeChoiceOverlayState extends State<ThemeChoiceOverlay> {
  /// Vertical positions: 25%, 50% and 75% of the screen height
  static const _alignments = [
    Alignment(0, -0.5),
    Alignment(0, 0),
    Alignment(0, 0.5),
  ];

  List<DailyWordChoiceModel>? _choices;
  bool _loadFailed = false;
  int? _pickingWordId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChoices();
  }

  Future<void> _loadChoices() async {
    setState(() {
      _loadFailed = false;
      _errorMessage = null;
    });
    try {
      final choices = await widget.loadChoices();
      if (mounted) setState(() => _choices = choices);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadFailed = true;
        _errorMessage = 'Impossible de charger les thèmes.';
      });
    }
  }

  Future<void> _pick(DailyWordChoiceModel choice) async {
    HapticFeedback.selectionClick();
    setState(() {
      _pickingWordId = choice.wordId;
      _errorMessage = null;
    });

    try {
      final reveal = await widget.onPick(choice.wordId);
      if (mounted) Navigator.of(context).pop(reveal);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pickingWordId = null;
        _errorMessage = 'Impossible de révéler ce mot. Réessaie.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: const Alignment(0, -0.9),
                  child: Text(
                    'Choisis un thème',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
                ..._buildContent(),
                if (_errorMessage != null)
                  Align(
                    alignment: const Alignment(0, 0.9),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ErrorBanner(message: _errorMessage!),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    final choices = _choices;

    if (_loadFailed) {
      // Nothing to pick: let the user retry or leave the overlay
      return [
        Align(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _loadChoices,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ];
    }

    if (choices == null) {
      return const [
        Center(child: CircularProgressIndicator(color: Colors.white)),
      ];
    }

    final colorScheme = Theme.of(context).colorScheme;
    final colors = [colorScheme.primary, colorScheme.secondary, colorScheme.tertiary];

    return [
      for (var i = 0; i < choices.length && i < 3; i++)
        Align(
          alignment: _alignments[i],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PopIn(
              delay: Duration(milliseconds: 150 * i),
              child: ThemeChoiceTag(
                theme: choices[i].theme,
                color: colors[i],
                isLoading: _pickingWordId == choices[i].wordId,
                onTap: _pickingWordId == null ? () => _pick(choices[i]) : null,
              ),
            ),
          ),
        ),
    ];
  }
}
