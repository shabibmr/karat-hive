import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

/// SH-REQ-06 — Coin denomination + quantity with computed total weight.
class CoinSpecInput extends StatelessWidget {
  const CoinSpecInput({
    super.key,
    required this.denominationGrams,
    required this.quantity,
    this.onDenominationChanged,
    this.onQuantityChanged,
    this.denominationOptions = const [1.0, 2.5, 5.0, 10.0, 20.0, 50.0, 100.0],
    this.denominationErrorText,
    this.quantityErrorText,
    this.denominationLabel = 'Coin denomination',
    this.quantityLabel = 'Quantity',
    this.totalWeightLabel = 'Total weight',
  });

  final double? denominationGrams;
  final int? quantity;
  final ValueChanged<double?>? onDenominationChanged;
  final ValueChanged<int?>? onQuantityChanged;
  final List<double> denominationOptions;
  final String? denominationErrorText;
  final String? quantityErrorText;
  final String denominationLabel;
  final String quantityLabel;
  final String totalWeightLabel;

  double get totalWeightGrams {
    final d = denominationGrams ?? 0.0;
    final q = quantity ?? 0;
    return d * q;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final hasTotal = totalWeightGrams > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KhSelectField<double>(
          key: const Key('coin-denomination-picker'),
          label: denominationLabel,
          value: denominationGrams,
          errorText: denominationErrorText,
          searchable: false,
          options: [
            for (final d in denominationOptions)
              KhSelectOption(
                value: d,
                label: WeightFormatter.grams(d, locale: locale),
              ),
          ],
          onChanged: (v) {
            onDenominationChanged?.call(v);
          },
        ),
        SizedBox(height: tokens.space.sm),
        KhNumericField(
          key: const Key('coin-quantity-field'),
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
              color: tokens.gold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(tokens.radius.sm),
              border: Border.all(
                color: tokens.gold.withValues(alpha: 0.3),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.space.sm),
              child: Row(
                children: [
                  Icon(Icons.scale_outlined, size: 16, color: tokens.gold),
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
            ),
          ),
        ],
      ],
    );
  }
}
