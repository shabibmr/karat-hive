import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/audit/controller/audit_controller.dart';

/// Common administrative action types recorded in audit logs.
const List<String> kCommonAuditActions = [
  'ALL',
  'CUSTOMER_SUSPENDED',
  'CUSTOMER_REACTIVATED',
  'CUSTOMER_ERASURE_COMPLETED',
  'VENDOR_VERIFIED',
  'VENDOR_REJECTED',
  'VENDOR_INFO_REQUESTED',
  'VENDOR_STATE_CHANGED',
  'REQUEST_REMOVED',
  'OFFER_ACCEPTED',
  'CONNECTION_CLOSED',
  'REVIEW_APPROVED',
  'REVIEW_REJECTED',
  'REVIEW_REDACTED',
  'ABUSE_REPORT_RESOLVED',
  'ABUSE_REPORT_DISMISSED',
  'SETTINGS_UPDATED',
  'ADMIN_CREATED',
  'ADMIN_SUSPENDED',
  'ADMIN_REVOKED',
  'ANNOUNCEMENT_CREATED',
  'ANNOUNCEMENT_CANCELLED',
  'EXPORT_JOB_CREATED',
  'AUDIT_VIEWED',
];

/// Common target entity types.
const List<String> kCommonEntityTypes = [
  'ALL',
  'customer_profile',
  'vendor_profile',
  'request',
  'offer',
  'connection',
  'review',
  'abuse_report',
  'platform_settings',
  'announcement',
  'export_job',
  'admin_user',
];

/// Filters toolbar for the audit log. Was
/// `_AuditScreenState._buildFiltersToolbar` (TR-S2-13). Date-range picking
/// stays in the screen.
class AuditFiltersToolbar extends StatelessWidget {
  const AuditFiltersToolbar({
    super.key,
    required this.state,
    required this.controller,
    required this.actorSearchController,
    required this.ipSearchController,
    required this.onPickDateRange,
    required this.onReset,
  });

  final AuditState state;
  final AuditController controller;
  final TextEditingController actorSearchController;
  final TextEditingController ipSearchController;
  final VoidCallback onPickDateRange;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final colors = kh.colors;
    final filters = state.filters;

    String dateRangeLabel() {
      if (filters.from == null && filters.to == null) {
        return 'All Dates';
      }
      final fromStr = filters.from != null
          ? '${filters.from!.year}-${filters.from!.month.toString().padLeft(2, '0')}-${filters.from!.day.toString().padLeft(2, '0')}'
          : '—';
      final toStr = filters.to != null
          ? '${filters.to!.year}-${filters.to!.month.toString().padLeft(2, '0')}-${filters.to!.day.toString().padLeft(2, '0')}'
          : '—';
      return '$fromStr to $toStr';
    }

    return Container(
      padding: EdgeInsets.all(kh.spacing.md),
      decoration: BoxDecoration(
        color: colors.backgroundElevated,
        borderRadius: kh.shapes.roundedMd,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Wrap(
        spacing: kh.spacing.md,
        runSpacing: kh.spacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Action Filter Dropdown
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              key: const Key('audit-action-filter-dropdown'),
              initialValue: filters.action != null &&
                      kCommonAuditActions.contains(filters.action)
                  ? filters.action
                  : 'ALL',
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Action Type',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: kh.spacing.sm,
                  vertical: kh.spacing.sm,
                ),
                border: OutlineInputBorder(borderRadius: kh.shapes.roundedSm),
              ),
              items: kCommonAuditActions.map((action) {
                return DropdownMenuItem<String>(
                  value: action,
                  child: Text(
                    action,
                    style: kh.typography.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                controller.setActionFilter(val == 'ALL' ? null : val);
              },
            ),
          ),
          // Entity Type Filter Dropdown
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<String>(
              key: const Key('audit-entity-filter-dropdown'),
              initialValue: filters.entityType != null &&
                      kCommonEntityTypes.contains(filters.entityType)
                  ? filters.entityType
                  : 'ALL',
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Target Entity',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: kh.spacing.sm,
                  vertical: kh.spacing.sm,
                ),
                border: OutlineInputBorder(borderRadius: kh.shapes.roundedSm),
              ),
              items: kCommonEntityTypes.map((entity) {
                return DropdownMenuItem<String>(
                  value: entity,
                  child: Text(
                    entity,
                    style: kh.typography.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                controller.setEntityTypeFilter(val == 'ALL' ? null : val);
              },
            ),
          ),
          // Actor Search field
          SizedBox(
            width: 200,
            child: TextField(
              key: const Key('audit-actor-search-input'),
              controller: actorSearchController,
              decoration: InputDecoration(
                labelText: 'Actor User ID',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: kh.spacing.sm,
                  vertical: kh.spacing.sm,
                ),
                border: OutlineInputBorder(borderRadius: kh.shapes.roundedSm),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, size: 18),
                  onPressed: () =>
                      controller.setActorFilter(actorSearchController.text.trim()),
                ),
              ),
              onSubmitted: (val) => controller.setActorFilter(val.trim()),
            ),
          ),
          SizedBox(
            width: 160,
            child: TextField(
              key: const Key('audit-ip-search-input'),
              controller: ipSearchController,
              decoration: InputDecoration(
                labelText: 'Client IP',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: kh.spacing.sm,
                  vertical: kh.spacing.sm,
                ),
                border: OutlineInputBorder(borderRadius: kh.shapes.roundedSm),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, size: 18),
                  onPressed: () =>
                      controller.setIpFilter(ipSearchController.text.trim()),
                ),
              ),
              onSubmitted: (val) => controller.setIpFilter(val.trim()),
            ),
          ),
          // Date Range picker button
          OutlinedButton.icon(
            key: const Key('audit-date-range-button'),
            icon: const Icon(Icons.date_range, size: 18),
            label: Text(dateRangeLabel()),
            onPressed: onPickDateRange,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: kh.spacing.md,
                vertical: kh.spacing.sm,
              ),
            ),
          ),
          // Clear filters button
          if (filters.hasActiveFilters)
            TextButton.icon(
              key: const Key('audit-clear-filters-button'),
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Reset'),
              onPressed: onReset,
            ),
        ],
      ),
    );
  }
}
