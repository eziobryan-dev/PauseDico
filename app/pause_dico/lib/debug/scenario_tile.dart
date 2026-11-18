import 'package:flutter/material.dart';

import '../core/utils/date_helpers.dart';
import 'debug_scenario.dart';

/// One scenario of the debug menu: title, what to try, and the simulated day
class ScenarioTile extends StatelessWidget {
  final DebugScenario scenario;
  final VoidCallback onTap;

  const ScenarioTile({super.key, required this.scenario, required this.onTap});

  static IconData _iconOf(ScenarioStart start) => switch (start) {
        ScenarioStart.home => Icons.home_rounded,
        ScenarioStart.alphabet => Icons.emoji_events_rounded,
        ScenarioStart.notebook => Icons.menu_book_rounded,
        ScenarioStart.profile => Icons.person,
        ScenarioStart.onboarding => Icons.waving_hand_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(_iconOf(scenario.start), color: theme.colorScheme.primary),
      title: Text(scenario.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        '${scenario.description}\n${DateHelpers.formatFrenchDate(scenario.now)} · ${scenario.id}',
      ),
      isThreeLine: true,
      trailing: const Icon(Icons.play_arrow_rounded),
      onTap: onTap,
    );
  }
}
