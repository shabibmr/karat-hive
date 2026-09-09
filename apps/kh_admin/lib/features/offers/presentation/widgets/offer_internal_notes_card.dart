import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/offers/model/offer_detail.dart';
import 'package:kh_admin/features/offers/presentation/widgets/offer_detail_formatters.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Internal administrative notes card. Was `_InternalNotesCard`.
class OfferInternalNotesCard extends StatelessWidget {
  const OfferInternalNotesCard({
    super.key,
    required this.notes,
    required this.controller,
    required this.isPosting,
    required this.onPost,
  });

  final List<OfferInternalNoteItem> notes;
  final TextEditingController controller;
  final bool isPosting;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      padding: EdgeInsets.all(kh.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.offersDetailNotesTitle ?? 'Internal Administrative Notes',
            style: kh.typography.title.copyWith(
              color: kh.colors.textPrimary,
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: kh.spacing.xxs),
          Text(
            l10n?.offersDetailNotesSubtitle ??
                'Admin inspection notes are internal to Karat Hive. Commercial terms are read-only.',
            style: kh.typography.caption.copyWith(
              color: kh.colors.textMuted,
              fontSize: 11.0,
            ),
          ),
          SizedBox(height: kh.spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('offer-internal-note-input'),
                  controller: controller,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: l10n?.offersDetailNotesHint ??
                        'Add an internal note about this offer…',
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(width: kh.spacing.md),
              ElevatedButton.icon(
                key: const Key('offer-add-note-button'),
                onPressed: isPosting ? null : onPost,
                icon: isPosting
                    ? const SizedBox(
                        width: 14.0,
                        height: 14.0,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      )
                    : const Icon(Icons.add_comment_outlined, size: 16.0),
                label: Text(
                  l10n?.offersDetailAddNote ?? 'Add Note',
                  style: const TextStyle(fontSize: 12.0),
                ),
              ),
            ],
          ),
          SizedBox(height: kh.spacing.lg),
          if (notes.isEmpty)
            Text(
              l10n?.offersDetailNoNotes ?? 'No internal notes added yet.',
              style: kh.typography.bodySmall.copyWith(
                color: kh.colors.textMuted,
                fontSize: 13.0,
              ),
            )
          else
            Column(
              children: [
                for (final note in notes)
                  Container(
                    margin: EdgeInsets.only(bottom: kh.spacing.xs),
                    padding: EdgeInsets.all(kh.spacing.sm),
                    decoration: BoxDecoration(
                      color: kh.colors.backgroundSurface,
                      borderRadius: kh.shapes.roundedSm,
                      border: Border.all(color: kh.colors.borderSubtle),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 16.0,
                          color: kh.colors.goldPrimary,
                        ),
                        SizedBox(width: kh.spacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    note.author,
                                    style: kh.typography.caption.copyWith(
                                      color: kh.colors.goldPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11.0,
                                    ),
                                  ),
                                  Text(
                                    offerFormatDate(note.createdAt),
                                    style: kh.typography.caption.copyWith(
                                      color: kh.colors.textMuted,
                                      fontSize: 10.0,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: kh.spacing.xxs),
                              Text(
                                note.text,
                                style: kh.typography.bodySmall.copyWith(
                                  color: kh.colors.textPrimary,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
