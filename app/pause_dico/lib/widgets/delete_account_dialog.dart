import 'package:flutter/material.dart';

/// Confirmation before permanently deleting the account.
/// Returns true when confirmed.
class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = theme.colorScheme.error;
    return AlertDialog(
      icon: Icon(Icons.delete_forever, color: error, size: 40),
      title: const Text('Supprimer mon compte ?'),
      content: Text(
        'Votre compte et toutes vos données (mots découverts, carnet, '
        'progression, quiz) seront définitivement supprimés.\n\n'
        'Cette action est irréversible.',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer'),
        ),
      ],
    );
  }
}
