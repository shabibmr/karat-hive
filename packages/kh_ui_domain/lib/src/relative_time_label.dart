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
    this.format,
  });

  final DateTime at;
  final DateTime? now;
  final TextStyle? style;

  /// Optional override; when null, uses [RelativeTimeFormatter] with
  /// [AppLocalizations] labels (English defaults if l10n is absent).
  final String Function(Duration elapsed)? format;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final locale = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context);
    final past = at.toUtc();
    final anchor = (now ?? DateTime.now()).toUtc();
    final elapsed = anchor.difference(past);

    final text = format != null
        ? format!(elapsed)
        : RelativeTimeFormatter.since(
            past,
            now: anchor,
            locale: locale,
            labels: l10n != null
                ? RelativeTimeLabels.fromAppLocalizations(l10n)
                : null,
          );

    return Text(
      text,
      style: style ??
          TextStyle(
            fontSize: 12,
            color: tokens.ink.withValues(alpha: 0.6),
          ),
    );
  }
}
