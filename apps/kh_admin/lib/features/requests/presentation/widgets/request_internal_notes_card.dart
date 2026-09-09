import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/core/format/kh_formats.dart';
import 'package:kh_admin/features/requests/model/request_detail.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// Admin internal notes list + add-note form. Was `_buildInternalNotesCard`.
///
/// The note field's controller and submit wiring stay owned by the screen
/// state; this widget renders them.
class RequestInternalNotesCard extends StatelessWidget {
  const RequestInternalNotesCard({
    super.key,
    required this.detail,
    required this.noteController,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final RequestDetail detail;
  final TextEditingController noteController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final dateFormat = khDateTimeFormat;

    return Container(
      padding: EdgeInsets.all(kh.spacing.lg),
      decoration: BoxDecoration(
        color: kh.colors.backgroundElevated,
        borderRadius: kh.shapes.roundedLg,
        border: Border.all(color: kh.colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KhSectionLabel(
              l10n?.requestsDetailNotesTitle(detail.internalNotes.length) ??
                  'Admin Internal Notes (${detail.internalNotes.length})'),
          SizedBox(height: kh.spacing.md),
          if (detail.internalNotes.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detail.internalNotes.length,
              separatorBuilder: (_, __) => Divider(
                color: kh.colors.borderSubtle,
                height: kh.spacing.md,
              ),
              itemBuilder: (context, index) {
                final note = detail.internalNotes[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          note.authorName,
                          style: kh.typography.caption.copyWith(
                            color: kh.colors.goldPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.0,
                          ),
                        ),
                        Text(
                          dateFormat.format(note.createdAt),
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
                );
              },
            )
          else
            Padding(
              padding: EdgeInsets.only(bottom: kh.spacing.md),
              child: Text(
                l10n?.requestsDetailNoNotes ?? 'No internal notes recorded.',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textMuted,
                  fontSize: 12.0,
                ),
              ),
            ),
          SizedBox(height: kh.spacing.sm),
          TextField(
            key: const Key('add-note-field'),
            controller: noteController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n?.requestsDetailAddNoteLabel ?? 'Add Internal Note',
              hintText: l10n?.requestsDetailAddNoteHint ??
                  'Record audit or compliance notes…',
              isDense: true,
            ),
          ),
          SizedBox(height: kh.spacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton(
              key: const Key('submit-note-button'),
              onPressed: isSubmitting ? null : onSubmit,
              child: isSubmitting
                  ? const SizedBox(
                      width: 14.0,
                      height: 14.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0),
                    )
                  : Text(l10n?.requestsDetailAddNote ?? 'Add Note'),
            ),
          ),
        ],
      ),
    );
  }
}
