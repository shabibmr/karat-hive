import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_feedback_banner.dart';
import 'package:kh_admin/features/customers/controller/customer_detail_controller.dart';
import 'package:kh_admin/features/customers/model/customer_detail.dart';
import 'package:kh_admin/features/customers/presentation/widgets/customer_admin_notes_card.dart';
import 'package:kh_admin/features/customers/presentation/widgets/customer_detail_error_view.dart';
import 'package:kh_admin/features/customers/presentation/widgets/customer_detail_header.dart';
import 'package:kh_admin/features/customers/presentation/widgets/customer_lifecycle_actions_card.dart';
import 'package:kh_admin/features/customers/presentation/widgets/customer_request_history_card.dart';
import 'package:kh_admin/features/customers/presentation/widgets/customer_summary_card.dart';

/// ADM-S04 · Customer detail screen — full customer record, request history,
/// admin internal notes, and lifecycle controls (suspend, reactivate, erasure).
///
/// Composition root only: each section lives in `presentation/widgets/`
/// (TR-S2-12). Screen state owns the note field and lifecycle dialogs.
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

  Future<void> _handleAddNote(CustomerDetail detail) async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;
    await _executeAction(
      actionName: 'add note',
      task: () async {
        await ref
            .read(customerDetailControllerProvider(detail.id).notifier)
            .addAdminNote(text);
        _noteController.clear();
      },
      successMessage: 'Admin note added successfully.',
    );
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
              const CustomerDetailBackButton(),
              SizedBox(height: kh.spacing.lg),
              CustomerDetailErrorView(
                error: err.toString(),
                onRetry: () => ref
                    .read(customerDetailControllerProvider(widget.customerId)
                        .notifier)
                    .reload(),
              ),
            ],
          ),
        ),
        data: (detail) => SingleChildScrollView(
          padding: EdgeInsets.all(kh.spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomerDetailBackButton(),
              SizedBox(height: kh.spacing.md),
              CustomerDetailHeader(detail: detail),
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
                  final lifecycleCard = CustomerLifecycleActionsCard(
                    detail: detail,
                    isProcessing: _isProcessingAction,
                    onReactivate: () =>
                        _promptReactivateDialog(context, kh, detail),
                    onSuspend: () => _promptSuspendDialog(context, kh, detail),
                    onErasure: () => _promptErasureDialog(context, kh, detail),
                  );
                  final notesCard = CustomerAdminNotesCard(
                    detail: detail,
                    noteController: _noteController,
                    isProcessing: _isProcessingAction,
                    onAddNote: () => _handleAddNote(detail),
                  );
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomerSummaryCard(detail: detail),
                              SizedBox(height: kh.spacing.lg),
                              CustomerRequestHistoryCard(detail: detail),
                              SizedBox(height: kh.spacing.lg),
                              notesCard,
                            ],
                          ),
                        ),
                        SizedBox(width: kh.spacing.lg),
                        Expanded(
                          flex: 2,
                          child: lifecycleCard,
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomerSummaryCard(detail: detail),
                      SizedBox(height: kh.spacing.lg),
                      lifecycleCard,
                      SizedBox(height: kh.spacing.lg),
                      CustomerRequestHistoryCard(detail: detail),
                      SizedBox(height: kh.spacing.lg),
                      notesCard,
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
}
