import 'fake_backend.dart';

/// Screen a scenario opens on
enum ScenarioStart { home, alphabet, notebook, profile, onboarding }

/// A ready-made situation of the app (a user, a day, a server state), opened
/// directly without signing in nor touching the database
class DebugScenario {
  /// Used with `--dart-define=SCENARIO=<id>` and in the tests
  final String id;
  final String category;
  final String title;

  /// What to look at / try once the scenario is open
  final String description;

  /// Date and time the app believes it is
  final DateTime now;
  final ScenarioStart start;

  /// Builds a fresh server state (each opening starts over)
  final FakeBackend Function() build;

  const DebugScenario({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.now,
    required this.build,
    this.start = ScenarioStart.home,
  });
}
