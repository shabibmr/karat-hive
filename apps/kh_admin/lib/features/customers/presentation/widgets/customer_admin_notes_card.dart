import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/features/customers/model/customer_detail.dart';
import 'package:kh_admin/features/customers/presentation/widgets/customer_detail_formatters.dart';

/// Admin audit & internal-notes card. Was
/// `_CustomerDetailScreenState._buildAdminNotesCard` (TR-S2-12). The add-note
/// controller call stays in the screen.
class CustomerAdminNotesCard extends StatelessWidget {
  const CustomerAdminNotesCard({
    super.key,
    required this.detail,
    required this.noteController,
    required this.isProcessing,
    required this.onAddNote,
  });

  final CustomerDetail detail;
  final TextEditingController noteController;
  final bool isProcessing;
  final VoidCallback onAddNote;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    return Container(
      key: const Key('customer-admin-notes-card'),
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
          const KhSectionLabel('ADMIN AUDIT & NOTES'),
          SizedBox(height: kh.spacing.xs),
          Text(
            'Internal Notes (${detail.adminNotes.length})',
            style: kh.typography.title.copyWith(color: kh.colors.textPrimary),
          ),
          SizedBox(height: kh.spacing.xs),
          Text(
            'Internal notes are strictly visible to platform admins and tracked with timestamps.',
            style: kh.typography.caption.copyWith(color: kh.colors.textSecondary),
          ),
          SizedBox(height: kh.spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('customer-note-input-field'),
                  controller: noteController,
                  maxLines: 2,
                  style: kh.typography.bodySmall,
                  decoration: InputDecoration(
                    hintText: 'Add an internal admin note…',
                    isDense: true,
                    filled: true,
                    fillColor: kh.colors.backgroundSurface,
                    border: OutlineInputBorder(
                      borderRadius: kh.shapes.roundedMd,
                      borderSide: BorderSide(color: kh.colors.borderSubtle),
                    ),
                  ),
                ),
              ),
              SizedBox(width: kh.spacing.sm),
              ElevatedButton.icon(
                key: const Key('customer-add-note-button'),
                onPressed: isProcessing ? null : onAddNote,
                icon: const Icon(Icons.note_add, size: 16),
                label: const Text('Add Note'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kh.colors.goldPrimary,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(
                    horizontal: kh.spacing.md,
                    vertical: kh.spacing.sm,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: kh.spacing.lg),
          if (detail.adminNotes.isEmpty)
            Text(
              'No internal notes added yet.',
              style: kh.typography.caption.copyWith(
                color: kh.colors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detail.adminNotes.length,
              separatorBuilder: (_, __) => SizedBox(height: kh.spacing.sm),
              itemBuilder: (context, idx) {
                final note = detail.adminNotes[idx];
                return Container(
                  padding: EdgeInsets.all(kh.spacing.sm),
                  decoration: BoxDecoration(
                    color: kh.colors.backgroundSurface,
                    borderRadius: kh.shapes.roundedMd,
                    border: Border.all(color: kh.colors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            note.authorName,
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.goldPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            customerFormatDateTime(note.createdAt),
                            style: kh.typography.caption.copyWith(
                              color: kh.colors.textMuted,
                              fontSize: 10.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: kh.spacing.xs),
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
        ],
      ),
    );
  }
}
