import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_metric_card.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/announcements/model/announcement_enums.dart';
import 'package:kh_admin/features/announcements/model/announcement_item.dart';
import 'package:kh_admin/features/announcements/presentation/widgets/announcement_formatters.dart';

/// Read-only announcement inspection dialog. Was
/// `_AnnouncementsScreenState._showDetailDialog` (TR-S2-08).
///
/// [onCancel] is invoked (after this dialog closes) when the admin taps
/// "Cancel Announcement"; the screen wires it to the cancel flow.
void showAnnouncementDetailDialog(
  BuildContext context,
  AnnouncementItem item, {
  required VoidCallback onCancel,
}) {
  showDialog<void>(
    context: context,
    builder: (dialogCtx) {
      final kh = dialogCtx.kh;
      KhStatusTone tone = KhStatusTone.neutral;
      switch (item.status) {
        case AnnouncementStatus.scheduled:
          tone = KhStatusTone.pending;
          break;
        case AnnouncementStatus.dispatched:
          tone = KhStatusTone.success;
          break;
        case AnnouncementStatus.cancelled:
          tone = KhStatusTone.error;
          break;
        case AnnouncementStatus.draft:
          tone = KhStatusTone.neutral;
          break;
      }

      return AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Announcement #${announcementShortId(item.id)}',
                style: kh.typography.title,
              ),
            ),
            KhStatusChip(label: item.status.label, tone: tone, dense: true),
          ],
        ),
        content: SizedBox(
          width: 580,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badges row
                Wrap(
                  spacing: kh.spacing.sm,
                  runSpacing: kh.spacing.xs,
                  children: [
                    Chip(
                      label: Text('Audience: ${item.audienceType.label}'),
                      backgroundColor: kh.colors.backgroundElevated,
                      side: BorderSide(color: kh.colors.borderSubtle),
                    ),
                    Chip(
                      label: Text('Channels: ${item.channels.displayString}'),
                      backgroundColor: kh.colors.backgroundElevated,
                      side: BorderSide(color: kh.colors.borderSubtle),
                    ),
                    if (item.critical)
                      Chip(
                        avatar: Icon(Icons.warning_amber_rounded,
                            size: 16, color: kh.colors.error),
                        label: Text(
                          'CRITICAL',
                          style: TextStyle(
                            color: kh.colors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: kh.colors.error.withValues(alpha: 0.12),
                        side: BorderSide(color: kh.colors.error.withValues(alpha: 0.3)),
                      ),
                  ],
                ),
                SizedBox(height: kh.spacing.md),
                // English Content
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(kh.spacing.md),
                  decoration: BoxDecoration(
                    color: kh.colors.backgroundElevated,
                    borderRadius: kh.shapes.roundedSm,
                    border: Border.all(color: kh.colors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ENGLISH CONTENT',
                          style: kh.typography.caption.copyWith(
                            color: kh.colors.goldPrimary,
                            fontWeight: FontWeight.bold,
                          )),
                      SizedBox(height: kh.spacing.xs),
                      Text(item.titleEn,
                          style: kh.typography.body.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(height: kh.spacing.xs),
                      Text(item.bodyEn, style: kh.typography.bodySmall),
                    ],
                  ),
                ),
                SizedBox(height: kh.spacing.md),
                // Arabic Content
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(kh.spacing.md),
                  decoration: BoxDecoration(
                    color: kh.colors.backgroundElevated,
                    borderRadius: kh.shapes.roundedSm,
                    border: Border.all(color: kh.colors.borderSubtle),
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المحتوى باللغة العربية',
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.goldPrimary,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(height: kh.spacing.xs),
                        Text(item.titleAr,
                            style: kh.typography.body.copyWith(fontWeight: FontWeight.bold)),
                        SizedBox(height: kh.spacing.xs),
                        Text(item.bodyAr, style: kh.typography.bodySmall),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: kh.spacing.md),
                // Delivery & Schedule Metadata
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(kh.spacing.md),
                  decoration: BoxDecoration(
                    color: kh.colors.backgroundElevated,
                    borderRadius: kh.shapes.roundedSm,
                    border: Border.all(color: kh.colors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DISPATCH & SCHEDULE DETAILS',
                          style: kh.typography.caption.copyWith(
                            color: kh.colors.goldPrimary,
                            fontWeight: FontWeight.bold,
                          )),
                      SizedBox(height: kh.spacing.xs),
                      Text('Created By: ${item.createdByDisplayName ?? "Admin"}',
                          style: kh.typography.bodySmall),
                      Text('Created At: ${announcementFormatDateTime(item.createdAt)}',
                          style: kh.typography.bodySmall),
                      if (item.scheduledFor != null)
                        Text('Scheduled For: ${announcementFormatDateTime(item.scheduledFor)}',
                            style: kh.typography.bodySmall),
                      if (item.cancelledAt != null)
                        Text('Cancelled At: ${announcementFormatDateTime(item.cancelledAt)}',
                            style: kh.typography.bodySmall.copyWith(color: kh.colors.error)),
                      SizedBox(height: kh.spacing.sm),
                      // Delivery Stats
                      if (item.dispatchStats != null) ...[
                        Row(
                          children: [
                            Expanded(
                              child: KhMetricCard(
                                label: 'Sent',
                                value: '${item.dispatchStats!.sent}',
                                linkText: 'Dispatched',
                                valueColor: kh.colors.info,
                              ),
                            ),
                            SizedBox(width: kh.spacing.md),
                            Expanded(
                              child: KhMetricCard(
                                label: 'Delivered',
                                value: '${item.dispatchStats!.delivered}',
                                linkText: 'Confirmed',
                                valueColor: kh.colors.success,
                              ),
                            ),
                            SizedBox(width: kh.spacing.md),
                            Expanded(
                              child: KhMetricCard(
                                label: 'Opened',
                                value: '${item.dispatchStats!.opened}',
                                linkText: 'Read',
                                valueColor: kh.colors.goldPrimary,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          padding: EdgeInsets.all(kh.spacing.sm),
                          decoration: BoxDecoration(
                            color: kh.colors.gold400.withValues(alpha: 0.08),
                            borderRadius: kh.shapes.roundedSm,
                            border: Border.all(color: kh.colors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: kh.colors.goldPrimary),
                              SizedBox(width: kh.spacing.xs),
                              Expanded(
                                child: Text(
                                  'SAM-GAP-10: Recipient counts are evaluated dynamically at scheduled dispatch.',
                                  style: kh.typography.caption.copyWith(color: kh.colors.goldPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (item.canCancel)
            TextButton(
              style: TextButton.styleFrom(foregroundColor: kh.colors.error),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                onCancel();
              },
              child: const Text('Cancel Announcement'),
            ),
          FilledButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
