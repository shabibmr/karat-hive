import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/core/design/widgets/kh_section_label.dart';
import 'package:kh_admin/core/design/widgets/kh_status_chip.dart';
import 'package:kh_admin/core/format/kh_formats.dart';
import 'package:kh_admin/features/requests/model/request_detail.dart';
import 'package:kh_admin/features/requests/presentation/widgets/request_detail_row.dart';
import 'package:kh_admin/l10n/app_localizations.dart';

/// State transition history card. Was `_buildTimelineCard`.
class RequestTimelineCard extends StatelessWidget {
  const RequestTimelineCard({super.key, required this.detail});

  final RequestDetail detail;

  @override
  Widget build(BuildContext context) {
    final kh = context.kh;
    final l10n = AppLocalizations.of(context);
    final dateFormat = khDateTimeFormat;

    return Container(
      key: const Key('request-timeline'),
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
              l10n?.requestsDetailTimelineTitle ?? 'State Transition History'),
          SizedBox(height: kh.spacing.md),
          if (detail.timeline.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: kh.spacing.md),
              child: Text(
                l10n?.requestsDetailNoTransitions ?? 'No recorded transitions.',
                style: kh.typography.bodySmall.copyWith(
                  color: kh.colors.textMuted,
                  fontSize: 13.0,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: detail.timeline.length,
              separatorBuilder: (_, __) => SizedBox(height: kh.spacing.sm),
              itemBuilder: (context, index) {
                final ev = detail.timeline[index];
                return Row(
                  children: [
                    KhStatusChip(
                      label: ev.state.label,
                      tone: requestStateTone(ev.state),
                      dense: true,
                    ),
                    SizedBox(width: kh.spacing.md),
                    Text(
                      dateFormat.format(ev.timestamp),
                      style: kh.typography.caption.copyWith(
                        color: kh.colors.textSecondary,
                        fontSize: 11.0,
                      ),
                    ),
                    if (ev.actor != null) ...[
                      SizedBox(width: kh.spacing.sm),
                      Text(
                        l10n?.requestsDetailTimelineBy(ev.actor!) ??
                            'by ${ev.actor}',
                        style: kh.typography.caption.copyWith(
                          color: kh.colors.textMuted,
                          fontSize: 11.0,
                        ),
                      ),
                    ],
                    if (ev.notes != null) ...[
                      SizedBox(width: kh.spacing.sm),
                      Expanded(
                        child: Text(
                          '(${ev.notes})',
                          style: kh.typography.caption.copyWith(
                            color: kh.colors.textSecondary,
                            fontStyle: FontStyle.italic,
                            fontSize: 11.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
