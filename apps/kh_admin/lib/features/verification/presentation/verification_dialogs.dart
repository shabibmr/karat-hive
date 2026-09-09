import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/api/api_exception.dart';
import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/l10n/app_localizations.dart';
import 'package:kh_admin/features/verification/controller/verification_controller.dart';

/// Shows the [ApproveVerificationDialog]. Returns true if approval was submitted successfully.
Future<bool?> showApproveVerificationDialog({
  required BuildContext context,
  required String vendorId,
  String? vendorName,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => ApproveVerificationDialog(
      vendorId: vendorId,
      vendorName: vendorName,
    ),
  );
}

/// Shows the [RejectVerificationDialog]. Returns true if rejection was submitted successfully.
Future<bool?> showRejectVerificationDialog({
  required BuildContext context,
  required String vendorId,
  String? vendorName,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => RejectVerificationDialog(
      vendorId: vendorId,
      vendorName: vendorName,
    ),
  );
}

/// Shows the [RequestInfoDialog]. Returns true if information request was submitted successfully.
Future<bool?> showRequestInfoDialog({
  required BuildContext context,
  required String vendorId,
  String? vendorName,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => RequestInfoDialog(
      vendorId: vendorId,
      vendorName: vendorName,
    ),
  );
}

/// Dialog requiring rationale before approving vendor verification (ADM-S07).
class ApproveVerificationDialog extends ConsumerStatefulWidget {
  const ApproveVerificationDialog({
    super.key,
    required this.vendorId,
    this.vendorName,
  });

  final String vendorId;
  final String? vendorName;

  @override
  ConsumerState<ApproveVerificationDialog> createState() =>
      _ApproveVerificationDialogState();
}

class _ApproveVerificationDialogState
    extends ConsumerState<ApproveVerificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _rationaleController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _rationaleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final rationale = _rationaleController.text.trim();
      await ref
          .read(verificationQueueControllerProvider.notifier)
          .verifyVendor(widget.vendorId, rationale);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e is ApiException ? e.message : e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: colors.backgroundElevated,
      shape: RoundedRectangleBorder(
        borderRadius: shapes.roundedMd,
        side: BorderSide(color: colors.borderSubtle),
      ),
      titlePadding: EdgeInsets.fromLTRB(spacing.lg, spacing.lg, spacing.lg, spacing.sm),
      contentPadding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
      actionsPadding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.lg, spacing.lg),
      title: Row(
        children: [
          Icon(Icons.check_circle_outline, color: colors.success, size: 24),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              l10n?.approveConfirmTitle ?? 'Approve Verification',
              style: typography.title.copyWith(color: colors.cream100),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.vendorName != null
                    ? 'Approve verification for "${widget.vendorName}". Approval advances vendor toward ACTIVE marketplace status. Audit rationale is required.'
                    : (l10n?.approveConfirmBody ??
                        'This will mark the vendor as VERIFIED and may advance them to ACTIVE if categories and regions are already declared. The decision is audit-logged.'),
                style: typography.bodySmall.copyWith(color: colors.cream200),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: spacing.md),
                _DialogErrorBanner(message: _errorMessage!),
              ],
              SizedBox(height: spacing.md),
              Text(
                'Approval Rationale *',
                style: typography.label.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.xs),
              TextFormField(
                key: const Key('approve-rationale-field'),
                controller: _rationaleController,
                enabled: !_isSubmitting,
                maxLines: 3,
                style: typography.body.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Enter internal rationale for approving this vendor credentials...',
                ),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return 'Rationale is required for approval';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        ElevatedButton(
          key: const Key('confirm-approve-button'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.success,
            foregroundColor: colors.cream100,
          ),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(l10n?.confirmApprove ?? 'Approve Verification'),
        ),
      ],
    );
  }
}

/// Dialog requiring rationale + message to vendor before rejecting vendor verification (ADM-S07).
class RejectVerificationDialog extends ConsumerStatefulWidget {
  const RejectVerificationDialog({
    super.key,
    required this.vendorId,
    this.vendorName,
  });

  final String vendorId;
  final String? vendorName;

  @override
  ConsumerState<RejectVerificationDialog> createState() =>
      _RejectVerificationDialogState();
}

