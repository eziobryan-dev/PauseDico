import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pause_dico/core/utils/app_clock.dart';
import 'package:pause_dico/core/utils/app_environment.dart';
import 'package:pause_dico/debug/debug_scenarios.dart';
import 'package:pause_dico/debug/fake_backend.dart';
import 'package:pause_dico/debug/scenario_runner.dart';
import 'package:pause_dico/main.dart';
import 'package:pause_dico/repositories/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the debug scenario [id] on a phone-sized screen, with no network
/// delay, and returns its fake server to check what the actions changed
Future<FakeBackend> pumpScenario(WidgetTester tester, String id) async {
  final scenario = DebugScenarios.byId(id);
  if (scenario == null) throw ArgumentError('Scénario inconnu : $id');

  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(() {
    tester.view.reset();
    AppClock.reset();
    Repositories.reset();
    AppEnvironment.simulated = false;
  });

  final backend = ScenarioRunner.install(scenario, latency: Duration.zero);
  await tester.pumpWidget(
    PauseDicoApp(home: ScenarioRunner.screenFor(scenario, onExit: () {})),
  );
  await settle(tester);
  return backend;
}

/// Lets loads, animations and delayed steps finish. Unlike pumpAndSettle it
/// also works with endless animations (glowing quiz icon, letter shine).
Future<void> settle(WidgetTester tester, [Duration duration = const Duration(seconds: 4)]) async {
  const step = Duration(milliseconds: 100);
  for (var elapsed = Duration.zero; elapsed < duration; elapsed += step) {
    await tester.pump(step);
  }
}

/// Taps [finder] (scrolled into view first) and lets the UI settle
Future<void> tapAndSettle(WidgetTester tester, Finder finder, [Duration? duration]) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await settle(tester, duration ?? const Duration(seconds: 4));
}
