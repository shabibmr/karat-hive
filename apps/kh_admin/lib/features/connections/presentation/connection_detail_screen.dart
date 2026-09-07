import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/theme/kh_theme.dart';
import '../../../core/design/widgets/kh_screen_header.dart';
import '../../../core/design/widgets/kh_section_label.dart';
import '../../../core/design/widgets/kh_status_chip.dart';
import '../controller/connection_detail_controller.dart';
import '../model/connection_detail.dart';
import '../model/connection_enums.dart';

/// ADM-S13 · Connection detail — Full connection record, unmasked parties,
/// contact attempts timeline, admin notes, and connection close lifecycle action.
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

  static String _formatPrice(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return 'AED $whole.${parts[1]}';
  }

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    final utc = dt.toUtc();
    final gst = utc.add(const Duration(hours: 4));
    final year = gst.year.toString().padLeft(4, '0');
    final month = gst.month.toString().padLeft(2, '0');
    final day = gst.day.toString().padLeft(2, '0');
    final hour = gst.hour.toString().padLeft(2, '0');
    final minute = gst.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute GST';
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
                          } catch (e) {
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
          error: (err, _) => _DetailErrorState(
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
                    'Created on ${_formatDate(detail.createdAt)}${detail.identityRevealedAt != null ? " · Identity revealed on ${_formatDate(detail.identityRevealedAt)}" : ""}',
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
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildRequestCard(kh, detail),
                              SizedBox(height: kh.spacing.lg),
                              _buildAcceptedOfferCard(kh, detail),
                              SizedBox(height: kh.spacing.lg),
                              _buildContactEventsCard(kh, detail),
                            ],
                          ),
                        ),
                        SizedBox(width: kh.spacing.lg),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLifecycleActionsCard(context, kh, detail),
                              SizedBox(height: kh.spacing.lg),
                              _buildAdminNotesCard(kh, detail),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLifecycleActionsCard(context, kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildRequestCard(kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildAcceptedOfferCard(kh, detail),
                      SizedBox(height: kh.spacing.lg),
                      _buildContactEventsCard(kh, detail),
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

  Widget _buildRequestCard(dynamic kh, ConnectionDetail detail) {
    final request = detail.request;
    final customer = detail.customer;

    return Container(
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
              Icon(Icons.shopping_bag_outlined, color: kh.colors.goldPrimary, size: 20),
              SizedBox(width: kh.spacing.xs),
              Text('Originating Request', style: kh.typography.title),
              if (request?.reference != null) ...[
                const Spacer(),
                Text(
                  request!.reference!,
                  style: kh.typography.bodySmall.copyWith(color: kh.colors.goldPrimary),
                ),
              ],
            ],
          ),
          Divider(color: kh.colors.borderSubtle, height: kh.spacing.lg * 2),
          _infoRow(kh, 'Customer Name', customer?.displayName ?? '—'),
          _infoRow(kh, 'Customer Email', customer?.email ?? '—'),
          _infoRow(kh, 'Customer Mobile', customer?.mobileNumber ?? '—'),
          _infoRow(kh, 'Request Type', request?.requestType ?? '—'),
          _infoRow(kh, 'Indicative Budget', request?.indicativeValue != null ? _formatPrice(request!.indicativeValue!) : '—'),
          if (request?.purityKarat != null)
            _infoRow(kh, 'Purity / Karat', request!.purityKarat!),
          if (request?.weightGrams != null)
            _infoRow(kh, 'Weight', '${request!.weightGrams} grams'),
          if (request?.ornamentType != null)
            _infoRow(kh, 'Ornament Type', request!.ornamentType!),
          if (request?.description != null && request!.description!.isNotEmpty) ...[
            SizedBox(height: kh.spacing.xs),
            const KhSectionLabel('DESCRIPTION / NOTES'),
            SizedBox(height: kh.spacing.xxs),
            Text(
              request.description!,
              style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAcceptedOfferCard(dynamic kh, ConnectionDetail detail) {
    final offer = detail.offer;
    final vendor = detail.vendor;

    return Container(
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
              Icon(Icons.verified_outlined, color: kh.colors.goldPrimary, size: 20),
              SizedBox(width: kh.spacing.xs),
              Text('Accepted Offer Terms', style: kh.typography.title),
              if (offer?.reference != null) ...[
                const Spacer(),
                Text(
                  offer!.reference!,
                  style: kh.typography.bodySmall.copyWith(color: kh.colors.goldPrimary),
                ),
              ],
            ],
          ),
          Divider(color: kh.colors.borderSubtle, height: kh.spacing.lg * 2),
          _infoRow(kh, 'Vendor Legal Name', vendor?.legalBusinessName ?? '—'),
          if (vendor?.tradingName != null && vendor!.tradingName!.isNotEmpty)
            _infoRow(kh, 'Trading Name', vendor.tradingName!),
          _infoRow(kh, 'Vendor Email', vendor?.email ?? '—'),
          _infoRow(kh, 'Vendor Mobile', vendor?.mobileNumber ?? '—'),
          if (vendor?.tradeLicenceNumber != null)
            _infoRow(kh, 'Trade Licence', vendor!.tradeLicenceNumber!),
          if (vendor?.rating != null)
            _infoRow(kh, 'Aggregate Rating', '★ ${vendor!.rating!.toStringAsFixed(1)}'),
          Divider(color: kh.colors.borderSubtle, height: kh.spacing.md * 2),
          _infoRow(
            kh,
            'Agreed Price',
            offer != null ? _formatPrice(offer.agreedPriceAed) : '—',
            isHighlighted: true,
          ),
          if (offer?.makingCharges != null)
            _infoRow(kh, 'Making Charges', _formatPrice(offer!.makingCharges!)),
          if (offer?.ratePerGram != null)
            _infoRow(kh, 'Rate Per Gram', _formatPrice(offer!.ratePerGram!)),
          if (offer?.validityHours != null)
            _infoRow(kh, 'Offer Validity', '${offer!.validityHours} hours'),
          if (offer?.deliveryTimeframe != null)
            _infoRow(kh, 'Delivery Timeframe', offer!.deliveryTimeframe!),
          if (offer?.warrantyTerms != null)
            _infoRow(kh, 'Warranty Terms', offer!.warrantyTerms!),
          if (offer?.vendorNote != null && offer!.vendorNote!.isNotEmpty) ...[
            SizedBox(height: kh.spacing.xs),
            const KhSectionLabel('VENDOR NOTE'),
            SizedBox(height: kh.spacing.xxs),
            Text(
              offer.vendorNote!,
              style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactEventsCard(dynamic kh, ConnectionDetail detail) {
    return Container(
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
              Icon(Icons.chat_bubble_outline, color: kh.colors.goldPrimary, size: 20),
              SizedBox(width: kh.spacing.xs),
              Text('Contact Initiation Events', style: kh.typography.title),
            ],
          ),
          SizedBox(height: kh.spacing.xs),
          Text(
            'WhatsApp outbound clicks recorded by platform Talk action. '
            'Conversation content is never available or stored off-platform.',
            style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
          ),
          Divider(color: kh.colors.borderSubtle, height: kh.spacing.lg * 2),
          if (detail.contactEvents.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Center(
                child: Text(
                  'No off-platform contact events recorded yet.',
                  style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detail.contactEvents.length,
              separatorBuilder: (_, __) => Divider(color: kh.colors.borderSubtle),
              itemBuilder: (context, index) {
                final event = detail.contactEvents[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: kh.spacing.xs),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kh.colors.success.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.phone_in_talk,
                          size: 16,
                          color: kh.colors.success,
                        ),
                      ),
                      SizedBox(width: kh.spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Initiated via ${event.channel} by ${event.initiatedBy}',
                              style: kh.typography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: kh.colors.textPrimary,
                              ),
                            ),
                            Text(
                              _formatDate(event.occurredAt),
                              style: kh.typography.caption.copyWith(
                                color: kh.colors.textSecondary,
                              ),
                            ),
                          ],
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

  Widget _buildLifecycleActionsCard(
    BuildContext context,
    dynamic kh,
    ConnectionDetail detail,
  ) {
    final isClosed = detail.state == ConnectionState.closed;

    return Container(
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
              Icon(Icons.shield_outlined, color: kh.colors.goldPrimary, size: 20),
              SizedBox(width: kh.spacing.xs),
              Text('Lifecycle Management', style: kh.typography.title),
            ],
          ),
          Divider(color: kh.colors.borderSubtle, height: kh.spacing.lg * 2),
          if (isClosed) ...[
            Container(
              padding: EdgeInsets.all(kh.spacing.md),
              decoration: BoxDecoration(
                color: kh.colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kh.colors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outline, color: kh.colors.error, size: 18),
                      SizedBox(width: kh.spacing.xs),
                      Text(
                        'Connection Closed',
                        style: kh.typography.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: kh.colors.error,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: kh.spacing.xs),
                  Text(
                    'Closed on ${_formatDate(detail.closedAt)}${detail.closedBy != null ? " by ${detail.closedBy}" : ""}.',
                    style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'If the introduction has failed, unfulfilled commitments were made, or an abusive interaction was reported, administrators may terminate the connection.',
              style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
            ),
            SizedBox(height: kh.spacing.md),
            FilledButton.icon(
              key: const Key('close-connection-button'),
              style: FilledButton.styleFrom(
                backgroundColor: kh.colors.error,
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () => _showCloseConnectionModal(context),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Close Connection'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdminNotesCard(dynamic kh, ConnectionDetail detail) {
    return Container(
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
              Icon(Icons.note_alt_outlined, color: kh.colors.goldPrimary, size: 20),
              SizedBox(width: kh.spacing.xs),
              Text('Internal Admin Notes', style: kh.typography.title),
            ],
          ),
          SizedBox(height: kh.spacing.xxs),
          Text(
            'Private notes visible only to platform administrators.',
            style: kh.typography.caption.copyWith(color: kh.colors.textMuted),
          ),
          Divider(color: kh.colors.borderSubtle, height: kh.spacing.lg * 2),
          if (detail.adminNotes.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Center(
                child: Text(
                  'No internal notes recorded yet.',
                  style: kh.typography.bodySmall.copyWith(color: kh.colors.textSecondary),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detail.adminNotes.length,
              separatorBuilder: (_, __) => Divider(color: kh.colors.borderSubtle),
              itemBuilder: (context, index) {
                final note = detail.adminNotes[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: kh.spacing.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            note.author,
                            style: kh.typography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: kh.colors.goldPrimary,
                            ),
                          ),
                          Text(
                            _formatDate(note.createdAt),
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: kh.spacing.xxs),
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
          Divider(color: kh.colors.borderSubtle, height: kh.spacing.lg * 2),
          TextField(
            key: const Key('add-note-input'),
            controller: _noteController,
            maxLines: 2,
            enabled: !_isPostingNote,
            decoration: const InputDecoration(
              labelText: 'Add Internal Note',
              hintText: 'Record findings, SLA status checks, customer feedback…',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          SizedBox(height: kh.spacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              key: const Key('add-note-button'),
              onPressed: _isPostingNote ? null : _handlePostNote,
              icon: _isPostingNote
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, size: 14),
              label: const Text('Add Note'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    dynamic kh,
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: kh.spacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: kh.typography.bodySmall.copyWith(
                color: isHighlighted ? kh.colors.goldPrimary : kh.colors.textPrimary,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailErrorState extends StatelessWidget {
  const _DetailErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: kh.colors.error),
            SizedBox(height: kh.spacing.sm),
            Text(
              message,
              style: kh.typography.body.copyWith(color: kh.colors.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: kh.spacing.md),
            FilledButton.icon(
              key: const Key('connection-detail-error-retry'),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
