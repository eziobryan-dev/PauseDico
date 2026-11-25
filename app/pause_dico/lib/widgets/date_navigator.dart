import 'package:flutter/material.dart';

import '../core/utils/app_clock.dart';
import '../core/utils/date_helpers.dart';

/// Displays a date in French with previous / next day arrows. Tapping the
/// date opens a calendar: days before [firstDate] (account creation) and
/// after today are greyed out. Without a next day, [trailing] (if any) takes
/// the place of the next arrow.
class DateNavigator extends StatelessWidget {
  final DateTime date;
  final DateTime firstDate;
  final bool canGoPrevious;
  final bool canGoNext;
  final ValueChanged<int> onChangeDay;
  final ValueChanged<DateTime> onPickDate;
  final Widget? trailing;

  const DateNavigator({
    super.key,
    required this.date,
    required this.firstDate,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onChangeDay,
    required this.onPickDate,
    this.trailing,
  });

  Future<void> _openCalendar(BuildContext context) async {
    final today = AppClock.today();
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateHelpers.dateOnly(firstDate),
      lastDate: today,
      helpText: 'Aller au mot du…',
    );
    if (picked != null) onPickDate(DateHelpers.dateOnly(picked));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _arrow(Icons.chevron_left, visible: canGoPrevious, offset: -1),
        Flexible(
          child: TextButton.icon(
            onPressed: () => _openCalendar(context),
            icon: const Icon(Icons.calendar_month, size: 20),
            // Shrinks on narrow screens (next to the "next quiz" pill)
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                DateHelpers.formatFrenchDate(date),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        if (!canGoNext && trailing != null)
          trailing!
        else
          _arrow(Icons.chevron_right, visible: canGoNext, offset: 1),
      ],
    );
  }

  Widget _arrow(IconData icon, {required bool visible, required int offset}) {
    return Visibility(
      visible: visible,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: IconButton(
        icon: Icon(icon),
        onPressed: () => onChangeDay(offset),
      ),
    );
  }
}