class _RejectVerificationDialogState
    extends ConsumerState<RejectVerificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _rationaleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _rationaleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final rationale = _rationaleController.text.trim();
      final message = _messageController.text.trim();
      final fullRationale = message.isNotEmpty
          ? '$rationale (Vendor notification: $message)'
          : rationale;

      await ref
          .read(verificationQueueControllerProvider.notifier)
          .rejectVendor(widget.vendorId, fullRationale);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e is ApiException ? e.message : e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: colors.backgroundElevated,
      shape: RoundedRectangleBorder(
        borderRadius: shapes.roundedMd,
        side: BorderSide(color: colors.borderSubtle),
      ),
      titlePadding: EdgeInsets.fromLTRB(spacing.lg, spacing.lg, spacing.lg, spacing.sm),
      contentPadding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
      actionsPadding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.lg, spacing.lg),
      title: Row(
        children: [
          Icon(Icons.cancel_outlined, color: colors.error, size: 24),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              l10n?.rejectConfirmTitle ?? 'Reject Verification',
              style: typography.title.copyWith(color: colors.cream100),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.vendorName != null
                    ? 'Reject verification for "${widget.vendorName}". The vendor will be notified and may resubmit. Both internal rationale and vendor message are required.'
                    : (l10n?.rejectConfirmBody ??
                        'The vendor will be notified with your rationale and may resubmit documents. This decision is audit-logged.'),
                style: typography.bodySmall.copyWith(color: colors.cream200),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: spacing.md),
                _DialogErrorBanner(message: _errorMessage!),
              ],
              SizedBox(height: spacing.md),
              Text(
                'Internal Rationale *',
                style: typography.label.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.xs),
              TextFormField(
                key: const Key('reject-rationale-field'),
                controller: _rationaleController,
                enabled: !_isSubmitting,
                maxLines: 2,
                style: typography.body.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Internal audit reason for rejection...',
                ),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return 'Rationale is required for rejection';
                  }
                  return null;
                },
              ),
              SizedBox(height: spacing.md),
              Text(
                'Message to Vendor *',
                style: typography.label.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.xs),
              TextFormField(
                key: const Key('reject-message-field'),
                controller: _messageController,
                enabled: !_isSubmitting,
                maxLines: 3,
                style: typography.body.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Explain to vendor why credentials were rejected so they can re-upload...',
                ),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return 'Message to vendor is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        ElevatedButton(
          key: const Key('confirm-reject-button'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: colors.cream100,
          ),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(l10n?.confirmReject ?? 'Reject Verification'),
        ),
      ],
    );
  }
}

/// Dialog requiring message to vendor before requesting more information (ADM-S07).
class RequestInfoDialog extends ConsumerStatefulWidget {
  const RequestInfoDialog({
    super.key,
    required this.vendorId,
    this.vendorName,
  });

  final String vendorId;
  final String? vendorName;

  @override
  ConsumerState<RequestInfoDialog> createState() => _RequestInfoDialogState();
}

class _RequestInfoDialogState extends ConsumerState<RequestInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final message = _messageController.text.trim();
      await ref
          .read(verificationQueueControllerProvider.notifier)
          .requestInfo(widget.vendorId, message);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e is ApiException ? e.message : e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: colors.backgroundElevated,
      shape: RoundedRectangleBorder(
        borderRadius: shapes.roundedMd,
        side: BorderSide(color: colors.borderSubtle),
      ),
      titlePadding: EdgeInsets.fromLTRB(spacing.lg, spacing.lg, spacing.lg, spacing.sm),
      contentPadding: EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
      actionsPadding: EdgeInsets.fromLTRB(spacing.lg, spacing.sm, spacing.lg, spacing.lg),
      title: Row(
        children: [
          Icon(Icons.mail_outline, color: colors.goldPrimary, size: 24),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              l10n?.requestInfoConfirmTitle ?? 'Request More Information',
              style: typography.title.copyWith(color: colors.cream100),
            ),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.vendorName != null
                    ? 'Request more information from "${widget.vendorName}". The vendor will remain in the queue while reviewing your request.'
                    : (l10n?.requestInfoConfirmBody ??
                        'The vendor will remain in the verification queue and see your message in their awaiting-approval shell.'),
                style: typography.bodySmall.copyWith(color: colors.cream200),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: spacing.md),
                _DialogErrorBanner(message: _errorMessage!),
              ],
              SizedBox(height: spacing.md),
              Text(
                'Message to Vendor *',
                style: typography.label.copyWith(color: colors.textSecondary),
              ),
              SizedBox(height: spacing.xs),
              TextFormField(
                key: const Key('request-info-message-field'),
                controller: _messageController,
                enabled: !_isSubmitting,
                maxLines: 4,
                style: typography.body.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Describe what additional clarification or documents are required from vendor...',
                ),
                validator: (value) {
                  if ((value?.trim() ?? '').isEmpty) {
                    return 'Message to vendor is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        ElevatedButton(
          key: const Key('confirm-request-info-button'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.gold400,
            foregroundColor: colors.sapphire900,
          ),
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n?.confirmRequestInfo ?? 'Send Request'),
        ),
      ],
    );
  }
}

class _DialogErrorBanner extends StatelessWidget {
  const _DialogErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.kh.colors;
    final typography = context.kh.typography;
    final spacing = context.kh.spacing;
    final shapes = context.kh.shapes;

    return Container(
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.15),
        borderRadius: shapes.roundedSm,
        border: Border.all(color: colors.error.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 16, color: colors.error),
          SizedBox(width: spacing.xs),
          Expanded(
            child: Text(
              message,
              style: typography.caption.copyWith(color: colors.cream100),
            ),
          ),
        ],
      ),
    );
  }
}
