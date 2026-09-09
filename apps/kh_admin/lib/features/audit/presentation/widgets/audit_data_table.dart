import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/audit/model/audit_log_item.dart';
import 'package:kh_admin/features/audit/presentation/widgets/audit_action_tone.dart';

/// The audit-log data table. Was `_AuditScreenState._buildDataTable`
/// (TR-S2-13).
class AuditDataTable extends StatelessWidget {
  const AuditDataTable({
    super.key,
    required this.items,
    required this.onInspect,
  });

  final List<AuditLogItem> items;
  final ValueChanged<AuditLogItem> onInspect;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final colors = kh.colors;

    return KhDataTable(
      key: const Key('audit-data-table'),
      minWidth: 840,
      columns: const [
        KhTableColumn('Occurred At (GST)', flex: 3),
        KhTableColumn('Action', flex: 3),
        KhTableColumn('Actor (User ID)', flex: 2),
        KhTableColumn('Target Entity', flex: 3),
        KhTableColumn('Metadata', flex: 2),
        KhTableColumn('Details', flex: 1),
      ],
      rows: [
        for (final item in items)
          KhTableRow(
            key: Key('audit-row-${item.id}'),
            onTap: () => onInspect(item),
            cells: [
              Text(
                item.formattedGst,
                style: kh.typography.bodySmall.copyWith(
                  color: colors.textPrimary,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              KhStatusChip(
                label: item.action,
                tone: auditToneForAction(item.action),
                dense: true,
              ),
              Text(
                item.actorUserId != null && item.actorUserId!.length > 12
                    ? '${item.actorUserId!.substring(0, 8)}…'
                    : (item.actorUserId ?? 'System'),
                style: kh.typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: kh.typography.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                  children: [
                    TextSpan(
                      text: item.entityType,
                      style: kh.typography.bodySmall.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.entityId != null)
                      TextSpan(
                        text: ' · ${item.entityId!.length > 8 ? "${item.entityId!.substring(0, 8)}…" : item.entityId}',
                        style: kh.typography.bodySmall.copyWith(
                          color: colors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                item.ip ?? '—',
                style: kh.typography.bodySmall.copyWith(
                  color: colors.textMuted,
                  fontSize: 11,
                ),
              ),
              OutlinedButton(
                onPressed: () => onInspect(item),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: kh.spacing.xs,
                    vertical: kh.spacing.xxs,
                  ),
                  minimumSize: Size(0, kh.spacing.buttonHeight - 10),
                ),
                child: Text(
                  'Inspect',
                  style: kh.typography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
