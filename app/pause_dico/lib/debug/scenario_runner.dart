import 'package:flutter/material.dart';

import '../core/utils/app_clock.dart';
import '../core/utils/app_environment.dart';
import '../repositories/repositories.dart';
import '../screens/alphabet_screen.dart';
import '../screens/home_screen.dart';
import '../screens/notebook_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/user_screen.dart';
import 'debug_scenario.dart';
import 'fake_backend.dart';

/// Puts the app in a scenario's situation: simulated ads / notifications,
/// moved clock, and the scenario's in-memory server behind every repository
abstract class ScenarioRunner {
  static FakeBackend install(DebugScenario scenario, {Duration? latency}) {
    AppEnvironment.simulated = true;
    AppClock.travelTo(scenario.now);
    final backend = scenario.build();
    if (latency != null) backend.latency = latency;
    Repositories.override(
      auth: () => backend,
      user: () => backend,
      gameProfile: () => backend,
      history: () => backend,
      quiz: () => backend,
    );
    return backend;
  }

  /// Screen the scenario opens on; [onExit] closes it (onboarding finished)
  static Widget screenFor(DebugScenario scenario, {required VoidCallback onExit}) {
    return switch (scenario.start) {
      ScenarioStart.home => const HomeScreen(),
      ScenarioStart.alphabet => const AlphabetScreen(),
      ScenarioStart.notebook => const NotebookScreen(),
      ScenarioStart.profile => const UserScreen(),
      ScenarioStart.onboarding => OnboardingScreen(onDone: onExit),
    };
  }
}
