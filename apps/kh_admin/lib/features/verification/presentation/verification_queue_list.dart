import 'package:flutter/material.dart';

import '../../../core/design/theme/kh_theme.dart';
import '../../../core/design/widgets/kh_data_table.dart';
import '../../../core/design/widgets/kh_status_chip.dart';
import '../../../l10n/app_localizations.dart';
import '../model/verification_queue_item.dart';

/// Oldest-first queue list for ADM-S07.
class VerificationQueueList extends StatelessWidget {
  const VerificationQueueList({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelect,
  });

  final List<VerificationQueueItem> items;
  final String? selectedId;
  final ValueChanged<VerificationQueueItem> onSelect;

  String _formatWaitingAge(AppLocalizations? l10n, double hours) {
    if (hours < 1) {
      return l10n?.waitingLessThanHour ?? '< 1 hour';
    }
    if (hours < 24) {
      final rounded = hours.round();
      return l10n?.waitingHours(rounded) ?? '$rounded h waiting';
    }
    final days = (hours / 24).floor();
    return l10n?.waitingDays(days) ?? '$days d waiting';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typography = context.kh.typography;
    final colors = context.kh.colors;

    return KhDataTable(
      columns: [
        KhTableColumn(l10n?.verificationColumnBusiness ?? 'Business', flex: 3),
        KhTableColumn(l10n?.verificationColumnLicence ?? 'Licence', flex: 2),
        KhTableColumn(l10n?.verificationColumnWaiting ?? 'Waiting', flex: 2),
        KhTableColumn(l10n?.verificationColumnStatus ?? 'Status', flex: 2),
      ],
      rows: items.map((item) {
        final isSelected = item.id == selectedId;
        return KhTableRow(
          key: Key('verification-queue-row-${item.id}'),
          cells: [
            InkWell(
              onTap: () => onSelect(item),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.legalBusinessName,
                    style: typography.bodySmall.copyWith(
                      color: isSelected ? colors.goldPrimary : colors.cream100,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (item.tradingName != null && item.tradingName!.isNotEmpty)
                    Text(
                      item.tradingName!,
                      style: typography.caption.copyWith(color: colors.textMuted),
                    ),
                ],
              ),
            ),
            InkWell(
              onTap: () => onSelect(item),
              child: Text(
                item.tradeLicenceNumber,
                style: typography.bodySmall.copyWith(color: colors.textSecondary),
              ),
            ),
            InkWell(
              onTap: () => onSelect(item),
              child: Text(
                _formatWaitingAge(l10n, item.oldestWaitingHours),
                style: typography.bodySmall.copyWith(
                  color: item.oldestWaitingHours >= 48
                      ? colors.warning
                      : colors.textSecondary,
                  fontWeight: item.oldestWaitingHours >= 48
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
            InkWell(
              onTap: () => onSelect(item),
              child: KhStatusChip(
                label: l10n?.statusPendingVerification ?? 'PENDING',
                tone: KhStatusTone.pending,
                dense: true,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
