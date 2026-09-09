import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_data_table.dart';
import 'package:kh_admin/core/design/widgets/kh_feedback_banner.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/customers/controller/customer_detail_controller.dart';
import 'package:kh_admin/features/customers/model/customer_detail.dart';
import 'package:kh_admin/features/customers/model/customer_enums.dart';

/// ADM-S04 · Customer detail screen — full customer record, request history,
/// admin internal notes, and lifecycle controls (suspend, reactivate, erasure).
class CustomerDetailScreen extends ConsumerStatefulWidget {
  const CustomerDetailScreen({
    super.key,
    required this.customerId,
  });

  final String customerId;

  @override
  ConsumerState<CustomerDetailScreen> createState() =>
      _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends ConsumerState<CustomerDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _isProcessingAction = false;
  String? _actionFeedback;
  bool _actionSuccess = true;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  KhStatusTone _statusTone(CustomerAccountState state) {
    switch (state) {
      case CustomerAccountState.active:
        return KhStatusTone.success;
      case CustomerAccountState.suspended:
        return KhStatusTone.pending;
      case CustomerAccountState.deactivated:
        return KhStatusTone.error;
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '—';
    final date = _formatDate(dt);
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  Future<void> _executeAction({
    required String actionName,
    required Future<void> Function() task,
    required String successMessage,
  }) async {
    setState(() {
      _isProcessingAction = true;
      _actionFeedback = null;
    });

    try {
      await task();
      if (!mounted) return;
      setState(() {
        _actionFeedback = successMessage;
        _actionSuccess = true;
      });
    } on Object catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      setState(() {
        _actionFeedback = 'Failed to $actionName: $msg';
        _actionSuccess = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingAction = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final detailAsync =
        ref.watch(customerDetailControllerProvider(widget.customerId));

    return Material(
      color: kh.colors.backgroundSurface,
      child: detailAsync.when(
        loading: () => const Center(
          key: Key('customer-detail-loading'),
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, _) => SingleChildScrollView(
          padding: EdgeInsets.all(kh.spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(context, kh),
              SizedBox(height: kh.spacing.lg),
              _buildErrorView(context, kh, err.toString()),
            ],
          ),
        ),
        data: (detail) => SingleChildScrollView(
          padding: EdgeInsets.all(kh.spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(context, kh),
              SizedBox(height: kh.spacing.md),
              _buildHeader(context, kh, detail),
              if (_actionFeedback != null) ...[
                SizedBox(height: kh.spacing.md),
                KhFeedbackBanner(
                  key: const Key('customer-detail-feedback-banner'),
                  message: _actionFeedback!,
                  isSuccess: _actionSuccess,
                ),
              ],
              SizedBox(height: kh.spacing.xl),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSummaryCard(kh, detail),
                              SizedBox(height: kh.spacing.lg),
                              _buildRequestHistoryCard(kh, detail),
                              SizedBox(height: kh.spacing.lg),
                              _buildAdminNotesCard(kh, detail),
                            ],
                          ),
                        ),
                        SizedBox(width: kh.spacing.lg),
                        Expanded(
                          flex: 2,
                          child: _buildLifecycleActionsCard(context, kh, detail),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSummaryCard(kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildLifecycleActionsCard(context, kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildRequestHistoryCard(kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildAdminNotesCard(kh, detail),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, KhThemeExtension kh) {
    return TextButton.icon(
      key: const Key('customer-detail-back-button'),
      onPressed: () => context.go('/customers'),
      icon: const Icon(Icons.arrow_back, size: 18),
      label: const Text('Back to Customers'),
      style: TextButton.styleFrom(
        foregroundColor: kh.colors.goldPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: kh.spacing.sm,
          vertical: kh.spacing.xs,
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    KhThemeExtension kh,
    CustomerDetail detail,
  ) {
    return KhScreenHeader(
      eyebrow: 'Customer Profile',
      heading: detail.displayName.isNotEmpty
          ? detail.displayName
          : 'Customer Record',
      supportingText: 'ID: ${detail.id} • User ID: ${detail.userId}',
      trailing: KhStatusChip(
        label: detail.accountState.displayName,
        tone: _statusTone(detail.accountState),
      ),
    );
  }

  Widget _buildSummaryCard(KhThemeExtension kh, CustomerDetail detail) {
    return Container(
      key: const Key('customer-summary-card'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(
          color: kh.colors.borderSubtle,
          width: kh.shapes.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: kh.colors.goldPrimary.withValues(alpha: 0.18),
                child: Text(
                  detail.displayName.isNotEmpty
                      ? detail.displayName[0].toUpperCase()
                      : 'C',
                  style: kh.typography.headline.copyWith(
                    color: kh.colors.goldPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: kh.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.displayName.isNotEmpty
                          ? detail.displayName
                          : 'Unnamed Customer',
                      style: kh.typography.title.copyWith(
                        fontWeight: FontWeight.bold,
                        color: kh.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: kh.spacing.xxs),
                    KhStatusChip(
                      label: detail.accountState.displayName,
                      tone: _statusTone(detail.accountState),
                      dense: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: kh.spacing.lg),
          Divider(color: kh.colors.borderSubtle, height: 1),
          SizedBox(height: kh.spacing.md),
          _buildInfoRow(kh, 'Email Address', detail.email ?? '—'),
          _buildInfoRow(kh, 'Mobile Number', detail.mobileNumber ?? '—'),
          _buildInfoRow(kh, 'Default Region', detail.defaultRegion ?? 'UAE (Default)'),
          _buildInfoRow(kh, 'Joined Date', _formatDate(detail.createdAt)),
          _buildInfoRow(kh, 'User ID', detail.userId),
          _buildInfoRow(kh, 'Customer Profile ID', detail.id),
        ],
      ),
    );
  }

  Widget _buildInfoRow(KhThemeExtension kh, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: kh.spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: kh.typography.caption.copyWith(
                color: kh.colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifecycleActionsCard(
    BuildContext context,
    KhThemeExtension kh,
    CustomerDetail detail,
  ) {
    final isSuspended = detail.accountState == CustomerAccountState.suspended;
    final isDeactivated = detail.accountState == CustomerAccountState.deactivated;

    return Container(
      key: const Key('customer-lifecycle-card'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(
          color: kh.colors.borderSubtle,
          width: kh.shapes.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KhSectionLabel('ADMIN ACTIONS'),
          SizedBox(height: kh.spacing.xs),
          Text(
            'Account Lifecycle Controls',
            style: kh.typography.title.copyWith(color: kh.colors.textPrimary),
          ),
          SizedBox(height: kh.spacing.xs),
          Text(
            'Administrative actions modify account access and are logged to the platform audit trail.',
            style: kh.typography.caption.copyWith(color: kh.colors.textSecondary),
          ),
          SizedBox(height: kh.spacing.lg),
          if (_isProcessingAction)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            if (isSuspended)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const Key('customer-reactivate-button'),
                  onPressed: () => _promptReactivateDialog(context, kh, detail),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reactivate Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kh.colors.success,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: kh.spacing.sm),
                  ),
                ),
              )
            else if (!isDeactivated)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('customer-suspend-button'),
                  onPressed: () => _promptSuspendDialog(context, kh, detail),
                  icon: const Icon(Icons.block, size: 18),
                  label: const Text('Suspend Customer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kh.colors.warning,
                    side: BorderSide(color: kh.colors.warning),
                    padding: EdgeInsets.symmetric(vertical: kh.spacing.sm),
                  ),
                ),
              ),
            SizedBox(height: kh.spacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                key: const Key('customer-erasure-button'),
                onPressed: () => _promptErasureDialog(context, kh, detail),
                icon: const Icon(Icons.delete_forever, size: 18),
                label: const Text('Request data erasure'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kh.colors.error,
                  side: BorderSide(color: kh.colors.error),
                  padding: EdgeInsets.symmetric(vertical: kh.spacing.sm),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestHistoryCard(KhThemeExtension kh, CustomerDetail detail) {
    return Container(
      key: const Key('customer-request-history-card'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(
          color: kh.colors.borderSubtle,
          width: kh.shapes.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KhSectionLabel('ACTIVITY HISTORY'),
          SizedBox(height: kh.spacing.xs),
          Text(
            'Customer Requests (${detail.requests.length})',
            style: kh.typography.title.copyWith(color: kh.colors.textPrimary),
          ),
          SizedBox(height: kh.spacing.md),
          if (detail.requests.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Center(
                child: Text(
                  'No requests submitted by this customer yet.',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textSecondary,
                  ),
                ),
              ),
            )
          else
            KhDataTable(
              key: const Key('customer-requests-table'),
              minWidth: 640,
              columns: const [
                KhTableColumn('Reference / ID', flex: 2),
                KhTableColumn('Type', flex: 2),
                KhTableColumn('State', flex: 2),
                KhTableColumn('Offers', flex: 1),
                KhTableColumn('Created Date', flex: 2),
              ],
              rows: [
                for (final req in detail.requests)
                  KhTableRow(
                    cells: [
                      Text(
                        req.reference ??
                            (req.id.length > 8 ? req.id.substring(0, 8) : req.id),
                        style: kh.typography.bodySmall.copyWith(
                          color: kh.colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        req.requestType ?? '—',
                        style: kh.typography.bodySmall.copyWith(
                          color: kh.colors.textSecondary,
                        ),
                      ),
                      KhStatusChip(
                        label: req.state ?? 'UNKNOWN',
                        dense: true,
                        tone: (req.state == 'ACCEPTED' || req.state == 'FULFILLED')
                            ? KhStatusTone.success
                            : (req.state == 'CANCELLED' || req.state == 'EXPIRED')
                                ? KhStatusTone.error
                                : KhStatusTone.neutral,
                      ),
                      Text(
                        '${req.offerCount}',
                        style: kh.typography.bodySmall.copyWith(
                          color: kh.colors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatDate(req.createdAt),
                        style: kh.typography.bodySmall.copyWith(
                          color: kh.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAdminNotesCard(KhThemeExtension kh, CustomerDetail detail) {
    return Container(
      key: const Key('customer-admin-notes-card'),
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(
          color: kh.colors.borderSubtle,
          width: kh.shapes.cardBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KhSectionLabel('ADMIN AUDIT & NOTES'),
          SizedBox(height: kh.spacing.xs),
          Text(
            'Internal Notes (${detail.adminNotes.length})',
            style: kh.typography.title.copyWith(color: kh.colors.textPrimary),
          ),
          SizedBox(height: kh.spacing.xs),
          Text(
            'Internal notes are strictly visible to platform admins and tracked with timestamps.',
            style: kh.typography.caption.copyWith(color: kh.colors.textSecondary),
          ),
          SizedBox(height: kh.spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('customer-note-input-field'),
                  controller: _noteController,
                  maxLines: 2,
                  style: kh.typography.bodySmall,
                  decoration: InputDecoration(
                    hintText: 'Add an internal admin note…',
                    isDense: true,
                    filled: true,
                    fillColor: kh.colors.backgroundSurface,
                    border: OutlineInputBorder(
                      borderRadius: kh.shapes.roundedMd,
                      borderSide: BorderSide(color: kh.colors.borderSubtle),
                    ),
                  ),
                ),
              ),
              SizedBox(width: kh.spacing.sm),
              ElevatedButton.icon(
                key: const Key('customer-add-note-button'),
                onPressed: _isProcessingAction
                    ? null
                    : () async {
                        final text = _noteController.text.trim();
                        if (text.isEmpty) return;
                        await _executeAction(
                          actionName: 'add note',
                          task: () async {
                            await ref
                                .read(customerDetailControllerProvider(
                                        detail.id)
                                    .notifier)
                                .addAdminNote(text);
                            _noteController.clear();
                          },
                          successMessage: 'Admin note added successfully.',
                        );
                      },
                icon: const Icon(Icons.note_add, size: 16),
                label: const Text('Add Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kh.colors.goldPrimary,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: kh.spacing.md,
                    vertical: kh.spacing.sm,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: kh.spacing.lg),
          if (detail.adminNotes.isEmpty)
            Text(
              'No internal notes added yet.',
              style: kh.typography.caption.copyWith(
                color: kh.colors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detail.adminNotes.length,
              separatorBuilder: (_, __) => SizedBox(height: kh.spacing.sm),
              itemBuilder: (context, idx) {
                final note = detail.adminNotes[idx];
                return Container(
                  padding: EdgeInsets.all(kh.spacing.sm),
                  decoration: BoxDecoration(
                    color: kh.colors.backgroundSurface,
                    borderRadius: kh.shapes.roundedMd,
                    border: Border.all(color: kh.colors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            note.authorName,
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.goldPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDateTime(note.createdAt),
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.textMuted,
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: kh.spacing.xs),
                      Text(
                        note.text,
                        style: kh.typography.bodySmall.copyWith(
                          color: kh.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _promptSuspendDialog(
    BuildContext context,
    KhThemeExtension kh,
    CustomerDetail detail,
  ) async {
    final formKey = GlobalKey<FormState>();
    var selectedReasonCode = 'POLICY_VIOLATION';
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Suspend Customer Account', style: kh.typography.title),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suspending ${detail.displayName} will block customer login and invalidate active requests.',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textSecondary,
                  ),
                ),
                SizedBox(height: kh.spacing.md),
                DropdownButtonFormField<String>(
                  key: const Key('suspend-customer-reason-code-field'),
                  initialValue: selectedReasonCode,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Reason Code',
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'POLICY_VIOLATION',
                      child: Text('Policy Violation / Terms Breach'),
                    ),
                    DropdownMenuItem(
                      value: 'ABUSE_SUSPICION',
                      child: Text('Abuse or Suspicious Activity'),
                    ),
                    DropdownMenuItem(
                      value: 'FRAUD_PREVENTION',
                      child: Text('Fraud Prevention / Dispute'),
                    ),
                    DropdownMenuItem(
                      value: 'CUSTOMER_REQUEST',
                      child: Text('Customer Request'),
                    ),
                    DropdownMenuItem(
                      value: 'ADMIN_DISCRETION',
                      child: Text('Administrative Discretion'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) selectedReasonCode = val;
                  },
                ),
                SizedBox(height: kh.spacing.md),
                TextFormField(
                  key: const Key('suspend-customer-reason-text-field'),
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason Explanation',
                    hintText: 'Provide detailed justification for suspension…',
                    isDense: true,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Reason explanation is required.'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirm-suspend-customer-button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kh.colors.warning,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogCtx).pop(true);
              }
            },
            child: const Text('Confirm Suspension'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _executeAction(
        actionName: 'suspend customer',
        task: () => ref
            .read(customerDetailControllerProvider(detail.id).notifier)
            .suspendCustomer(
              reasonCode: selectedReasonCode,
              reasonText: reasonController.text.trim(),
            ),
        successMessage: 'Customer account suspended successfully.',
      );
    }
  }

  Future<void> _promptReactivateDialog(
    BuildContext context,
    KhThemeExtension kh,
    CustomerDetail detail,
  ) async {
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Reactivate Customer Account', style: kh.typography.title),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reactivating ${detail.displayName} will restore full customer login and marketplace browsing access.',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textSecondary,
                  ),
                ),
                SizedBox(height: kh.spacing.md),
                TextFormField(
                  key: const Key('reactivate-customer-reason-text-field'),
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reactivation Rationale',
                    hintText: 'Explain why this account is being restored…',
                    isDense: true,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Reactivation rationale is required.'
                      : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirm-reactivate-customer-button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kh.colors.success,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogCtx).pop(true);
              }
            },
            child: const Text('Confirm Reactivation'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _executeAction(
        actionName: 'reactivate customer',
        task: () => ref
            .read(customerDetailControllerProvider(detail.id).notifier)
            .reactivateCustomer(
              reasonText: reasonController.text.trim(),
            ),
        successMessage: 'Customer account reactivated successfully.',
      );
    }
  }

  Future<void> _promptErasureDialog(
    BuildContext context,
    KhThemeExtension kh,
    CustomerDetail detail,
  ) async {
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: kh.colors.error, size: 24),
            SizedBox(width: kh.spacing.xs),
            Text('Confirm data erasure', style: kh.typography.title),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This will initiate permanent PII anonymization for ${detail.displayName} under UAE Personal Data Protection Law and FR-CUS-004.\n\nAll personal identifiable information (name, email, mobile phone, and profile links) will be permanently scrambled and removed.\n\nThis action is irreversible.',
                  style: kh.typography.bodySmall.copyWith(
                    color: kh.colors.textSecondary,
                  ),
                ),
                SizedBox(height: kh.spacing.md),
                TextFormField(
                  key: const Key('erasure-customer-reason-text-field'),
                  controller: reasonController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Erasure rationale',
                    hintText: 'Mandatory justification for PII anonymization…',
                    isDense: true,
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Erasure rationale is required.'
                      : null,
                ),
                SizedBox(height: kh.spacing.md),
                Container(
                  padding: EdgeInsets.all(kh.spacing.sm),
                  decoration: BoxDecoration(
                    color: kh.colors.error.withValues(alpha: 0.1),
                    borderRadius: kh.shapes.roundedMd,
                    border: Border.all(
                      color: kh.colors.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'WARNING: Once anonymized, this customer account cannot be recovered or identified.',
                    style: kh.typography.caption.copyWith(
                      color: kh.colors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            key: const Key('confirm-erasure-customer-button'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kh.colors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.of(dialogCtx).pop(true);
              }
            },
            child: const Text('Permanently Anonymize PII'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _executeAction(
        actionName: 'request erasure',
        task: () => ref
            .read(customerDetailControllerProvider(detail.id).notifier)
            .erasureCustomer(reasonText: reasonController.text.trim()),
        successMessage: 'Customer PII anonymization completed.',
      );
    }
  }

  Widget _buildErrorView(BuildContext context, KhThemeExtension kh, String error) {
    return Center(
      key: const Key('customer-detail-error'),
      child: Padding(
        padding: EdgeInsets.all(kh.spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: kh.colors.error),
            SizedBox(height: kh.spacing.md),
            Text(
              'Failed to load customer profile',
              style: kh.typography.title.copyWith(color: kh.colors.textPrimary),
            ),
            SizedBox(height: kh.spacing.xs),
            Text(
              error,
              textAlign: TextAlign.center,
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textSecondary,
              ),
            ),
            SizedBox(height: kh.spacing.md),
            ElevatedButton.icon(
              key: const Key('customer-detail-retry-button'),
              onPressed: () => ref
                  .read(customerDetailControllerProvider(widget.customerId).notifier)
                  .reload(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
