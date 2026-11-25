import 'package:flutter/material.dart';

import 'app_clock.dart';

abstract class DateHelpers {
  /// Returns the date without its time component.
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Adds calendar days (not 24h periods): stays at midnight across daylight
  /// saving changes.
  static DateTime addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  /// Number of calendar days from [from] to [to], ignoring the time of day
  /// and daylight saving changes.
  static int daysBetween(DateTime from, DateTime to) =>
      DateTime.utc(to.year, to.month, to.day)
          .difference(DateTime.utc(from.year, from.month, from.day))
          .inDays;

  /// Returns the Monday of the week ending on the given Sunday.
  static DateTime weekStart(DateTime sunday) => addDays(sunday, -6);

  /// Returns the Saturday preceding the given Sunday.
  static DateTime weekEnd(DateTime sunday) => addDays(sunday, -1);

  /// Days until the next Sunday (weekly quiz day), 0 on a Sunday.
  static int daysUntilSunday(DateTime date) =>
      (DateTime.sunday - date.weekday) % DateTime.daysPerWeek;

  /// Returns the date formatted as ISO string 'YYYY-MM-DD' for SQL queries.
  static String toIsoDateString([DateTime? date]) {
    final targetDate = date ?? AppClock.now();
    final year = targetDate.year;
    final month = targetDate.month.toString().padLeft(2, '0');
    final day = targetDate.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Whether a daily reload boundary was crossed between [lastLoad] and [now]:
  /// midnight (new day) or today's [notifTime] (daily reminder).
  static bool hasCrossedDailyBoundary(
    DateTime lastLoad,
    DateTime now,
    TimeOfDay? notifTime,
  ) {
    final today = dateOnly(now);
    final boundaries = [
      today,
      if (notifTime != null)
        today.add(Duration(hours: notifTime.hour, minutes: notifTime.minute)),
    ];
    return boundaries.any(
      (boundary) => lastLoad.isBefore(boundary) && !now.isBefore(boundary),
    );
  }

  /// Parses a SQL time 'HH:mm[:ss]' into a TimeOfDay (null if absent).
  static TimeOfDay? parseTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Formats a TimeOfDay as SQL time 'HH:mm'.
  static String toTimeString(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Formats a DateTime into a human-readable French date string.
  /// Example: "Lundi 28 septembre 2026"
  static String formatFrenchDate([DateTime? date]) {
    final targetDate = date ?? AppClock.now();

    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];

    const days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
    ];

    final dayName = days[targetDate.weekday - 1];
    final monthName = months[targetDate.month - 1];

    return '$dayName ${targetDate.day} $monthName ${targetDate.year}';
  }
}
