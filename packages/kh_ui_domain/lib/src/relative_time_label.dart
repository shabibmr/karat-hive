import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

/// SH-DOM-08 — Relative time label (“2h ago”).
class RelativeTimeLabel extends StatelessWidget {
  const RelativeTimeLabel({
    super.key,
    required this.at,
    this.now,
    this.style,
  });

  final DateTime at;
  final DateTime? now;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Text(
      RelativeTimeFormatter.since(at.toUtc(), now: now?.toUtc()),
      style: style ??
          TextStyle(
            fontSize: 12,
            color: tokens.ink.withValues(alpha: 0.6),
          ),
    );
  }
}
