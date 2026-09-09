import 'package:flutter/material.dart';

import 'package:kh_admin/core/design/theme/kh_theme.dart';
import 'package:kh_admin/features/connections/model/connection_detail.dart';
import 'package:kh_admin/features/connections/presentation/widgets/connection_detail_formatters.dart';

/// Contact-initiation-events card. Was
/// `_ConnectionDetailScreenState._buildContactEventsCard` (TR-S2-14).
class ConnectionContactEventsCard extends StatelessWidget {
  const ConnectionContactEventsCard({super.key, required this.detail});

  final ConnectionDetail detail;

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
                              connectionFormatDate(event.occurredAt),
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
}
