import 'package:flutter/material.dart';

/// Card displaying the username, editable inline
class UsernameCard extends StatelessWidget {
  final String username;
  final TextEditingController controller;
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onEdit;
  final VoidCallback onSave;

  const UsernameCard({
    super.key,
    required this.username,
    required this.controller,
    required this.isEditing,
    required this.isSaving,
    required this.onEdit,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
          children: [
            const Icon(Icons.account_circle),
            const SizedBox(width: 12),
            Expanded(
              child: isEditing
                  ? TextField(
                      controller: controller,
                      autofocus: true,
                      onSubmitted: (_) => onSave(),
                      decoration: const InputDecoration(
                        hintText: 'Nom d\'utilisateur',
                        isDense: true,
                        border: InputBorder.none,
                      ),
                    )
                  : Text(
                      username,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
            ),
            _buildTrailing(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    if (isSaving) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (isEditing) {
      return IconButton(
        icon: const Icon(Icons.check, color: Colors.green),
        tooltip: 'Valider',
        onPressed: onSave,
      );
    }
    return IconButton(
      icon: const Icon(Icons.edit),
      tooltip: 'Modifier',
      onPressed: onEdit,
    );
  }
}
