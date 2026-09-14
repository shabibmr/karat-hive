import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

/// SH-REQ-03 — Request direction control.
///
/// Supports fixed (read-only display) vs selectable BUY/SELL.
class RequestDirectionControl extends StatelessWidget {
  const RequestDirectionControl({
    super.key,
    required this.value,
    this.fixed = false,
    this.onChanged,
    this.label = 'Direction',
    this.buyLabel = 'BUY',
    this.sellLabel = 'SELL',
  });

  final Direction? value;
  final bool fixed;
  final ValueChanged<Direction>? onChanged;
  final String label;
  final String buyLabel;
  final String sellLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    if (fixed) {
      final text = value == Direction.sell ? sellLabel : buyLabel;
      return Padding(
        padding: EdgeInsets.only(bottom: tokens.space.sm),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radius.sm),
            ),
          ),
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: tokens.ink,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: tokens.ink,
          ),
        ),
        SizedBox(height: tokens.space.xs),
        RadioListTile<Direction>(
          key: const Key('direction-buy'),
          contentPadding: EdgeInsets.zero,
          title: Text(buyLabel),
          value: Direction.buy,
          groupValue: value,
          onChanged: (v) {
            if (v != null) onChanged?.call(v);
          },
        ),
        RadioListTile<Direction>(
          key: const Key('direction-sell'),
          contentPadding: EdgeInsets.zero,
          title: Text(sellLabel),
          value: Direction.sell,
          groupValue: value,
          onChanged: (v) {
            if (v != null) onChanged?.call(v);
          },
        ),
      ],
    );
  }
}
