import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/src/notification_list_item.dart';

/// In-app centre retention window (`FR-CUS-032`, `FR-VEN-026`, `NFR-021`).
const Duration kNotificationCentreWindow = Duration(days: 90);

/// Notifications whose [AppNotification.createdAt] falls in the centre window
/// ending at [now], newest first.
///
/// Items older than [window] are dropped here so the UI stays correct even if
/// a caller passes an unfiltered payload.
List<AppNotification> notificationsInCentreWindow(
  Iterable<AppNotification> notifications, {
  required DateTime now,
  Duration window = kNotificationCentreWindow,
}) {
  final cutoff = now.subtract(window);
  final filtered = notifications
      .where((n) => !n.createdAt.isBefore(cutoff))
      .toList(growable: false);
  return List<AppNotification>.of(filtered)
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}

/// SH-NTF-02 — Notification centre list (90-day window).
///
/// Composes [NotificationListItem] (SH-NTF-01). Empty state uses existing
/// [KhEmptyView] (SH-FND-12). Unread count badges (SH-FND-18) belong to the
/// screen chrome, not this list.
class NotificationCentreList extends StatelessWidget {
  const NotificationCentreList({
    super.key,
    required this.notifications,
    this.now,
    this.onNotificationTap,
    this.emptyMessage = 'No notifications in the last 90 days.',
    this.emptyIcon = Icons.notifications_none_outlined,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  final List<AppNotification> notifications;

  /// Frozen clock for the 90-day filter and item relative times.
  final DateTime? now;

  /// Deep-link / mark-read is the parent's job.
  final void Function(AppNotification notification)? onNotificationTap;

  /// Passed through so this package need not own copy for empty state.
  final String emptyMessage;
  final IconData emptyIcon;

  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final clock = now ?? DateTime.now().toUtc();
    final items = notificationsInCentreWindow(
      notifications,
      now: clock,
    );

    if (items.isEmpty) {
      return KeyedSubtree(
        key: const Key('notification-centre-list'),
        child: KhEmptyView(
          message: emptyMessage,
          icon: emptyIcon,
        ),
      );
    }

    final gap = tokens.space.sm;
    final listPadding = padding ?? EdgeInsets.all(tokens.space.md);

    return ListView.separated(
      key: const Key('notification-centre-list'),
      padding: listPadding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: gap),
      itemBuilder: (context, index) {
        final n = items[index];
        return NotificationListItem(
          notification: n,
          now: clock,
          onTap: onNotificationTap == null
              ? null
              : () => onNotificationTap!(n),
        );
      },
    );
  }
}
