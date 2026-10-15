import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/constants/app_constants.dart';

/// Daily "mot du jour" reminder: permission, scheduling, and the local
/// on/off flag cached in shared_preferences.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  static AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  static IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

  /// Initializes time zones and the plugin. Call once at startup.
  static Future<void> init() async {
    tz_data.initializeTimeZones();
    final timezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timezone.identifier));

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permissions are requested when the user turns the reminder on
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  /// Asks the OS for the notification permission. Returns whether it is granted.
  static Future<bool> requestPermission() async {
    final granted = _isAndroid
        ? await _android?.requestNotificationsPermission()
        : await _ios?.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? false;
  }

  /// Whether notifications are currently allowed by the OS
  static Future<bool> hasPermission() async {
    final granted = _isAndroid
        ? await _android?.areNotificationsEnabled()
        : (await _ios?.checkPermissions())?.isEnabled;
    return granted ?? false;
  }

  /// Whether the user turned the daily reminder on (local cache)
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.dailyNotificationEnabledKey) ?? false;
  }

  /// Reminder time used when the user never picked one
  static const TimeOfDay defaultTime = TimeOfDay(
    hour: AppConstants.defaultNotifHour,
    minute: AppConstants.defaultNotifMinute,
  );

  /// Turns the reminder on at [time] and caches the flag
  static Future<void> enableDaily(TimeOfDay time) async {
    await scheduleReminders(time);
    await _setEnabled(true);
  }

  /// Cancels the reminders and caches the flag
  static Future<void> disableDaily() async {
    await _cancelReminders();
    await _setEnabled(false);
  }

  /// (Re)schedules one reminder per day for the next days at [time].
  /// Called at each app opening and after each reveal, so that:
  /// - no reminder fires today once the daily word is revealed,
  /// - the next one mentions the current streak,
  /// - Sunday's one announces the weekly quiz (no daily word that day).
  static Future<void> scheduleReminders(
    TimeOfDay time, {
    bool revealedToday = false,
    int streak = 0,
  }) async {
    await _cancelReminders();

    final now = tz.TZDateTime.now(tz.local);
    var isNext = true;
    for (var offset = 0; offset < AppConstants.scheduledRemindersCount; offset++) {
      final day = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + offset,
        time.hour,
        time.minute,
      );
      if (!day.isAfter(now) || (offset == 0 && revealedToday)) continue;

      await _plugin.zonedSchedule(
        id: AppConstants.dailyNotificationId + offset,
        body: _bodyFor(day, streak: isNext ? streak : 0),
        scheduledDate: day,
        notificationDetails: _details,
        // Inexact: no exact alarm permission needed, may fire a few minutes late
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      isNext = false;
    }
  }

  static String _bodyFor(DateTime day, {required int streak}) {
    if (day.weekday == DateTime.sunday) return AppConstants.weeklyQuizNotificationBody;
    if (streak >= 2) {
      return '🔥 Ne casse pas ta série de $streak jours ! '
          '${AppConstants.dailyNotificationBody}';
    }
    return AppConstants.dailyNotificationBody;
  }

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      AppConstants.dailyNotificationChannelId,
      AppConstants.dailyNotificationChannelName,
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> _cancelReminders() async {
    for (var offset = 0; offset < AppConstants.scheduledRemindersCount; offset++) {
      await _plugin.cancel(id: AppConstants.dailyNotificationId + offset);
    }
  }

  static Future<void> _setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.dailyNotificationEnabledKey, enabled);
  }
}
