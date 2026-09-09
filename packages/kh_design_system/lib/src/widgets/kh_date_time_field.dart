import 'package:flutter/material.dart';

import '../tokens.dart';

/// SH-FND-09 modes — date only (licence expiry) or schedule (date + time).
enum KhDateTimeMode { dateOnly, dateTime }

/// Optional override for [showDatePicker] (tests / custom hosts).
typedef KhPickDate = Future<DateTime?> Function(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
});

/// Optional override for [showTimePicker].
typedef KhPickTime = Future<TimeOfDay?> Function(
  BuildContext context, {
  required TimeOfDay initialTime,
});

/// SH-FND-09 — date / time picker field.
class KhDateTimeField extends StatelessWidget {
  const KhDateTimeField({
    super.key,
    required this.label,
    required this.onChanged,
    this.value,
    this.mode = KhDateTimeMode.dateOnly,
    this.emptyLabel,
    this.errorText,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.pickDate,
    this.pickTime,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final KhDateTimeMode mode;
  final String? emptyLabel;
  final String? errorText;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final KhPickDate? pickDate;
  final KhPickTime? pickTime;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final display = value == null
        ? (emptyLabel ?? label)
        : _format(context, value!, mode);

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      value: value == null ? null : display,
      child: InkWell(
        key: const Key('kh-date-time-field'),
        onTap: enabled ? () => _openPicker(context) : null,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            errorText: errorText,
            suffixIcon: Icon(
              mode == KhDateTimeMode.dateTime
                  ? Icons.event_available
                  : Icons.calendar_today,
              color: tokens.ink.withValues(alpha: enabled ? 0.7 : 0.35),
            ),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: tokens.space.xs),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                display,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: tokens.ink.withValues(
                        alpha: value == null || !enabled ? 0.55 : 1,
                      ),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final now = DateTime.now();
    final initial = value ?? now;
    final first = firstDate ?? DateTime(now.year - 20);
    final last = lastDate ?? DateTime(now.year + 20);

    final clampedInitial = initial.isBefore(first)
        ? first
        : initial.isAfter(last)
            ? last
            : initial;

    final pickedDate = pickDate != null
        ? await pickDate!(
            context,
            initialDate: clampedInitial,
            firstDate: first,
            lastDate: last,
          )
        : await showDatePicker(
            context: context,
            initialDate: clampedInitial,
            firstDate: first,
            lastDate: last,
          );

    if (pickedDate == null || !context.mounted) return;

    if (mode == KhDateTimeMode.dateOnly) {
      onChanged(DateTime(pickedDate.year, pickedDate.month, pickedDate.day));
      return;
    }

    final initialTime = TimeOfDay.fromDateTime(value ?? clampedInitial);
    final pickedTime = pickTime != null
        ? await pickTime!(context, initialTime: initialTime)
        : await showTimePicker(
            context: context,
            initialTime: initialTime,
          );

    if (pickedTime == null || !context.mounted) return;

    onChanged(
      DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      ),
    );
  }

  static String _format(
    BuildContext context,
    DateTime value,
    KhDateTimeMode mode,
  ) {
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatShortDate(value);
    if (mode == KhDateTimeMode.dateOnly) return date;
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(value),
      alwaysUse24HourFormat: true,
    );
    return '$date, $time';
  }
}
