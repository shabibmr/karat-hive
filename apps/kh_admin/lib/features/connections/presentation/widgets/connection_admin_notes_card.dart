import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/connections/model/connection_detail.dart';
import 'package:kh_admin/features/connections/presentation/widgets/connection_detail_formatters.dart';

/// Internal-admin-notes card. Was
/// `_ConnectionDetailScreenState._buildAdminNotesCard` (TR-S2-14). The add-note
/// controller call stays in the screen.
class ConnectionAdminNotesCard extends StatelessWidget {
  const ConnectionAdminNotesCard({
    super.key,
    required this.detail,
    required this.noteController,
    required this.isPosting,
    required this.onPost,
  });

  final ConnectionDetail detail;
  final TextEditingController noteController;
  final bool isPosting;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
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
                            connectionFormatDate(note.createdAt),
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
            controller: noteController,
            maxLines: 2,
            enabled: !isPosting,
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
              onPressed: isPosting ? null : onPost,
              icon: isPosting
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
}
