import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

/// SH-ID-06 — Review list item (abbreviated author, stars, text, date).
///
/// Used on ratings sheets (`ReviewExcerpt`), VEN-S20, and Admin moderation.
/// Author abbreviation (e.g. "Ahmed K.") and date formatting are owned by the
/// caller / API (`FR-CUS-031`); this widget renders what it is given.
class ReviewListItem extends StatelessWidget {
  const ReviewListItem({
    super.key,
    required this.abbreviatedAuthor,
    required this.rating,
    required this.dateLabel,
    this.comment,
    this.contextLabel,
    this.onTap,
  }) : assert(rating >= 1 && rating <= 5);

  /// Abbreviated reviewer name already prepared by the API (e.g. "Fatima M.").
  final String abbreviatedAuthor;

  /// Integer stars 1–5.
  final int rating;

  /// Pre-formatted date string (callers own l10n / GST display).
  final String dateLabel;

  /// Optional free-text comment; omitted when null/blank.
  final String? comment;

  /// Optional secondary context (e.g. request title) shown after the date.
  final String? contextLabel;

  final VoidCallback? onTap;

  /// Convenience for published [Review] rows (VEN-S20 / Admin).
  factory ReviewListItem.fromReview(
    Review review, {
    Key? key,
    required String dateLabel,
    String? contextLabel,
    String? abbreviatedAuthor,
    VoidCallback? onTap,
  }) {
    final author = (abbreviatedAuthor ?? review.authorDisplayName ?? '').trim();
    final stars = review.rating < 1
        ? 1
        : (review.rating > 5 ? 5 : review.rating);
    return ReviewListItem(
      key: key,
      abbreviatedAuthor: author.isEmpty ? '—' : author,
      rating: stars,
      dateLabel: dateLabel,
      comment: review.comment,
      contextLabel: contextLabel,
      onTap: onTap,
    );
  }

  /// Convenience for pre-accept rating-sheet excerpts (`FR-CUS-031`).
  factory ReviewListItem.fromExcerpt(
    ReviewExcerpt excerpt, {
    Key? key,
    String dateLabel = '',
    String? contextLabel,
    VoidCallback? onTap,
  }) {
    final author = excerpt.abbreviatedName.trim();
    final stars = excerpt.rating < 1
        ? 1
        : (excerpt.rating > 5 ? 5 : excerpt.rating);
    return ReviewListItem(
      key: key,
      abbreviatedAuthor: author.isEmpty ? '—' : author,
      rating: stars,
      dateLabel: dateLabel,
      comment: excerpt.comment,
      contextLabel: contextLabel,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final hasComment = comment != null && comment!.trim().isNotEmpty;
    final hasContext = contextLabel != null && contextLabel!.trim().isNotEmpty;
    final hasDate = dateLabel.trim().isNotEmpty;
    final meta = [
      if (hasDate) dateLabel.trim(),
      if (hasContext) contextLabel!.trim(),
    ].join(' · ');

    return Card(
      key: const Key('review-list-item'),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      abbreviatedAuthor,
                      key: const Key('review-list-item-author'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: tokens.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: tokens.space.sm),
                  _ReviewStars(
                    key: const Key('review-list-item-stars'),
                    rating: rating,
                    color: tokens.gold,
                  ),
                ],
              ),
              if (meta.isNotEmpty) ...[
                SizedBox(height: tokens.space.xs),
                Text(
                  meta,
                  key: const Key('review-list-item-date'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.ink.withValues(alpha: 0.65),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (hasComment) ...[
                SizedBox(height: tokens.space.sm),
                Text(
                  comment!.trim(),
                  key: const Key('review-list-item-comment'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: tokens.ink.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewStars extends StatelessWidget {
  const _ReviewStars({super.key, required this.rating, required this.color});

  final int rating;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 16,
            color: color,
          ),
      ],
    );
  }
}
