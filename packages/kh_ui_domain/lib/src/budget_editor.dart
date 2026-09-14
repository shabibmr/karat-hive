import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';

/// Selection mode for [BudgetEditor] per SH-REQ-04.
enum BudgetMode {
  maxOnly,
  range,
}

/// SH-REQ-04 — Budget editor.
///
/// Supports max-only vs min–max range modes with flexible switch and validation.
class BudgetEditor extends StatelessWidget {
  const BudgetEditor({
    super.key,
    required this.mode,
    this.budgetMin,
    this.budgetMax,
    this.budgetIsFlexible = false,
    this.mandatory = false,
    this.onModeChanged,
    this.onMinChanged,
    this.onMaxChanged,
    this.onFlexibleChanged,
    this.minErrorText,
    this.maxErrorText,
    this.label,
    this.maxOnlyLabel = 'Maximum only',
    this.rangeLabel = 'Min–max range',
    this.minLabel = 'Budget min',
    this.maxLabel = 'Budget max',
    this.flexibleLabel = 'Budget is flexible',
    this.unit = 'AED',
  });

  final BudgetMode mode;
  final String? budgetMin;
  final String? budgetMax;
  final bool budgetIsFlexible;
  final bool mandatory;
  final ValueChanged<BudgetMode>? onModeChanged;
  final ValueChanged<String?>? onMinChanged;
  final ValueChanged<String?>? onMaxChanged;
  final ValueChanged<bool>? onFlexibleChanged;
  final String? minErrorText;
  final String? maxErrorText;
  final String? label;
  final String maxOnlyLabel;
  final String rangeLabel;
  final String minLabel;
  final String maxLabel;
  final String flexibleLabel;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final titleText = label ?? (mandatory ? 'Budget' : 'Budget (optional)');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titleText,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: tokens.ink,
          ),
        ),
        SizedBox(height: tokens.space.xs),
        RadioListTile<BudgetMode>(
          key: const Key('budget-mode-max-only'),
          contentPadding: EdgeInsets.zero,
          title: Text(maxOnlyLabel),
          value: BudgetMode.maxOnly,
          groupValue: mode,
          onChanged: (v) {
            if (v != null) onModeChanged?.call(v);
          },
        ),
        RadioListTile<BudgetMode>(
          key: const Key('budget-mode-range'),
          contentPadding: EdgeInsets.zero,
          title: Text(rangeLabel),
          value: BudgetMode.range,
          groupValue: mode,
          onChanged: (v) {
            if (v != null) onModeChanged?.call(v);
          },
        ),
        SizedBox(height: tokens.space.xs),
        if (mode == BudgetMode.range) ...[
          KhNumericField(
            key: const Key('budget-min-field'),
            label: minLabel,
            unit: unit,
            decimalPlaces: 2,
            initialValue: budgetMin,
            errorText: minErrorText,
            onChanged: (v) => onMinChanged?.call(v?.toStringAsFixed(2)),
          ),
          SizedBox(height: tokens.space.sm),
        ],
        KhNumericField(
          key: const Key('budget-max-field'),
          label: maxLabel,
          unit: unit,
          decimalPlaces: 2,
          initialValue: budgetMax,
          errorText: maxErrorText,
          onChanged: (v) => onMaxChanged?.call(v?.toStringAsFixed(2)),
        ),
        if (onFlexibleChanged != null) ...[
          SizedBox(height: tokens.space.xs),
          SwitchListTile(
            key: const Key('budget-flexible-switch'),
            contentPadding: EdgeInsets.zero,
            title: Text(flexibleLabel),
            value: budgetIsFlexible,
            onChanged: onFlexibleChanged,
          ),
        ],
      ],
    );
  }
}
