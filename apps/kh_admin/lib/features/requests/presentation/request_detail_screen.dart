import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_feedback_banner.dart';
import 'package:kh_admin/features/requests/controller/request_detail_controller.dart';
import 'package:kh_admin/features/requests/model/request_detail.dart';
import 'package:kh_admin/features/requests/presentation/widgets/request_customer_card.dart';
import 'package:kh_admin/features/requests/presentation/widgets/request_detail_header.dart';
import 'package:kh_admin/features/requests/presentation/widgets/request_internal_notes_card.dart';
import 'package:kh_admin/features/requests/presentation/widgets/request_matched_vendors_card.dart';
import 'package:kh_admin/features/requests/presentation/widgets/request_media_gallery_card.dart';
import 'package:kh_admin/features/requests/presentation/widgets/request_moderation_card.dart';
import 'package:kh_admin/features/requests/presentation/widgets/request_offers_card.dart';
import 'package:kh_admin/features/requests/presentation/widgets/request_specifications_card.dart';
import 'package:kh_admin/features/requests/presentation/widgets/request_timeline_card.dart';
import 'package:kh_admin/features/requests/presentation/widgets/remove_request_dialog.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// ADM-S09 · Request detail — full request oversight, matched vendors, offers,
/// unmasked customer, state timeline, connection status, internal notes, and
/// administrative removal action.
///
/// Composition root only: each section lives in `presentation/widgets/`
/// (TR-S2-06). Screen state owns the note field and action feedback.
class RequestDetailScreen extends ConsumerStatefulWidget {
  const RequestDetailScreen({
    super.key,
    required this.requestId,
  });

  final String requestId;

  @override
  ConsumerState<RequestDetailScreen> createState() =>
      _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  final _noteController = TextEditingController();
  bool _isSubmittingNote = false;
  String? _actionFeedback;
  bool _actionSuccess = true;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  RequestDetailController get _controller =>
      ref.read(requestDetailControllerProvider(widget.requestId).notifier);

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final detailAsync =
        ref.watch(requestDetailControllerProvider(widget.requestId));

    return Material(
      color: kh.colors.backgroundSurface,
      child: detailAsync.when(
        loading: () => const Center(
          key: Key('request-detail-loading'),
          child: Padding(
            padding: EdgeInsets.all(48.0),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, _) => SingleChildScrollView(
          padding: EdgeInsets.all(kh.spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RequestDetailBackButton(),
              SizedBox(height: kh.spacing.lg),
              RequestDetailErrorView(
                message: err.toString(),
                onRetry: _controller.reload,
              ),
            ],
          ),
        ),
        data: (detail) => SingleChildScrollView(
          padding: EdgeInsets.all(kh.spacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RequestDetailBackButton(),
              SizedBox(height: kh.spacing.md),
              RequestDetailHeader(detail: detail),
              if (_actionFeedback != null) ...[
                SizedBox(height: kh.spacing.md),
                KhFeedbackBanner(
                  key: const Key('request-feedback-banner'),
                  message: _actionFeedback!,
                  isSuccess: _actionSuccess,
                  onDismiss: () => setState(() => _actionFeedback = null),
                ),
              ],
              if (detail.isRemoved) ...[
                SizedBox(height: kh.spacing.md),
                RequestRemovedNoticeBanner(detail: detail),
              ],
              if (detail.isAccepted && detail.connection != null) ...[
                SizedBox(height: kh.spacing.md),
                RequestConnectionBanner(connection: detail.connection!),
              ],
              SizedBox(height: kh.spacing.xl),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 1080;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              RequestSpecificationsCard(detail: detail),
                              SizedBox(height: kh.spacing.lg),
                              RequestMediaGalleryCard(detail: detail),
                              SizedBox(height: kh.spacing.lg),
                              RequestOffersCard(detail: detail),
                              SizedBox(height: kh.spacing.lg),
                              RequestTimelineCard(detail: detail),
                            ],
                          ),
                        ),
                        SizedBox(width: kh.spacing.lg),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              RequestCustomerCard(detail: detail),
                              SizedBox(height: kh.spacing.lg),
                              RequestMatchedVendorsCard(detail: detail),
                              SizedBox(height: kh.spacing.lg),
                              RequestModerationCard(
                                detail: detail,
                                onRemove: () => _handleRemove(detail),
                              ),
                              SizedBox(height: kh.spacing.lg),
                              RequestInternalNotesCard(
                                detail: detail,
                                noteController: _noteController,
                                isSubmitting: _isSubmittingNote,
                                onSubmit: _handleAddNote,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RequestCustomerCard(detail: detail),
                      SizedBox(height: kh.spacing.lg),
                      RequestSpecificationsCard(detail: detail),
                      SizedBox(height: kh.spacing.lg),
                      RequestMediaGalleryCard(detail: detail),
                      SizedBox(height: kh.spacing.lg),
                      RequestOffersCard(detail: detail),
                      SizedBox(height: kh.spacing.lg),
                      RequestMatchedVendorsCard(detail: detail),
                      SizedBox(height: kh.spacing.lg),
                      RequestTimelineCard(detail: detail),
                      SizedBox(height: kh.spacing.lg),
                      RequestModerationCard(
                        detail: detail,
                        onRemove: () => _handleRemove(detail),
                      ),
                      SizedBox(height: kh.spacing.lg),
                      RequestInternalNotesCard(
                        detail: detail,
                        noteController: _noteController,
                        isSubmitting: _isSubmittingNote,
                        onSubmit: _handleAddNote,
                      ),
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

  Future<void> _handleAddNote() async {
    final l10n = AppLocalizations.of(context);
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmittingNote = true);
    try {
      await _controller.addNote(text: text);
      _noteController.clear();
      setState(() {
        _actionSuccess = true;
        _actionFeedback =
            l10n?.requestsDetailNoteAdded ?? 'Note added successfully.';
      });
    } on Object catch (e) {
      setState(() {
        _actionSuccess = false;
        _actionFeedback = l10n?.requestsDetailNoteAddFailed(e.toString()) ??
            'Failed to add note: $e';
      });
    } finally {
      if (mounted) setState(() => _isSubmittingNote = false);
    }
  }

  Future<void> _handleRemove(RequestDetail detail) async {
    final l10n = AppLocalizations.of(context);
    final outcome = await showRemoveRequestDialog(context, detail);
    if (outcome == null || !mounted) return;

    try {
      await _controller.removeRequest(
        reasonCode: outcome.reasonCode,
        reasonText: outcome.reasonText,
        policyClause: outcome.policyClause,
      );
      setState(() {
        _actionSuccess = true;
        _actionFeedback =
            l10n?.requestsDetailRemoveSuccess ?? 'Request successfully removed.';
      });
    } on Object catch (e) {
      setState(() {
        _actionSuccess = false;
        _actionFeedback = l10n?.requestsDetailRemoveFailed(e.toString()) ??
            'Failed to remove request: $e';
      });
    }
  }
}
