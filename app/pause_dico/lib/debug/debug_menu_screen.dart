import 'package:flutter/material.dart';

import '../core/utils/context_extensions.dart';
import '../widgets/screen_title.dart';
import 'debug_scenario.dart';
import 'debug_scenarios.dart';
import 'scenario_runner.dart';
import 'scenario_tile.dart';

/// Debug builds only (`--dart-define=SCENARIO=menu`): every scenario of
/// [DebugScenarios], opened on simulated data. Back returns here, and each
/// opening starts the scenario over.
class DebugMenuScreen extends StatefulWidget {
  /// Scenario opened right away (`--dart-define=SCENARIO=<id>`)
  final String? autoStartId;

  const DebugMenuScreen({super.key, this.autoStartId});

  @override
  State<DebugMenuScreen> createState() => _DebugMenuScreenState();
}

class _DebugMenuScreenState extends State<DebugMenuScreen> {
  @override
  void initState() {
    super.initState();
    final id = widget.autoStartId;
    if (id == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scenario = DebugScenarios.byId(id);
      if (scenario != null) {
        _open(scenario);
      } else if (mounted) {
        context.showSnackBar('Scénario « $id » inconnu');
      }
    });
  }

  void _open(DebugScenario scenario) {
    if (!mounted) return;
    final navigator = Navigator.of(context);
    final backend = ScenarioRunner.install(scenario);
    // Sign out / account deletion: back to the menu
    backend.onSignedOut = () => navigator.popUntil((route) => route.isFirst);
    navigator.push(
      MaterialPageRoute(
        builder: (_) => ScenarioRunner.screenFor(scenario, onExit: navigator.pop),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = {for (final s in DebugScenarios.all) s.category};
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const ScreenTitle('Scénarios de test')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          for (final category in categories) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Text(
                category,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            for (final scenario in DebugScenarios.all.where((s) => s.category == category))
              ScenarioTile(scenario: scenario, onTap: () => _open(scenario)),
          ],
        ],
      ),
    );
  }
}
