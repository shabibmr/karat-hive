import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/announcements/model/announcement_enums.dart';
import 'package:kh_admin/features/announcements/model/announcement_item.dart';
import 'package:kh_admin/features/announcements/presentation/widgets/announcement_formatters.dart';

/// The announcements data table. Was the inline `KhDataTable` + row builder in
/// `AnnouncementsScreen.build` (TR-S2-08).
class AnnouncementTable extends StatelessWidget {
  const AnnouncementTable({
    super.key,
    required this.items,
    required this.onRowTap,
    required this.onCancel,
  });

  final List<AnnouncementItem> items;
  final ValueChanged<AnnouncementItem> onRowTap;
  final ValueChanged<AnnouncementItem> onCancel;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return KhDataTable(
      rowHeight: 64,
      columns: const [
        KhTableColumn('Title', flex: 3),
        KhTableColumn('Audience', flex: 2),
        KhTableColumn('Channels', flex: 2),
        KhTableColumn('Status', flex: 2),
        KhTableColumn('Dispatch Progress', flex: 2),
        KhTableColumn('Created By', flex: 2),
        KhTableColumn('Date', flex: 2),
        KhTableColumn('Actions', flex: 2),
      ],
      rows: items.map((item) {
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

        final dateStr = announcementFormatDateTime(
            item.scheduledFor ?? item.createdAt, 10);
        String progressStr = '-';
        if (item.dispatchStats != null) {
          progressStr =
              '${item.dispatchStats!.sent} sent (${item.dispatchStats!.delivered} deliv.)';
        } else if (item.status == AnnouncementStatus.scheduled) {
          progressStr = 'Pending dispatch';
        }

        return KhTableRow(
          key: ValueKey(item.id),
          onTap: () => onRowTap(item),
          cells: [
            // Title Cell
            Row(
              children: [
                if (item.critical) ...[
                  Icon(Icons.warning_amber_rounded, size: 16, color: kh.colors.error),
                  SizedBox(width: kh.spacing.xxs),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.titleEn,
                        style: kh.typography.bodySmall
                            .copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.titleAr.isNotEmpty)
                        Text(
                          item.titleAr,
                          style: kh.typography.caption
                              .copyWith(color: kh.colors.textMuted),
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // Audience Cell
            Text(item.audienceType.label, style: kh.typography.bodySmall),
            // Channels Cell
            Text(item.channels.displayString, style: kh.typography.bodySmall),
            // Status Cell
            KhStatusChip(
              label: item.status.label,
              tone: tone,
              dense: true,
            ),
            // Dispatch Progress Cell
            Text(
              progressStr,
              style: kh.typography.bodySmall.copyWith(
                color: item.dispatchStats != null
                    ? kh.colors.success
                    : kh.colors.textMuted,
              ),
            ),
            // Created By Cell
            Text(
              item.createdByDisplayName ?? 'Admin',
              style: kh.typography.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
            // Date Cell
            Text(dateStr, style: kh.typography.bodySmall),
            // Actions Cell
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.info_outline, size: 18),
                  tooltip: 'View details',
                  onPressed: () => onRowTap(item),
                ),
                if (item.canCancel)
                  IconButton(
                    icon: Icon(Icons.cancel_outlined,
                        size: 18, color: kh.colors.error),
                    tooltip: 'Cancel',
                    onPressed: () => onCancel(item),
                  ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }
}
