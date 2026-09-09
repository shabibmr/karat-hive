import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/src/relative_time_label.dart';

/// Maps a notification `type` wire value to a category icon (SH-NTF-01).
IconData notificationCategoryIcon(String type) {
  final t = type.toLowerCase();
  if (t.contains('offer.accepted') || t.contains('connection.established')) {
    return Icons.check_circle_outline;
  }
  if (t.contains('offer.rejected')) return Icons.cancel_outlined;
  if (t.contains('matched')) return Icons.inbox_outlined;
  if (t.contains('expir')) return Icons.schedule_outlined;
  if (t.contains('cancel') || t.contains('withdrawn')) {
    return Icons.remove_circle_outline;
  }
  if (t.contains('edit') || t.contains('revis')) return Icons.edit_outlined;
  if (t.contains('review')) return Icons.star_outline;
  if (t.contains('verif')) return Icons.verified_outlined;
  if (t.contains('document') || t.contains('kyc')) {
    return Icons.description_outlined;
  }
  if (t.contains('announcement')) return Icons.campaign_outlined;
  if (t.contains('security') || t.contains('connection.closed')) {
    return Icons.shield_outlined;
  }
  if (t.contains('offer') || t == 'first_offer') {
    return Icons.local_offer_outlined;
  }
  return Icons.notifications_outlined;
}

/// SH-NTF-01 — Notification list item (category icon, read/unread, deep link).
///
/// Deep-link navigation is the parent's job via [onTap]; this widget never
/// interprets [AppNotification.deepLink] itself.
class NotificationListItem extends StatelessWidget {
  const NotificationListItem({
    super.key,
    required this.notification,
    this.onTap,
    this.now,
  });

  final AppNotification notification;
  final VoidCallback? onTap;

  /// Frozen clock for [RelativeTimeLabel] in tests / goldens.
  final DateTime? now;

  bool get isUnread => notification.readAt == null;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final unread = isUnread;
    final hasDeepLink = onTap != null && notification.deepLink.trim().isNotEmpty;

    final iconColor = notification.isCritical
        ? tokens.danger
        : (unread ? tokens.gold : tokens.ink.withValues(alpha: 0.7));

    return Card(
      key: Key('notification-item-${notification.id}'),
      elevation: 0,
      color: unread
          ? tokens.gold.withValues(alpha: 0.08)
          : tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(
          color: unread ? tokens.gold : tokens.ink.withValues(alpha: 0.12),
          width: unread ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        child: Padding(
          padding: EdgeInsets.all(tokens.space.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                key: Key('notification-category-${notification.id}'),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: tokens.gold.withValues(alpha: unread ? 0.22 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notificationCategoryIcon(notification.type),
                  size: 20,
                  color: iconColor,
                ),
              ),
              SizedBox(width: tokens.space.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  unread ? FontWeight.w700 : FontWeight.w600,
                              color: unread ? tokens.gold : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: tokens.space.sm),
                        RelativeTimeLabel(
                          at: notification.createdAt,
                          now: now,
                        ),
                      ],
                    ),
                    if (notification.body.isNotEmpty) ...[
                      SizedBox(height: tokens.space.xs),
                      Text(
                        notification.body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.ink
                              .withValues(alpha: unread ? 0.85 : 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (unread)
                Container(
                  key: Key('notification-unread-${notification.id}'),
                  width: 8,
                  height: 8,
                  margin: const EdgeInsetsDirectional.only(start: 8, top: 6),
                  decoration: BoxDecoration(
                    color: tokens.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              if (hasDeepLink)
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: unread ? 4 : 8,
                    top: 2,
                  ),
                  child: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                    size: 20,
                    color: tokens.ink.withValues(alpha: 0.35),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
