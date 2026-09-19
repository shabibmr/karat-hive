import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../repository/reviews_repository.dart';

/// CUS-S18 — Customer leave feedback for Vendor on closed connection (`FR-CUS-029`, `FR-CUS-030`, `BR-016`, `BR-017`).
class LeaveReviewScreen extends StatelessWidget {
  const LeaveReviewScreen({
    super.key,
    required this.connectionId,
    this.vendorLabel,
  });

  final String connectionId;
  final String? vendorLabel;

  @override
  Widget build(BuildContext context) {
    return _LeaveReviewBaseScreen(
      connectionId: connectionId,
      partyLabel: vendorLabel,
      isVendorReviewingCustomer: false,
    );
  }
}

/// VEN-S19 — Vendor leave feedback for Customer on closed connection (`FR-VEN-029`, `BR-016`, `BR-017`).
///
/// Implements CP5-B03.3:
/// - Star rating (1–5 mandatory) via [StarRatingInput] (SH-ID-04)
/// - Comment ≤ 1000 chars via [ReviewCommentField] (SH-ID-05)
/// - Connection context
/// - Already-reviewed handling (`REVIEW_ALREADY_EXISTS` / `BR-017`)
/// - Moderation confirmation state
class VendorLeaveReviewScreen extends StatelessWidget {
  const VendorLeaveReviewScreen({
    super.key,
    required this.connectionId,
    this.customerLabel,
  });

  final String connectionId;
  final String? customerLabel;

  @override
  Widget build(BuildContext context) {
    return _LeaveReviewBaseScreen(
      connectionId: connectionId,
      partyLabel: customerLabel,
      isVendorReviewingCustomer: true,
    );
  }
}

class _LeaveReviewBaseScreen extends ConsumerStatefulWidget {
  const _LeaveReviewBaseScreen({
    required this.connectionId,
    required this.partyLabel,
    required this.isVendorReviewingCustomer,
  });

  final String connectionId;
  final String? partyLabel;
  final bool isVendorReviewingCustomer;

  @override
  ConsumerState<_LeaveReviewBaseScreen> createState() =>
      _LeaveReviewBaseScreenState();
}

class _LeaveReviewBaseScreenState extends ConsumerState<_LeaveReviewBaseScreen> {
  int? _rating = 5;
  final _commentController = TextEditingController();
  bool _busy = false;
  bool _alreadyReviewed = false;
  bool _submitted = false;
  String? _errorMessage;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final rating = _rating;
    if (rating == null || rating < 1 || rating > 5) {
      setState(() => _errorMessage = 'Please select a star rating (1–5).');
      return;
    }

    final comment = _commentController.text.trim();
    if (comment.length > ReviewCommentField.maxLength) {
      setState(() => _errorMessage =
          'Comment exceeds ${ReviewCommentField.maxLength} characters.');
      return;
    }

    setState(() {
      _busy = true;
      _errorMessage = null;
    });

    final res = await ref.read(reviewsRepositoryProvider).create(
          connectionId: widget.connectionId,
          rating: rating,
          comment: comment.isEmpty ? null : comment,
        );

    if (!mounted) return;

    res.when(
      ok: (_) {
        setState(() {
          _busy = false;
          _submitted = true;
        });
      },
      err: (failure) {
        final code = failure.code;
        final isAlready = code == 'REVIEW_ALREADY_EXISTS' ||
            (failure.message?.contains('already exists') ?? false);
        final defaultFallback = widget.isVendorReviewingCustomer
            ? 'Could not submit feedback.'
            : 'Could not submit your review.';
        setState(() {
          _busy = false;
          if (isAlready) {
            _alreadyReviewed = true;
          } else {
            _errorMessage = failure.message ?? defaultFallback;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final isVendor = widget.isVendorReviewingCustomer;

    if (_alreadyReviewed) {
      return KhScaffold(
        title: isVendor ? 'Feedback' : 'Review',
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(tokens.space.lg),
            child: Card(
              key: const Key('leave-review-already-reviewed'),
              child: Padding(
                padding: EdgeInsets.all(tokens.space.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 48, color: tokens.gold),
                    SizedBox(height: tokens.space.md),
                    Text(
                      isVendor
                          ? 'Feedback Already Submitted'
                          : 'Review Already Submitted',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.space.sm),
                    Text(
                      'You have already submitted a review for this connection. Under BR-017, only one review per party per connection is permitted.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.ink.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: tokens.space.lg),
                    KhButton(
                      label: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_submitted) {
      return KhScaffold(
        title: isVendor ? 'Feedback Submitted' : 'Review Submitted',
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(tokens.space.lg),
            child: Card(
              key: const Key('leave-review-submitted'),
              child: Padding(
                padding: EdgeInsets.all(tokens.space.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.hourglass_top_rounded,
                        size: 48, color: tokens.gold),
                    SizedBox(height: tokens.space.md),
                    Text(
                      'Held for Moderation',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.space.sm),
                    Text(
                      isVendor
                          ? 'Thank you for rating your transaction experience. Your review is held for admin approval before publishing.'
                          : 'Thank you for rating your Vendor. Your review is held for admin approval before publishing.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: tokens.ink.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: tokens.space.lg),
                    KhButton(
                      label: 'Done',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final screenKey =
        isVendor ? 'leave-review-screen' : 'leave-review-screen-customer';
    final partyHeading =
        widget.partyLabel ?? (isVendor ? 'Customer' : 'Vendor');
    final ratingLabel =
        isVendor ? 'Transaction Rating (1–5)' : 'Vendor Rating (1–5)';
    final commentLabel =
        isVendor ? 'Customer Feedback (Optional)' : 'Comment (Optional)';
    final submitButtonLabel = isVendor ? 'Submit Feedback' : 'Submit Review';

    return KhScaffold(
      title: isVendor ? 'Rate Transaction' : 'Rate Vendor',
      body: SingleChildScrollView(
        key: Key(screenKey),
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(tokens.space.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Party',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: tokens.ink.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: tokens.space.xs),
                    Text(
                      partyHeading,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: tokens.space.xs),
                    Text(
                      'Connection ID: ${widget.connectionId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: tokens.ink.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: tokens.space.md),
            Card(
              child: Padding(
                padding: EdgeInsets.all(tokens.space.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StarRatingInput(
                      value: _rating,
                      label: ratingLabel,
                      onChanged: (val) => setState(() => _rating = val),
                    ),
                    SizedBox(height: tokens.space.md),
                    ReviewCommentField(
                      controller: _commentController,
                      label: commentLabel,
                      helperText:
                          'Max 1000 characters. Visible after admin approval.',
                    ),
                  ],
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: tokens.space.sm),
              KhInlineError(message: _errorMessage!),
            ],
            SizedBox(height: tokens.space.lg),
            KhButton(
              key: const Key('leave-review-submit-button'),
              label: submitButtonLabel,
              busy: _busy,
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
