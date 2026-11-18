/// Single source of "now" for the app, so that a test scenario can move the
/// whole app to another day (a Sunday, the day before a streak bonus…).
/// Always use [AppClock.now] / [AppClock.today] instead of `DateTime.now()`.
abstract class AppClock {
  static Duration _offset = Duration.zero;

  /// Current time, shifted when a scenario moved the clock
  static DateTime now() => DateTime.now().add(_offset);

  /// Current calendar day (midnight)
  static DateTime today() {
    final current = now();
    return DateTime(current.year, current.month, current.day);
  }

  /// Moves the clock to [moment]; time keeps flowing from there
  static void travelTo(DateTime moment) =>
      _offset = moment.difference(DateTime.now());

  /// Back to the real time
  static void reset() => _offset = Duration.zero;
}
