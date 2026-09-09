
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/router/admin_user_query_params.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_metric_card.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/admin_users/controller/admin_user_controller.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_enums.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_filters.dart';
import 'package:kh_admin/features/admin_users/model/admin_user_item.dart';
import 'package:kh_admin/core/widgets/debounced_search_mixin.dart';

/// ADM-S23 · Admin User Provisioning & Management.
///
/// Features:
/// - Summary metric cards: Total Admins, Active, Suspended, Revoked
/// - Provision Admin action dialog (email + displayName, strictly no role selector per SAM-GAP-13 & AD-API-03)
/// - Search and lifecycle state filtering
/// - Data table displaying Name, Email, Status, Created Date, and Suspend/Revoke actions
/// - Confirmation dialogs for account suspension and revocation
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> with DebouncedSearchMixin {
  late final TextEditingController _searchController;
  Uri? _lastSyncedUri;

  @override
  void initState() {
    super.initState();
    final query = ref.read(adminUserControllerProvider).filters.query;
    _searchController = TextEditingController(text: query);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFromUri();
  }

  void _syncFromUri() {
    Uri uri;
    try {
      uri = GoRouterState.of(context).uri;
    } on Object catch (_) {
      return;
    }
    if (uri == _lastSyncedUri) return;
    _lastSyncedUri = uri;

    final parsed = AdminUserQueryParams.fromUri(uri).toFilters();
    final current = ref.read(adminUserControllerProvider).filters;
    if (parsed == current) return;
    ref.read(adminUserControllerProvider.notifier).applyFilters(parsed);
    if (_searchController.text != parsed.query) {
      _searchController.text = parsed.query;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Duration get searchDebounceDuration =>
      const Duration(milliseconds: 300);

  void _onSearchChanged(String query) {
    debounceSearch(() {
      ref.read(adminUserControllerProvider.notifier).setSearchQuery(query);
    });
  }

  String _shortId(String id, [int maxLen = 8]) =>
      id.length > maxLen ? id.substring(0, maxLen) : id;

  String _formatDateTime(DateTime dt, [int maxLen = 10]) {
    final str = dt.toLocal().toString();
    return str.length >= maxLen ? str.substring(0, maxLen) : str;
  }

  void _showProvisionDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final messenger = ScaffoldMessenger.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final kh = dialogCtx.kh;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isBusy = ref.watch(adminUserControllerProvider).isActionLoading;

            return AlertDialog(
              backgroundColor: kh.colors.backgroundElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: kh.colors.borderStandard),
              ),
              title: Text('Provision Admin', style: kh.typography.title),
              content: SizedBox(
                width: 480,
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Provision a new system administrator. An email with temporary credentials will be dispatched. System admin roles have fixed coarse administrative access (AD-API-03).',
                        style: kh.typography.bodySmall.copyWith(
                          color: kh.colors.textSecondary,
                        ),
                      ),
                      SizedBox(height: kh.spacing.md),
                      TextFormField(
                        key: const Key('admin-name-field'),
                        controller: nameController,
                        enabled: !isBusy,
                        style: kh.typography.body,
                        decoration: InputDecoration(
                          labelText: 'Display Name *',
                          hintText: 'e.g. Sarah Connor',
                          labelStyle: TextStyle(color: kh.colors.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kh.colors.borderSubtle),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kh.colors.goldPrimary),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Display name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: kh.spacing.md),
                      TextFormField(
                        key: const Key('admin-email-field'),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isBusy,
                        style: kh.typography.body,
                        decoration: InputDecoration(
                          labelText: 'Email Address *',
                          hintText: 'e.g. sarah@karathive.ae',
                          labelStyle: TextStyle(color: kh.colors.textSecondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kh.colors.borderSubtle),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: kh.colors.goldPrimary),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email address is required';
                          }
                          final email = value.trim();
                          if (!email.contains('@') || !email.contains('.')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: kh.spacing.sm),
                      Container(
                        padding: EdgeInsets.all(kh.spacing.sm),
                        decoration: BoxDecoration(
                          color: kh.colors.backgroundSurface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: kh.colors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: kh.colors.goldPrimary),
                            SizedBox(width: kh.spacing.xs),
                            Expanded(
                              child: Text(
                                'Role is fixed: System Administrator (coarse RBAC)',
                                style: kh.typography.caption.copyWith(
                                  color: kh.colors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isBusy ? null : () => Navigator.of(dialogCtx).pop(),
                  child: Text('Cancel', style: TextStyle(color: kh.colors.textSecondary)),
                ),
                FilledButton(
                  key: const Key('confirm-provision-button'),
                  style: FilledButton.styleFrom(
                    backgroundColor: kh.colors.goldPrimary,
                    foregroundColor: kh.colors.backgroundPrimary,
                  ),
                  onPressed: isBusy
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          final email = emailController.text.trim();
                          final name = nameController.text.trim();

                          final success = await ref
                              .read(adminUserControllerProvider.notifier)
                              .provisionAdmin(
                                email: email,
                                displayName: name,
                              );

                          if (!dialogCtx.mounted) return;
                          Navigator.of(dialogCtx).pop();

                          if (!mounted) return;
                          if (success) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Admin user $name provisioned successfully.'),
                                backgroundColor: kh.colors.success,
                              ),
                            );
                          } else {
                            final error = ref.read(adminUserControllerProvider).errorMessage;
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(error ?? 'Failed to provision admin.'),
                                backgroundColor: kh.colors.error,
                              ),
                            );
                          }
                        },
                  child: isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Provision Admin'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSuspendDialog(AdminUserItem item) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final kh = dialogCtx.kh;
        return AlertDialog(
          backgroundColor: kh.colors.backgroundElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: kh.colors.borderStandard),
          ),
          title: Text('Suspend Admin', style: kh.typography.title),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to suspend ${item.displayName} (${item.email})?',
                  style: kh.typography.body.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: kh.spacing.sm),
                Text(
                  'The administrator will immediately lose access to the Karat Hive admin console until their account is reactivated.',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text('Cancel', style: TextStyle(color: kh.colors.textSecondary)),
            ),
            FilledButton(
              key: const Key('confirm-suspend-button'),
              style: FilledButton.styleFrom(
                backgroundColor: kh.colors.warning,
                foregroundColor: kh.colors.backgroundPrimary,
              ),
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                final success = await ref
                    .read(adminUserControllerProvider.notifier)
                    .suspendAdmin(item.id);

                if (!mounted) return;
                if (success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Admin account for ${item.displayName} suspended.'),
                      backgroundColor: kh.colors.warning,
                    ),
                  );
                } else {
                  final err = ref.read(adminUserControllerProvider).errorMessage;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(err ?? 'Failed to suspend admin.'),
                      backgroundColor: kh.colors.error,
                    ),
                  );
                }
              },
              child: const Text('Suspend'),
            ),
          ],
        );
      },
    );
  }

  void _showRevokeDialog(AdminUserItem item) {
    final messenger = ScaffoldMessenger.of(context);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final kh = dialogCtx.kh;
        return AlertDialog(
          backgroundColor: kh.colors.backgroundElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: kh.colors.borderStandard),
          ),
          title: Text('Revoke Admin', style: kh.typography.title),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to revoke access for ${item.displayName} (${item.email})?',
                  style: kh.typography.body.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: kh.spacing.sm),
                Text(
                  'This action permanently deactivates the administrator account. The system requires at least one active administrator to remain at all times.',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text('Cancel', style: TextStyle(color: kh.colors.textSecondary)),
            ),
            FilledButton(
              key: const Key('confirm-revoke-button'),
              style: FilledButton.styleFrom(
                backgroundColor: kh.colors.error,
                foregroundColor: kh.colors.cream100,
              ),
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                final success = await ref
                    .read(adminUserControllerProvider.notifier)
                    .revokeAdmin(item.id);

                if (!mounted) return;
                if (success) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Admin access revoked for ${item.displayName}.'),
                      backgroundColor: kh.colors.success,
                    ),
                  );
                } else {
                  final err = ref.read(adminUserControllerProvider).errorMessage;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(err ?? 'Failed to revoke admin.'),
                      backgroundColor: kh.colors.error,
                    ),
                  );
                }
              },
              child: const Text('Revoke'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AdminUserFilters>(
      adminUserControllerProvider.select((s) => s.filters),
      (prev, next) {
        if (prev != next) {
          context.updateAdminUserQuery(next);
        }
      },
    );

    final kh = context.kh;
    final filters =
        ref.watch(adminUserControllerProvider.select((s) => s.filters));
    final isLoading =
        ref.watch(adminUserControllerProvider.select((s) => s.isLoading));
    final errorMessage =
        ref.watch(adminUserControllerProvider.select((s) => s.errorMessage));
    final totalCount =
        ref.watch(adminUserControllerProvider.select((s) => s.totalCount));
    final activeCount =
        ref.watch(adminUserControllerProvider.select((s) => s.activeCount));
    final suspendedCount =
        ref.watch(adminUserControllerProvider.select((s) => s.suspendedCount));
    final revokedCount =
        ref.watch(adminUserControllerProvider.select((s) => s.revokedCount));
    final filteredAdmins =
        ref.watch(adminUserControllerProvider.select((s) => s.filteredAdmins));
    final controller = ref.read(adminUserControllerProvider.notifier);

    // Sync search input if cleared externally
    if (_searchController.text != filters.query &&
        !_searchController.selection.isValid) {
      _searchController.text = filters.query;
    }

    return Material(
      color: kh.colors.backgroundSurface,
      child: Padding(
        padding: EdgeInsets.all(kh.spacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KhScreenHeader(
              eyebrow: 'Platform Administration',
              heading: 'Admin Users',
              supportingText:
                  'Provision and manage system administrator accounts. Enforces coarse RBAC without role customization; at least one active admin must always be maintained.',
              trailing: FilledButton.icon(
                key: const Key('provision-admin-button'),
                style: FilledButton.styleFrom(
                  backgroundColor: kh.colors.goldPrimary,
                  foregroundColor: kh.colors.backgroundPrimary,
                  padding: EdgeInsets.symmetric(
                    horizontal: kh.spacing.md,
                    vertical: kh.spacing.sm,
                  ),
                ),
                onPressed: _showProvisionDialog,
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text(
                  'Provision Admin',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SizedBox(height: kh.spacing.lg),

            // Metric Cards: Total Admins, Active, Suspended, Revoked
            // Note: KhMetricCard automatically uppercases the label.
            Row(
              children: [
                Expanded(
                  child: KhMetricCard(
                    label: 'Total Admins',
                    value: isLoading ? '-' : '$totalCount',
                    linkText: 'View all',
                    onTap: () => controller.setStateFilter(null),
                  ),
                ),
                SizedBox(width: kh.spacing.md),
                Expanded(
                  child: KhMetricCard(
                    label: 'Active',
                    value: isLoading ? '-' : '$activeCount',
                    linkText: 'View active',
                    onTap: () => controller.setStateFilter(AdminAccountState.active),
                  ),
                ),
                SizedBox(width: kh.spacing.md),
                Expanded(
                  child: KhMetricCard(
                    label: 'Suspended',
                    value: isLoading ? '-' : '$suspendedCount',
                    linkText: 'View suspended',
                    onTap: () => controller.setStateFilter(AdminAccountState.suspended),
                  ),
                ),
                SizedBox(width: kh.spacing.md),
                Expanded(
                  child: KhMetricCard(
                    label: 'Revoked',
                    value: isLoading ? '-' : '$revokedCount',
                    linkText: 'View revoked',
                    onTap: () => controller.setStateFilter(AdminAccountState.deactivated),
                  ),
                ),
              ],
            ),
            SizedBox(height: kh.spacing.lg),

            // Filter Bar
            _AdminFilterBar(
              queryController: _searchController,
              currentState: filters.state,
              onSearchChanged: _onSearchChanged,
              onStateChanged: controller.setStateFilter,
              onClear: () {
                _searchController.clear();
                controller.resetFilters();
              },
            ),
            SizedBox(height: kh.spacing.lg),

            // Table Body / States
            Expanded(
              child: isLoading && filteredAdmins.isEmpty
                  ? const Center(
                      key: Key('admin-list-loading'),
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : errorMessage != null && filteredAdmins.isEmpty
                      ? Container(
                          key: const Key('admin-list-error'),
                          padding: EdgeInsets.all(kh.spacing.lg),
                          decoration: BoxDecoration(
                            color: kh.colors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kh.colors.error.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: kh.colors.error),
                              SizedBox(width: kh.spacing.md),
                              Expanded(
                                child: Text(
                                  errorMessage,
                                  style: kh.typography.body.copyWith(color: kh.colors.error),
                                ),
                              ),
                              FilledButton(
                                onPressed: controller.refresh,
                                style: FilledButton.styleFrom(
                                  backgroundColor: kh.colors.error,
                                  foregroundColor: kh.colors.cream100,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : filteredAdmins.isEmpty
                          ? Container(
                              key: const Key('admin-list-empty'),
                              width: double.infinity,
                              padding: EdgeInsets.all(kh.spacing.xxl),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: kh.colors.backgroundElevated,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: kh.colors.borderStandard),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.manage_accounts_outlined, size: 48, color: kh.colors.textMuted),
                                  SizedBox(height: kh.spacing.md),
                                  Text('No admin users found', style: kh.typography.title),
                                  SizedBox(height: kh.spacing.xs),
                                  Text(
                                    'No administrator accounts match the selected filters.',
                                    style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
                                  ),
                                ],
                              ),
                            )
                          : KhDataTable(
                              columns: const [
                                KhTableColumn('Name', flex: 3),
                                KhTableColumn('Email', flex: 3),
                                KhTableColumn('Status', flex: 2),
                                KhTableColumn('Created Date', flex: 2),
                                KhTableColumn('Actions', flex: 2),
                              ],
                              rows: filteredAdmins.map((item) {
                                return KhTableRow(
                                  key: ValueKey(item.id),
                                  cells: [
                                    // Name + short ID
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item.displayName,
                                          style: kh.typography.body.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          '#${_shortId(item.id)}',
                                          style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
                                        ),
                                      ],
                                    ),
                                    // Email
                                    Text(
                                      item.email,
                                      style: kh.typography.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // Status Chip
                                    KhStatusChip(
                                      label: item.accountState.label,
                                      tone: item.accountState.tone,
                                      dense: true,
                                    ),
                                    // Created Date
                                    Text(
                                      _formatDateTime(item.createdAt),
                                      style: kh.typography.bodySmall,
                                    ),
                                    // Actions (Suspend / Revoke)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (item.accountState == AdminAccountState.active)
                                          IconButton(
                                            key: ValueKey('suspend-${item.id}'),
                                            icon: Icon(
                                              Icons.pause_circle_outline,
                                              size: 18,
                                              color: kh.colors.warning,
                                            ),
                                            tooltip: 'Suspend Admin',
                                            onPressed: () => _showSuspendDialog(item),
                                          ),
                                        if (item.accountState != AdminAccountState.deactivated)
                                          IconButton(
                                            key: ValueKey('revoke-${item.id}'),
                                            icon: Icon(
                                              Icons.person_off_outlined,
                                              size: 18,
                                              color: kh.colors.error,
                                            ),
                                            tooltip: 'Revoke Admin',
                                            onPressed: () => _showRevokeDialog(item),
                                          ),
                                        if (item.accountState == AdminAccountState.deactivated)
                                          Text(
                                            'Revoked',
                                            style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminFilterBar extends StatelessWidget {
  const _AdminFilterBar({
    required this.queryController,
    required this.currentState,
    required this.onSearchChanged,
    required this.onStateChanged,
    required this.onClear,
  });

  final TextEditingController queryController;
  final AdminAccountState? currentState;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<AdminAccountState?> onStateChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final hasActiveFilters = queryController.text.isNotEmpty || currentState != null;

    return Container(
      padding: EdgeInsets.all(kh.spacing.sm),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Wrap(
        spacing: kh.spacing.md,
        runSpacing: kh.spacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search query field
          SizedBox(
            width: 280,
            height: 38,
            child: TextField(
              key: const Key('admin-search-field'),
              controller: queryController,
              onChanged: onSearchChanged,
              style: kh.typography.bodySmall,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                hintText: 'Search by name, email, or ID...',
                hintStyle: kh.typography.caption.copyWith(color: kh.colors.textMuted),
                prefixIcon: Icon(Icons.search, size: 18, color: kh.colors.textMuted),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: kh.colors.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: kh.colors.goldPrimary),
                ),
              ),
            ),
          ),

          // State filter dropdown
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: kh.colors.borderSubtle),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AdminAccountState?>(
                key: const Key('admin-state-filter'),
                value: currentState,
                dropdownColor: kh.colors.backgroundElevated,
                style: kh.typography.bodySmall.copyWith(color: kh.colors.textPrimary),
                items: const [
                  DropdownMenuItem(
                    value: null,
                    child: Text('All Statuses'),
                  ),
                  DropdownMenuItem(
                    value: AdminAccountState.active,
                    child: Text('Active'),
                  ),
                  DropdownMenuItem(
                    value: AdminAccountState.suspended,
                    child: Text('Suspended'),
                  ),
                  DropdownMenuItem(
                    value: AdminAccountState.deactivated,
                    child: Text('Revoked'),
                  ),
                ],
                onChanged: onStateChanged,
              ),
            ),
          ),

          // Clear filters button
          if (hasActiveFilters)
            TextButton.icon(
              key: const Key('admin-clear-filters-button'),
              style: TextButton.styleFrom(
                foregroundColor: kh.colors.textMuted,
              ),
              onPressed: onClear,
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }
}
