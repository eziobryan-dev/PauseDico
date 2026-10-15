import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/context_extensions.dart';
import '../services/link_service.dart';

/// "En savoir plus" link opening the word's Wiktionary page
class WiktionaryLink extends StatelessWidget {
  final String wordName;

  const WiktionaryLink({super.key, required this.wordName});

  Future<void> _open(BuildContext context) async {
    final opened = await LinkService.open(LinkService.wiktionaryUri(wordName));
    if (!opened && context.mounted) {
      context.showSnackBar("Impossible d'ouvrir le Wiktionnaire");
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _open(context),
      // No right padding: the text lines up with the card's right edge
      style: TextButton.styleFrom(
        padding: const EdgeInsets.only(left: 8),
      ),
      icon: Image.asset(
        AppConstants.wiktionaryIconAsset,
        width: 20,
        height: 20,
      ),
      label: const Text('En savoir plus'),
    );
  }
}
