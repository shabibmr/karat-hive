import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

import 'money_display.dart';

/// SH-DOM-02 — indicative valuation (weight × rate → AED).
///
/// Suppressed when [rates] is null, unavailable, or no matching karat row.
/// Never invents a rate from a stale timestamp alone (`FR-CUS-018`).
class IndicativeValuation extends StatelessWidget {
  const IndicativeValuation({
    super.key,
    required this.weightGrams,
    required this.karat,
    required this.rates,
    this.title = 'Indicative value',
    this.disclaimer = 'Estimate only — not an Offer',
  });

  final double weightGrams;
  final Karat karat;
  final GoldRateSnapshot? rates;
  final String title;
  final String disclaimer;

  double? get _value {
    final snap = rates;
    if (snap == null || !snap.available || weightGrams <= 0) return null;
    GoldRateRow? row;
    for (final r in snap.rates) {
      if (r.karat == karat) {
        row = r;
        break;
      }
    }
    row ??= snap.rates.isEmpty ? null : snap.rates.first;
    final rate = double.tryParse(row?.ratePerGramAed ?? '');
    if (rate == null) return null;
    return weightGrams * rate;
  }

  @override
  Widget build(BuildContext context) {
    final value = _value;
    if (value == null) return const SizedBox.shrink();

    final tokens = context.tokens;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: tokens.space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          SizedBox(height: tokens.space.xs),
          MoneyDisplay(amount: value, highlight: true),
          SizedBox(height: tokens.space.xs),
          Text(
            disclaimer,
            style: theme.textTheme.bodySmall?.copyWith(
              color: tokens.ink.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
