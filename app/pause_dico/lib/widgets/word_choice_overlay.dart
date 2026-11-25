import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/daily_word_choice_model.dart';
import '../models/daily_word_reveal_model.dart';
import 'error_banner.dart';
import 'green_action_button.dart';
import 'pop_in.dart';
import 'word_choice_tile.dart';

/// Non-dismissible blurred screen showing the 3 daily word candidates (word
/// and theme). It opens right away with a spinner while they load. The user
/// selects one, then "Suivant" saves the choice server-side and closes the
/// overlay with the revealed word. Leaving before that changes nothing: the
/// same 3 words come back next time.
class WordChoiceOverlay extends StatefulWidget {
  final Future<List<DailyWordChoiceModel>> Function() loadChoices;
  final Future<DailyWordRevealModel> Function(int wordId) onPick;

  const WordChoiceOverlay({
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
          WordChoiceOverlay(loadChoices: loadChoices, onPick: onPick),
    );
  }

  @override
  State<WordChoiceOverlay> createState() => _WordChoiceOverlayState();
}

class _WordChoiceOverlayState extends State<WordChoiceOverlay> {
  List<DailyWordChoiceModel>? _choices;
  bool _loadFailed = false;
  int? _selectedWordId;
  bool _isSaving = false;
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
        _errorMessage = 'Impossible de charger les mots du jour.';
      });
    }
  }

  void _select(DailyWordChoiceModel choice) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedWordId = choice.wordId;
      _errorMessage = null;
    });
  }

  Future<void> _confirm() async {
    final wordId = _selectedWordId;
    if (wordId == null) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final reveal = await widget.onPick(wordId);
      if (mounted) Navigator.of(context).pop(reveal);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Impossible de valider ce mot. Réessaie.';
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
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Choisis ton mot du jour',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  Expanded(child: Center(child: _buildContent())),
                  if (_errorMessage != null) ...[
                    ErrorBanner(message: _errorMessage!),
                    const SizedBox(height: 12),
                  ],
                  if (_choices != null)
                    GreenActionButton(
                      label: _isSaving ? 'Un instant…' : 'Suivant',
                      onPressed: _selectedWordId == null || _isSaving ? null : _confirm,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final choices = _choices;

    if (_loadFailed) {
      // Nothing to pick: let the user retry or leave the overlay
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          FilledButton.icon(
            onPressed: _loadChoices,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      );
    }

    if (choices == null) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final colors = [colorScheme.primary, colorScheme.secondary, colorScheme.tertiary];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < choices.length && i < colors.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: PopIn(
                delay: Duration(milliseconds: 150 * i),
                child: WordChoiceTile(
                  name: choices[i].name,
                  theme: choices[i].theme,
                  color: colors[i],
                  isSelected: _selectedWordId == choices[i].wordId,
                  onTap: _isSaving ? null : () => _select(choices[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
