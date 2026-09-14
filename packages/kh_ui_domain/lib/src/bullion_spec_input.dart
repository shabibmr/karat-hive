import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/src/money_display.dart';

/// SH-REQ-07 — Bullion bar weight + quantity + min-value gate (BR-010).
///
/// Computes total weight and indicative valuation; warns / flags when
/// computed indicative value is below the minimum platform threshold (AED 500).
class BullionSpecInput extends StatelessWidget {
  const BullionSpecInput({
    super.key,
    required this.barWeightGrams,
    required this.quantity,
    this.ratePerGramAed,
    this.minThresholdAed = 500.0,
    this.onBarWeightChanged,
    this.onQuantityChanged,
    this.barWeightErrorText,
    this.quantityErrorText,
    this.barWeightLabel = 'Bar weight',
    this.quantityLabel = 'Quantity',
    this.totalWeightLabel = 'Total weight',
    this.indicativeValueLabel = 'Indicative value',
    this.minThresholdErrorMessage,
  });

  final double? barWeightGrams;
  final int? quantity;
  final double? ratePerGramAed;
  final double minThresholdAed;
  final ValueChanged<double?>? onBarWeightChanged;
  final ValueChanged<int?>? onQuantityChanged;
  final String? barWeightErrorText;
  final String? quantityErrorText;
  final String barWeightLabel;
  final String quantityLabel;
  final String totalWeightLabel;
  final String indicativeValueLabel;
  final String? minThresholdErrorMessage;

  double get totalWeightGrams {
    final w = barWeightGrams ?? 0.0;
    final q = quantity ?? 0;
    return w * q;
  }

  double? get indicativeValue {
    if (ratePerGramAed == null || ratePerGramAed! <= 0) return null;
    final total = totalWeightGrams;
    if (total <= 0) return null;
    return total * ratePerGramAed!;
  }

  bool get isBelowMinimum {
    final val = indicativeValue;
    return val != null && val < minThresholdAed;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final hasTotal = totalWeightGrams > 0;
    final val = indicativeValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KhNumericField(
          key: const Key('bullion-bar-weight-field'),
          label: barWeightLabel,
          unit: 'g',
          min: 0.10,
          max: 5000.00,
          decimalPlaces: 2,
          initialValue: barWeightGrams?.toStringAsFixed(2),
          errorText: barWeightErrorText,
          onChanged: onBarWeightChanged,
        ),
        SizedBox(height: tokens.space.sm),
        KhNumericField(
          key: const Key('bullion-quantity-field'),
          label: quantityLabel,
          min: 1,
          decimalPlaces: 0,
          initialValue: quantity?.toString(),
          errorText: quantityErrorText,
          onChanged: (v) => onQuantityChanged?.call(v?.toInt()),
        ),
        if (hasTotal) ...[
          SizedBox(height: tokens.space.sm),
          DecoratedBox(
            decoration: BoxDecoration(
              color: isBelowMinimum
                  ? tokens.danger.withValues(alpha: 0.08)
                  : tokens.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(tokens.radius.sm),
              border: Border.all(
                color: isBelowMinimum
                    ? tokens.danger
                    : tokens.gold.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.space.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.scale_outlined,
                        size: 16,
                        color: isBelowMinimum ? tokens.danger : tokens.gold,
                      ),
                      SizedBox(width: tokens.space.xs),
                      Text(
                        '$totalWeightLabel: ',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: tokens.ink,
                        ),
                      ),
                      Text(
                        WeightFormatter.grams(totalWeightGrams, locale: locale),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: tokens.ink,
                        ),
                      ),
                    ],
                  ),
                  if (val != null) ...[
                    SizedBox(height: tokens.space.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.calculate_outlined,
                          size: 16,
                          color: isBelowMinimum ? tokens.danger : tokens.gold,
                        ),
                        SizedBox(width: tokens.space.xs),
                        Text(
                          '$indicativeValueLabel: ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: tokens.ink,
                          ),
                        ),
                        MoneyDisplay(amount: val, highlight: !isBelowMinimum),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
        if (isBelowMinimum) ...[
          SizedBox(height: tokens.space.xs),
          KhInlineError(
            key: const Key('bullion-minimum-error'),
            message: minThresholdErrorMessage ??
                'Indicative value (${MoneyFormatter.aed(val!, locale: locale)}) is below the minimum threshold of ${MoneyFormatter.aed(minThresholdAed, locale: locale)} (BR-010).',
          ),
        ],
      ],
    );
  }
}
