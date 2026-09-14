import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

import 'money_display.dart';

/// SH-DOM-01 — reference gold rate strip.
///
/// Handles `available:false` (inline message, no invented rate) and `stale`
/// styling. Labels are parameters so callers supply l10n.
class GoldRateStrip extends StatelessWidget {
  const GoldRateStrip({
    super.key,
    required this.rates,
    this.karat,
    this.title = 'Reference gold rate',
    this.perGramLabel = '/g',
    this.staleLabel = 'Stale',
    this.unavailableMessage =
        'Reference gold rates are unavailable. You can still compose this Request.',
  });

  final GoldRateSnapshot? rates;
  final Karat? karat;
  final String title;
  final String perGramLabel;
  final String staleLabel;
  final String unavailableMessage;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final snap = rates;
    if (snap == null) return const SizedBox.shrink();
    if (!snap.available) {
      return Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: KhInlineError(message: unavailableMessage),
      );
    }

    GoldRateRow? row;
    if (karat != null) {
      for (final r in snap.rates) {
        if (r.karat == karat) {
          row = r;
          break;
        }
      }
    }
    row ??= snap.rates.isEmpty ? null : snap.rates.first;
    final amount = double.tryParse(row?.ratePerGramAed ?? '') ?? 0;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: tokens.space.md,
        vertical: tokens.space.sm,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: snap.stale
                ? tokens.warning
                : tokens.gold.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(tokens.radius.sm),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.sm),
          child: Row(
            children: [
              Expanded(child: Text(title)),
              MoneyDisplay(amount: amount),
              Text(perGramLabel),
              if (snap.stale) ...[
                SizedBox(width: tokens.space.sm),
                KhStatusChip(
                  label: staleLabel,
                  tone: KhStatusTone.warning,
                  compact: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
