import 'package:flutter/material.dart';

import '../tokens.dart';

/// Built-in presets for SH-FND-10 (aligned with SH-ADM-10 / SRS today·7·30·90).
enum KhDateRangePreset { today, last7, last30, last90, custom }

/// Optional override for [showDateRangePicker] (tests / custom hosts).
typedef KhPickDateRange = Future<DateTimeRange?> Function(
  BuildContext context, {
  required DateTimeRange? initialDateRange,
  required DateTime firstDate,
  required DateTime lastDate,
});

/// Result emitted by [KhDateRangePicker].
class KhDateRangeSelection {
  const KhDateRangeSelection({
    required this.range,
    required this.preset,
  });

  final DateTimeRange range;
  final KhDateRangePreset preset;
}

/// SH-FND-10 — date range picker with presets + custom.
class KhDateRangePicker extends StatelessWidget {
  const KhDateRangePicker({
    super.key,
    required this.onChanged,
    this.range,
    this.preset,
    this.label,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.now,
    this.pickRange,
    this.presets = const [
      KhDateRangePreset.today,
      KhDateRangePreset.last7,
      KhDateRangePreset.last30,
      KhDateRangePreset.last90,
      KhDateRangePreset.custom,
    ],
  });

  final ValueChanged<KhDateRangeSelection> onChanged;
  final DateTimeRange? range;
  final KhDateRangePreset? preset;
  final String? label;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;

  /// Clock override for deterministic presets / tests.
  final DateTime? now;
  final KhPickDateRange? pickRange;
  final List<KhDateRangePreset> presets;

  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTimeRange rangeForPreset(
    KhDateRangePreset preset, {
    required DateTime now,
  }) {
    final end = dateOnly(now);
    switch (preset) {
      case KhDateRangePreset.today:
        return DateTimeRange(start: end, end: end);
      case KhDateRangePreset.last7:
        return DateTimeRange(
          start: end.subtract(const Duration(days: 6)),
          end: end,
        );
      case KhDateRangePreset.last30:
        return DateTimeRange(
          start: end.subtract(const Duration(days: 29)),
          end: end,
        );
      case KhDateRangePreset.last90:
        return DateTimeRange(
          start: end.subtract(const Duration(days: 89)),
          end: end,
        );
      case KhDateRangePreset.custom:
        return DateTimeRange(
          start: end.subtract(const Duration(days: 29)),
          end: end,
        );
    }
  }

  static String labelForPreset(KhDateRangePreset preset) {
    switch (preset) {
      case KhDateRangePreset.today:
        return 'Today';
      case KhDateRangePreset.last7:
        return '7 days';
      case KhDateRangePreset.last30:
        return '30 days';
      case KhDateRangePreset.last90:
        return '90 days';
      case KhDateRangePreset.custom:
        return 'Custom';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final selected = preset;
    final summary = range == null ? null : _formatRange(context, range!);

    return Semantics(
      container: true,
      label: label ?? 'Date range',
      child: Column(
        key: const Key('kh-date-range-picker'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(label!, style: Theme.of(context).textTheme.titleSmall),
            SizedBox(height: tokens.space.sm),
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final item in presets) ...[
                  _PresetChip(
                    preset: item,
                    selected: selected == item,
                    enabled: enabled,
                    onTap: () => _onPresetTap(context, item),
                  ),
                  SizedBox(width: tokens.space.sm),
                ],
              ],
            ),
          ),
          if (summary != null) ...[
            SizedBox(height: tokens.space.sm),
            Text(
              summary,
              key: const Key('kh-date-range-summary'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.ink.withValues(alpha: enabled ? 0.8 : 0.45),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _onPresetTap(
    BuildContext context,
    KhDateRangePreset item,
  ) async {
    if (!enabled) return;
    final clock = now ?? DateTime.now();

    if (item != KhDateRangePreset.custom) {
      onChanged(
        KhDateRangeSelection(
          range: rangeForPreset(item, now: clock),
          preset: item,
        ),
      );
      return;
    }

    final first = firstDate ?? DateTime(clock.year - 20);
    final last = lastDate ?? dateOnly(clock);
    final initial = range ?? rangeForPreset(KhDateRangePreset.last30, now: clock);

    final picked = pickRange != null
        ? await pickRange!(
            context,
            initialDateRange: initial,
            firstDate: first,
            lastDate: last,
          )
        : await showDateRangePicker(
            context: context,
            firstDate: first,
            lastDate: last,
            initialDateRange: initial,
          );

    if (picked == null) return;

    onChanged(
      KhDateRangeSelection(
        range: DateTimeRange(
          start: dateOnly(picked.start),
          end: dateOnly(picked.end),
        ),
        preset: KhDateRangePreset.custom,
      ),
    );
  }

  static String _formatRange(BuildContext context, DateTimeRange range) {
    final localizations = MaterialLocalizations.of(context);
    final start = localizations.formatShortDate(range.start);
    final end = localizations.formatShortDate(range.end);
    return '$start – $end';
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.preset,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final KhDateRangePreset preset;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final label = KhDateRangePicker.labelForPreset(preset);

    return Material(
      color: selected
          ? tokens.gold.withValues(alpha: 0.28)
          : tokens.ink.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(tokens.radius.lg),
      child: InkWell(
        key: Key('kh-date-range-preset-${preset.name}'),
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: tokens.space.md,
            vertical: tokens.space.sm,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: tokens.ink.withValues(
                    alpha: enabled ? (selected ? 1 : 0.7) : 0.4,
                  ),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
