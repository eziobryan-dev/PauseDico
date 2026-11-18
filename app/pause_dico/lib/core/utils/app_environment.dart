/// Whether the app runs on simulated data (debug scenarios, widget tests).
/// When true, services with side effects outside the app (AdMob, system
/// notifications) are simulated instead of calling their plugin.
abstract class AppEnvironment {
  static bool simulated = false;
}
