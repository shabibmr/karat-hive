import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_metric_card.dart';
import 'package:kh_admin/features/announcements/model/announcement_enums.dart';

/// The four summary metric cards above the announcements list. Was the inline
/// `Row` of `KhMetricCard`s in `AnnouncementsScreen.build` (TR-S2-08).
class AnnouncementMetricsRow extends StatelessWidget {
  const AnnouncementMetricsRow({
    super.key,
    required this.isLoading,
    required this.totalCount,
    required this.scheduledCount,
    required this.dispatchedCount,
    required this.cancelledCount,
    required this.onFilter,
  });

  final bool isLoading;
  final int totalCount;
  final int scheduledCount;
  final int dispatchedCount;
  final int cancelledCount;
  final ValueChanged<AnnouncementStatus?> onFilter;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Row(
      children: [
        Expanded(
          child: KhMetricCard(
            label: 'Total Announcements',
            value: isLoading ? '-' : '$totalCount',
            linkText: 'View All',
            onTap: () => onFilter(null),
          ),
        ),
        SizedBox(width: kh.spacing.md),
        Expanded(
          child: KhMetricCard(
            label: 'Scheduled',
            value: isLoading ? '-' : '$scheduledCount',
            linkText: 'Filter',
            onTap: () => onFilter(AnnouncementStatus.scheduled),
          ),
        ),
        SizedBox(width: kh.spacing.md),
        Expanded(
          child: KhMetricCard(
            label: 'Dispatched',
            value: isLoading ? '-' : '$dispatchedCount',
            linkText: 'Filter',
            onTap: () => onFilter(AnnouncementStatus.dispatched),
          ),
        ),
        SizedBox(width: kh.spacing.md),
        Expanded(
          child: KhMetricCard(
            label: 'Cancelled',
            value: isLoading ? '-' : '$cancelledCount',
            linkText: 'Filter',
            onTap: () => onFilter(AnnouncementStatus.cancelled),
          ),
        ),
      ],
    );
  }
}
