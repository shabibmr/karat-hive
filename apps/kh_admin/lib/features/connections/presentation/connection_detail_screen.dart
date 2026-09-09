import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_screen_header.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/features/connections/controller/connection_detail_controller.dart';
import 'package:kh_admin/features/connections/presentation/widgets/connection_accepted_offer_card.dart';
import 'package:kh_admin/features/connections/presentation/widgets/connection_admin_notes_card.dart';
import 'package:kh_admin/features/connections/presentation/widgets/connection_contact_events_card.dart';
import 'package:kh_admin/features/connections/presentation/widgets/connection_detail_error_state.dart';
import 'package:kh_admin/features/connections/presentation/widgets/connection_detail_formatters.dart';
import 'package:kh_admin/features/connections/presentation/widgets/connection_lifecycle_actions_card.dart';
import 'package:kh_admin/features/connections/presentation/widgets/connection_request_card.dart';

/// ADM-S13 · Connection detail — Full connection record, unmasked parties,
/// contact attempts timeline, admin notes, and connection close lifecycle action.
///
/// Composition root only: each section lives in `presentation/widgets/`
/// (TR-S2-14). Screen state owns the note field and the close-connection modal.
class ConnectionDetailScreen extends ConsumerStatefulWidget {
  const ConnectionDetailScreen({
    super.key,
    required this.connectionId,
  });

  final String connectionId;

  @override
  ConsumerState<ConnectionDetailScreen> createState() => _ConnectionDetailScreenState();
}

class _ConnectionDetailScreenState extends ConsumerState<ConnectionDetailScreen> {
  final TextEditingController _noteController = TextEditingController();
  bool _isPostingNote = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handlePostNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPostingNote = true);
    try {
      await ref
          .read(connectionDetailControllerProvider(widget.connectionId).notifier)
          .addAdminNote(text);
      _noteController.clear();
    } finally {
      if (mounted) {
        setState(() => _isPostingNote = false);
      }
    }
  }

  Future<void> _showCloseConnectionModal(BuildContext context) async {
    final reasonController = TextEditingController();
    bool isClosing = false;
    String? validationError;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final kh = context.kh;

            return AlertDialog(
              backgroundColor: kh.colors.backgroundElevated,
              shape: RoundedRectangleBorder(
                borderRadius: kh.shapes.roundedLg,
                side: BorderSide(
                  color: kh.colors.borderStandard,
                  width: kh.shapes.cardBorderWidth,
                ),
              ),
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: kh.colors.error, size: 24),
                  SizedBox(width: kh.spacing.sm),
                  Text(
                    'Close Connection',
                    style: kh.typography.title.copyWith(color: kh.colors.textPrimary),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(kh.spacing.sm),
                      decoration: BoxDecoration(
                        color: kh.colors.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: kh.colors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Closing this connection terminates the introduction between the customer and vendor. '
                        'Both parties will be notified, and the introduction will be marked as closed. '
                        'A reason is mandatory for the audit log.',
                        style: kh.typography.bodySmall.copyWith(
                          color: kh.colors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: kh.spacing.md),
                    TextField(
                      key: const Key('close-connection-reason-input'),
                      controller: reasonController,
                      maxLines: 3,
                      enabled: !isClosing,
                      decoration: InputDecoration(
                        labelText: 'Reason for closing (Mandatory)',
                        hintText: 'e.g. Customer decided not to proceed, unresponsive vendor…',
                        errorText: validationError,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  key: const Key('close-connection-dialog-cancel'),
                  onPressed: isClosing ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  key: const Key('close-connection-dialog-confirm'),
                  style: FilledButton.styleFrom(
                    backgroundColor: kh.colors.error,
                  ),
                  onPressed: isClosing
                      ? null
                      : () async {
                          final reason = reasonController.text.trim();
                          if (reason.isEmpty) {
                            setDialogState(() {
                              validationError = 'Please provide a reason for closing';
                            });
                            return;
                          }

                          setDialogState(() {
                            isClosing = true;
                            validationError = null;
                          });

                          try {
                            await ref
                                .read(connectionDetailControllerProvider(widget.connectionId).notifier)
                                .closeConnection(reasonText: reason);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          } on Object catch (e) {
                            setDialogState(() {
                              isClosing = false;
                              validationError = 'Error: $e';
                            });
                          }
                        },
                  child: isClosing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Close Connection'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final asyncDetail = ref.watch(connectionDetailControllerProvider(widget.connectionId));

    return Material(
      color: kh.colors.backgroundSurface,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(kh.spacing.xl),
        child: asyncDetail.when(
          loading: () => const Center(
            key: Key('connection-detail-loading'),
            child: Padding(
              padding: EdgeInsets.all(64.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => ConnectionDetailErrorState(
            key: const Key('connection-detail-error'),
            message: err.toString().replaceFirst(RegExp(r'^Exception:\s*'), ''),
            onRetry: () => ref
                .read(connectionDetailControllerProvider(widget.connectionId).notifier)
                .reload(),
          ),
          data: (detail) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Navigation Button
              Row(
                children: [
                  OutlinedButton.icon(
                    key: const Key('back-to-connections-button'),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/connections');
                      }
                    },
                    icon: const Icon(Icons.arrow_back, size: 16.0),
                    label: const Text(
                      'Back to Connections',
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),
                ],
              ),
              SizedBox(height: kh.spacing.md),

              // Screen Header
              KhScreenHeader(
                eyebrow: 'CONNECTION #${detail.id}',
                heading: '${detail.customer?.displayName ?? "Customer"} ↔ ${detail.vendor?.legalBusinessName ?? "Vendor"}',
                supportingText:
                    'Created on ${connectionFormatDate(detail.createdAt)}${detail.identityRevealedAt != null ? " · Identity revealed on ${connectionFormatDate(detail.identityRevealedAt)}" : ""}',
                trailing: KhStatusChip(
                  label: detail.state.displayName.toUpperCase(),
                  tone: detail.state.statusTone,
                ),
              ),
              SizedBox(height: kh.spacing.xl),

              // Responsive Two-Column Layout
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  final lifecycleCard = ConnectionLifecycleActionsCard(
                    detail: detail,
                    onClose: () => _showCloseConnectionModal(context),
                  );
                  final notesCard = ConnectionAdminNotesCard(
                    detail: detail,
                    noteController: _noteController,
                    isPosting: _isPostingNote,
                    onPost: _handlePostNote,
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
                              ConnectionRequestCard(detail: detail),
                              SizedBox(height: kh.spacing.lg),
                              ConnectionAcceptedOfferCard(detail: detail),
                              SizedBox(height: kh.spacing.lg),
                              ConnectionContactEventsCard(detail: detail),
                            ],
                          ),
                        ),
                        SizedBox(width: kh.spacing.lg),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              lifecycleCard,
                              SizedBox(height: kh.spacing.lg),
                              notesCard,
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      lifecycleCard,
                      SizedBox(height: kh.spacing.lg),
                      ConnectionRequestCard(detail: detail),
                      SizedBox(height: kh.spacing.lg),
                      ConnectionAcceptedOfferCard(detail: detail),
                      SizedBox(height: kh.spacing.lg),
                      ConnectionContactEventsCard(detail: detail),
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
}
