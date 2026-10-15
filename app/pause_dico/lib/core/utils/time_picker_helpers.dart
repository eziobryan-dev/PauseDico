import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class TimePickerHelpers {
  /// Shows the platform's own time picker (hours + minutes, 24h):
  /// the Cupertino wheel on iOS, the Material clock on Android.
  /// Returns null if the user cancels.
  static Future<TimeOfDay?> pickTime(BuildContext context, TimeOfDay initial) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _pickCupertinoTime(context, initial);
    }
    return showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'Heure du rappel',
      cancelText: 'Annuler',
      confirmText: 'Valider',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
  }

  static Future<TimeOfDay?> _pickCupertinoTime(
    BuildContext context,
    TimeOfDay initial,
  ) {
    var selected = initial;
    final now = DateTime.now();

    return showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  CupertinoButton(
                    onPressed: () => Navigator.of(context).pop(selected),
                    child: const Text('Valider'),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  initialDateTime: DateTime(
                    now.year,
                    now.month,
                    now.day,
                    initial.hour,
                    initial.minute,
                  ),
                  onDateTimeChanged: (value) =>
                      selected = TimeOfDay.fromDateTime(value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
