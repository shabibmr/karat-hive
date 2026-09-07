import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

/// SH-DOM-03 — Money display (AED).
///
/// Formats through [MoneyFormatter] so AED rendering stays in one place.
class MoneyDisplay extends StatelessWidget {
  const MoneyDisplay({
    super.key,
    required this.amount,
    this.locale,
    this.style,
    this.highlight = false,
    this.delta,
  });

  final num amount;

  /// When null, uses [Localizations.localeOf].
  final String? locale;
  final TextStyle? style;
  final bool highlight;
  final num? delta;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final effectiveLocale =
        locale ?? Localizations.localeOf(context).languageCode;
    final formatted = MoneyFormatter.aed(amount, locale: effectiveLocale);
    final baseStyle = style ??
        TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: highlight ? tokens.gold : tokens.ink,
        );

    if (delta == null) {
      return Text(formatted, style: baseStyle);
    }

    final deltaText = MoneyFormatter.aed(delta!.abs(), locale: effectiveLocale);
    final positive = delta! >= 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(formatted, style: baseStyle),
        const SizedBox(width: 6),
        Text(
          '${positive ? '+' : '−'}$deltaText',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: positive ? tokens.success : tokens.danger,
          ),
        ),
      ],
    );
  }
}
