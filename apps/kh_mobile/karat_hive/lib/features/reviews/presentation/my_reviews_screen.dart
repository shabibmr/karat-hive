import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../profile_settings/controller/business_profile_controller.dart';
import '../controller/my_reviews_controller.dart';
import '../controller/review_actions_controller.dart';

/// VEN-S20 — My reviews & responses (`FR-VEN-029`).
///
/// Implements:
/// - CP5-B04.1: Aggregate rating header to 1 dp, count, "New — limited history" if < 3
/// - Star distribution bars (via [RatingSummaryView] / SH-ID-03)
/// - CP5-B04.3: Review list via [ReviewListItem] (SH-ID-06) + response input ≤ 500 chars
/// - CP5-B04.4: Flag as unfair (re-enters Admin queue; review stays visible)
class MyReviewsScreen extends ConsumerStatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  ConsumerState<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends ConsumerState<MyReviewsScreen> {
  final Set<String> _flaggedReviewIds = <String>{};

  Future<void> _openResponseDialog(Review review) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _ResponseDialog(review: review),
    );
  }

  Future<void> _handleFlag(Review review) async {
    final confirmed = await showKhConfirmDialog(
      context,
      title: 'Flag Review as Unfair',
      body:
          'Flagging will re-enter this review into the Admin moderation queue for secondary evaluation.\n\nPer policy, the review remains visible until an Admin takes action.',
      confirmLabel: 'Flag for Review',
      cancelLabel: 'Cancel',
      destructive: false,
    );

    if (confirmed != true) return;

    final res = await ref
        .read(reviewActionsControllerProvider.notifier)
        .flag(review.id);

    if (!mounted) return;

    res.when(
      ok: (_) {
        setState(() {
          _flaggedReviewIds.add(review.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review flagged for moderation.'),
          ),
        );
        ref.read(myReviewsControllerProvider).refresh();
      },
      err: (f) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(f.message ?? 'Could not flag review.'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final vendorAsync = ref.watch(vendorProfileProvider);
    final paged = ref.watch(myReviewsControllerProvider);
    final perfAsync = ref.watch(reviewsPerformanceProvider);

    return KhScaffold(
      title: 'My reviews',
      onRefresh: () async {
        ref.invalidate(vendorProfileProvider);
        ref.invalidate(reviewsPerformanceProvider);
        await paged.refresh();
      },
      body: ListenableBuilder(
        listenable: paged,
        builder: (context, _) {
          return SingleChildScrollView(
            key: const Key('my-reviews-screen'),
            padding: EdgeInsets.all(tokens.space.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header description
                Text(
                  'Customer Reviews & Ratings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.space.xs),
                Text(
                  'Public ratings visible on your offer cards.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.ink.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: tokens.space.md),

                // CP5-B04.1: Aggregate Rating Header
                vendorAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (vendor) {
                    final rating = vendor.rating ??
                        const RatingSummary(
                          average: 0,
                          count: 0,
                          limitedHistory: true,
                        );
                    return Card(
                      key: const Key('my-reviews-aggregate-header'),
                      child: Padding(
                        padding: EdgeInsets.all(tokens.space.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RatingSummaryView(
                              summary: rating,
                              showDistribution: rating.count > 0,
                            ),
                            if (vendor.connectionCount > 0) ...[
                              SizedBox(height: tokens.space.sm),
                              Text(
                                '${vendor.connectionCount} total transactions completed',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: tokens.ink.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // CP5-B04.2: Rating History & Trends (when data is present)
                perfAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (perf) {
                    if (perf == null || perf.ratingTrend.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    final points = perf.ratingTrend
                        .map((p) => RatingTrendPoint(
                              period: p.period,
                              average: p.average,
                              count: p.count,
                            ))
                        .toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: tokens.space.lg),
                        const KhSectionHeader(
                          title: 'Rating History & Trends',
                        ),
                        SizedBox(height: tokens.space.sm),
                        Card(
                          key: const Key('my-reviews-trend-card'),
                          child: Padding(
                            padding: EdgeInsets.all(tokens.space.md),
                            child: RatingTrendChart(
                              points: points,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: tokens.space.lg),

                // Review list section
                KhSectionHeader(
                  title: 'Published Customer Feedback (${paged.value.items.length})',
                ),
                SizedBox(height: tokens.space.sm),

                if (paged.value.isLoading && paged.value.items.isEmpty) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else if (paged.value.items.isEmpty) ...[
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(tokens.space.xl),
                      child: Center(
                        child: Text(
                          'No customer reviews yet.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: tokens.ink.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  for (final review in paged.value.items) ...[
                    Builder(
                      builder: (context) {
                        final isFlagged = _flaggedReviewIds.contains(review.id) ||
                            review.state == ReviewState.pendingModeration;
                        return Card(
                          key: Key('review-card-${review.id}'),
                          child: Padding(
                            padding: EdgeInsets.all(tokens.space.sm),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ReviewListItem.fromReview(
                                  review,
                                  dateLabel: _formatDate(
                                      review.publishedAt ?? review.createdAt),
                                ),
                                if (review.vendorResponse != null) ...[
                                  SizedBox(height: tokens.space.sm),
                                  Container(
                                    padding: EdgeInsets.all(tokens.space.sm),
                                    decoration: BoxDecoration(
                                      color: tokens.ink.withValues(alpha: 0.04),
                                      borderRadius:
                                          BorderRadius.circular(tokens.radius.sm),
                                      border: BorderDirectional(
                                        start: BorderSide(
                                            color: tokens.gold, width: 3),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Your Public Response',
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: tokens.gold,
                                          ),
                                        ),
                                        SizedBox(height: tokens.space.xs),
                                        Text(
                                          review.vendorResponse!.text,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (isFlagged) ...[
                                  SizedBox(height: tokens.space.xs),
                                  Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Chip(
                                      key: Key('flagged-badge-${review.id}'),
                                      avatar: const Icon(Icons.flag_outlined,
                                          size: 14),
                                      label:
                                          const Text('Flagged for moderation'),
                                    ),
                                  ),
                                ],
                                if (review.vendorResponse == null || !isFlagged)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (review.vendorResponse == null) ...[
                                        TextButton.icon(
                                          key: Key('respond-button-${review.id}'),
                                          icon: const Icon(Icons.reply, size: 16),
                                          label: const Text('Respond'),
                                          onPressed: () =>
                                              _openResponseDialog(review),
                                        ),
                                        SizedBox(width: tokens.space.xs),
                                      ],
                                      if (!isFlagged)
                                        TextButton.icon(
                                          key: Key('flag-button-${review.id}'),
                                          icon: const Icon(Icons.flag_outlined,
                                              size: 16),
                                          label: const Text('Flag as unfair'),
                                          onPressed: () => _handleFlag(review),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: tokens.space.sm),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
  }

  String _monthName(int month) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][(month - 1).clamp(0, 11)];
}

class _ResponseDialog extends ConsumerStatefulWidget {
  const _ResponseDialog({required this.review});

  final Review review;

  @override
  ConsumerState<_ResponseDialog> createState() => _ResponseDialogState();
}

class _ResponseDialogState extends ConsumerState<_ResponseDialog> {
  late final TextEditingController _controller;
  String? _dialogError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _dialogError = 'Response cannot be empty.');
      return;
    }
    if (_controller.text.length > 500 || text.length > 500) {
      setState(() => _dialogError = 'Maximum 500 characters.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _dialogError = null;
    });

    final res = await ref
        .read(reviewActionsControllerProvider.notifier)
        .respond(id: widget.review.id, response: text);

    if (!mounted) return;

    res.when(
      ok: (_) {
        Navigator.of(context).pop();
        ref.read(myReviewsControllerProvider).refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Response submitted. Held for moderation.'),
          ),
        );
      },
      err: (f) {
        setState(() {
          _isSubmitting = false;
          final code = (f.code ?? '').toUpperCase();
          if (f is ConflictFailure ||
              code == 'REVIEW_RESPONSE_EXISTS' ||
              code == 'CONFLICT' ||
              code.contains('EXISTS') ||
              code.contains('CONFLICT')) {
            _dialogError = 'Only one public response is permitted per review.';
          } else {
            _dialogError = f.message ?? 'Failed to submit response.';
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Respond to Review'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Your public response will be held for admin moderation before appearing under the review (max 500 characters). Only one response allowed per review.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            KhTextField(
              key: const Key('vendor-response-input'),
              controller: _controller,
              label: 'Your Response',
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 4),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final count = _controller.text.length;
                final isOverLimit = count > 500;
                return Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    '$count / 500',
                    key: const Key('response-character-counter'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isOverLimit
                              ? Theme.of(context).colorScheme.error
                              : null,
                          fontWeight: isOverLimit ? FontWeight.bold : null,
                        ),
                  ),
                );
              },
            ),
            if (_dialogError != null) ...[
              const SizedBox(height: 8),
              KhInlineError(message: _dialogError!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        KhButton(
          key: const Key('submit-response-button'),
          label: 'Submit',
          busy: _isSubmitting,
          onPressed: _isSubmitting ? null : _submit,
        ),
      ],
    );
  }
}

