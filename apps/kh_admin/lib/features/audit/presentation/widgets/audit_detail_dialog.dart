import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/audit/model/audit_log_item.dart';

/// Audit entry detail modal. Was `_AuditScreenState._showDetailModal` /
/// `_buildMetadataGrid` / `_buildDiffSection` (TR-S2-13).
void showAuditDetailDialog(BuildContext context, AuditLogItem item) {
  final kh = context.kh;
  final colors = kh.colors;
  final spacing = kh.spacing;

  showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: colors.backgroundElevated,
        shape: RoundedRectangleBorder(borderRadius: kh.shapes.roundedLg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 720),
          child: Padding(
            padding: EdgeInsets.all(spacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AUDIT ENTRY DETAIL',
                            style: kh.typography.caption.copyWith(
                              color: colors.goldPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: spacing.xxs),
                          Text(
                            item.action,
                            style: kh.typography.headline,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                SizedBox(height: spacing.md),
                Divider(color: colors.borderSubtle),
                SizedBox(height: spacing.md),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMetadataGrid(context, item),
                        SizedBox(height: spacing.lg),
                        Text(
                          'State Change Diff (SAM-GAP-12)',
                          style: kh.typography.title,
                        ),
                        SizedBox(height: spacing.xs),
                        Text(
                          'Before and after state values captured at execution.',
                          style: kh.typography.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        SizedBox(height: spacing.sm),
                        _buildDiffSection(
                          context,
                          item.beforeValue,
                          item.afterValue,
                          _prettyJson,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: spacing.md),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

String _prettyJson(dynamic val) {
  if (val == null) return 'null';
  try {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(val);
  } on Object catch (_) {
    return val.toString();
  }
}

Widget _buildMetadataGrid(BuildContext context, AuditLogItem item) {
  final kh = context.kh;
  final colors = kh.colors;

  Widget metadataTile(String label, String value, {bool copyable = false}) {
    return Container(
      padding: EdgeInsets.all(kh.spacing.sm),
      decoration: BoxDecoration(
        color: colors.backgroundSurface,
        borderRadius: kh.shapes.roundedSm,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: kh.typography.caption.copyWith(
              color: colors.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
          SizedBox(height: kh.spacing.xxs),
          SelectableText(
            value,
            style: kh.typography.bodySmall.copyWith(
              color: colors.textPrimary,
              fontFamily: copyable ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }

  return LayoutBuilder(
    builder: (context, constraints) {
      final isWide = constraints.maxWidth > 500;
      final colCount = isWide ? 2 : 1;

      return GridView.count(
        crossAxisCount: colCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: kh.spacing.sm,
        crossAxisSpacing: kh.spacing.sm,
        childAspectRatio: isWide ? 3.8 : 4.5,
        children: [
          metadataTile('Record ID', item.id, copyable: true),
          metadataTile('Occurred At (GST UTC+4)', item.formattedGst),
          metadataTile('Occurred At (UTC)', item.occurredAt.toUtc().toIso8601String()),
          metadataTile(
            'Actor User ID',
            item.actorUserId ?? 'System / Anonymous',
            copyable: true,
          ),
          metadataTile('Target Entity Type', item.entityType),
          metadataTile('Target Entity ID', item.entityId ?? 'None', copyable: true),
          metadataTile('Client IP Address', item.ip ?? '—'),
          metadataTile('Client User Agent', item.userAgent ?? '—'),
        ],
      );
    },
  );
}

Widget _buildDiffSection(
  BuildContext context,
  dynamic before,
  dynamic after,
  String Function(dynamic) prettyJson,
) {
  final kh = context.kh;
  final colors = kh.colors;

  if (before == null && after == null) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundSurface,
        borderRadius: kh.shapes.roundedSm,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Text(
        'No state payload diff recorded for this entry.',
        style: kh.typography.bodySmall.copyWith(color: colors.textMuted),
      ),
    );
  }

  Widget payloadBox(String title, dynamic val, Color accentColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(kh.spacing.sm),
        decoration: BoxDecoration(
          color: colors.backgroundSurface,
          borderRadius: kh.shapes.roundedSm,
          border: Border.all(color: accentColor.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: kh.spacing.xs),
                Text(
                  title,
                  style: kh.typography.caption.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: kh.spacing.xs),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(kh.spacing.xs),
              decoration: BoxDecoration(
                color: colors.backgroundElevated,
                borderRadius: kh.shapes.roundedSm,
              ),
              child: SelectableText(
                val == null ? 'None' : prettyJson(val),
                style: kh.typography.bodySmall.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      payloadBox('BEFORE VALUE', before, colors.error),
      SizedBox(width: kh.spacing.md),
      payloadBox('AFTER VALUE', after, colors.success),
    ],
  );
}
