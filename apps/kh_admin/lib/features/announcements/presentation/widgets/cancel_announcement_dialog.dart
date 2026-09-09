import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/announcements/model/announcement_item.dart';
import 'package:kh_admin/features/announcements/presentation/widgets/announcement_formatters.dart';

/// Confirmation dialog for cancelling a scheduled announcement. Was
/// `_AnnouncementsScreenState._showCancelDialog` (TR-S2-08).
///
/// Returns `true` when the admin confirms cancellation. The controller call
/// and success snackbar stay with the screen.
Future<bool> showCancelAnnouncementDialog(
  BuildContext context,
  AnnouncementItem item,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) {
      final kh = dialogCtx.kh;
      return AlertDialog(
        title: Text('Cancel Announcement #${announcementShortId(item.id)}'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel "${item.titleEn}"? This announcement will not be dispatched.',
                style: kh.typography.bodySmall.copyWith(color: kh.colors.textMuted),
              ),
              SizedBox(height: kh.spacing.sm),
              Text(
                'Note: Announcements cannot be cancelled once dispatch has begun.',
                style: kh.typography.caption.copyWith(color: kh.colors.warning),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Back'),
          ),
          FilledButton(
            key: const Key('announcement-confirm-cancel-button'),
            style: FilledButton.styleFrom(backgroundColor: kh.colors.error),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Cancel Announcement'),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
