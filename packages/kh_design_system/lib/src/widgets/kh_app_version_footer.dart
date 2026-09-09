import 'package:flutter/material.dart';

import '../tokens.dart';

/// SH-FND-24 — display-only app version footer for Settings.
class KhAppVersionFooter extends StatelessWidget {
  const KhAppVersionFooter({
    super.key,
    required this.version,
    this.label = 'App version',
    this.showDivider = false,
  });

  final String version;
  final String label;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final muted = tokens.ink.withValues(alpha: 0.55);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          key: const Key('kh-app-version-footer'),
          padding: EdgeInsets.symmetric(vertical: tokens.space.sm + 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
              SizedBox(width: tokens.space.sm),
              Text(
                version,
                key: const Key('kh-app-version-value'),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: tokens.ink.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: tokens.ink.withValues(alpha: 0.08),
          ),
      ],
    );
  }
}
