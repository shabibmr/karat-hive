import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/settings/model/platform_setting_item.dart';

/// The platform-settings data table. Was
/// `_PlatformSettingsScreenState._buildSettingsTable` / `_formatDate`
/// (TR-S2-11).
class PlatformSettingsTable extends StatelessWidget {
  const PlatformSettingsTable({
    super.key,
    required this.items,
    required this.onEdit,
  });

  final List<PlatformSettingItem> items;
  final ValueChanged<PlatformSettingItem> onEdit;

  static String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    final columns = const [
      KhTableColumn('Setting Key & Description', flex: 4),
      KhTableColumn('Current Value', flex: 3),
      KhTableColumn('Type & Allowed Range', flex: 3),
      KhTableColumn('Security & Governance', flex: 2),
      KhTableColumn('Action', flex: 1),
    ];

    final rows = items.map((item) {
      return KhTableRow(
        key: Key('setting-row-${item.key}'),
        onTap: () => onEdit(item),
        cells: [
          // Cell 1: Key & Description & Badges
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      item.key,
                      style: kh.typography.body.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        color: kh.colors.goldPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.isOfferValidityPendingDecision) ...[
                    SizedBox(width: kh.spacing.xs),
                    const KhStatusChip(
                      label: 'Decision Pending',
                      tone: KhStatusTone.pending,
                      dense: true,
                    ),
                  ],
                ],
              ),
              if (item.description != null) ...[
                SizedBox(height: kh.spacing.xxs),
                Text(
                  item.description!,
                  style: kh.typography.caption.copyWith(
                    color: kh.colors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),

          // Cell 2: Current Value
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: kh.spacing.sm,
              vertical: kh.spacing.xs,
            ),
            decoration: BoxDecoration(
              color: kh.colors.backgroundSurface,
              borderRadius: kh.shapes.roundedSm,
              border: Border.all(color: kh.colors.borderSubtle),
            ),
            child: Text(
              item.formattedValue,
              style: kh.typography.bodySmall.copyWith(
                fontFamily: item.dataType == 'json' ||
                        item.dataType == 'number[]' ||
                        item.dataType == 'string[]'
                    ? 'monospace'
                    : null,
                color: kh.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Cell 3: Type & Allowed Range
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KhStatusChip(
                label: item.dataType.toUpperCase(),
                tone: KhStatusTone.neutral,
                dense: true,
              ),
              SizedBox(height: kh.spacing.xxs),
              Text(
                item.allowedRange?.summary ?? 'No range restrictions',
                style: kh.typography.caption.copyWith(
                  color: kh.colors.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          // Cell 4: Security & Governance
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              KhStatusChip(
                label: item.requiresSuperAdmin
                    ? 'Super-Admin Confirm'
                    : 'Standard Admin',
                tone: item.requiresSuperAdmin
                    ? KhStatusTone.error
                    : KhStatusTone.success,
                dense: true,
              ),
              if (item.updatedAt != null) ...[
                SizedBox(height: kh.spacing.xxs),
                Text(
                  'Updated ${_formatDate(item.updatedAt!)}',
                  style: kh.typography.caption.copyWith(
                    color: kh.colors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),

          // Cell 5: Action
          OutlinedButton(
            key: Key('edit-setting-${item.key}'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: kh.spacing.sm,
                vertical: kh.spacing.xs,
              ),
              minimumSize: const Size(60, 32),
            ),
            onPressed: () => onEdit(item),
            child: const Text('Edit'),
          ),
        ],
      );
    }).toList(growable: false);

    return KhDataTable(
      columns: columns,
      rows: rows,
      minWidth: 900,
    );
  }
}
