import 'package:flutter/material.dart';

import '../tokens.dart';

/// SH-FND-23 — tappable external link row (ToS, Privacy, support).
///
/// Opening the URL is the caller's job (e.g. `openUrl`); this widget only
/// surfaces the row chrome and invokes [onTap].
class KhExternalLinkRow extends StatelessWidget {
  const KhExternalLinkRow({
    super.key,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: label,
          child: InkWell(
            key: const Key('kh-external-link-row'),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.space.sm + 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: tokens.ink,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: tokens.space.sm),
                  Icon(
                    rtl ? Icons.chevron_left : Icons.chevron_right,
                    size: 22,
                    color: tokens.ink.withValues(alpha: 0.45),
                  ),
                ],
              ),
            ),
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
