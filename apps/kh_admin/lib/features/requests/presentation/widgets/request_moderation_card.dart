import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/features/requests/model/request_detail.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Platform moderation / removal action card. Was `_buildAdminActionsCard`.
class RequestModerationCard extends StatelessWidget {
  const RequestModerationCard({
    super.key,
    required this.detail,
    required this.onRemove,
  });

  final RequestDetail detail;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KhSectionLabel(
              l10n?.requestsDetailModerationTitle ?? 'Platform Moderation'),
          SizedBox(height: kh.spacing.md),
          Text(
            l10n?.requestsDetailModerationBody ??
                'Administrators can forcibly remove requests that violate platform trading policies (FR-ADM-019).',
            style: kh.typography.bodySmall.copyWith(
              color: kh.colors.textSecondary,
              fontSize: 12.0,
            ),
          ),
          SizedBox(height: kh.spacing.md),
          if (detail.isRemoved)
            ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.block, size: 18.0),
              label: Text(
                  l10n?.requestsDetailAlreadyRemoved ?? 'Request Already Removed'),
            )
          else
            ElevatedButton.icon(
              key: const Key('remove-request-button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kh.colors.error,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: kh.spacing.md,
                  vertical: kh.spacing.sm,
                ),
              ),
              icon: const Icon(Icons.delete_forever, size: 18.0),
              label: Text(l10n?.requestsDetailRemoveRequest ?? 'Remove Request'),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}
