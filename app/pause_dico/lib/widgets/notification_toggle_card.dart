import 'package:flutter/material.dart';

import '../core/utils/date_helpers.dart';

/// Card with the daily reminder switch and, when on, the reminder time
class NotificationToggleCard extends StatelessWidget {
  final bool enabled;
  final TimeOfDay time;
  final bool isBusy;
  final ValueChanged<bool> onChanged;
  final VoidCallback onTimeTap;

  const NotificationToggleCard({
    super.key,
    required this.enabled,
    required this.time,
    required this.isBusy,
    required this.onChanged,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Rappel quotidien'),
            subtitle: const Text('Une notification pour ton mot du jour'),
            secondary: Icon(
              enabled ? Icons.notifications_active : Icons.notifications_off,
            ),
            value: enabled,
            onChanged: isBusy ? null : onChanged,
          ),
          if (enabled)
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Heure du rappel'),
              trailing: Text(
                DateHelpers.toTimeString(time),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              onTap: isBusy ? null : onTimeTap,
            ),
        ],
      ),
    );
  }
}
