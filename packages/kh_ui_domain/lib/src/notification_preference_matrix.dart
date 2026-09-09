import 'package:flutter/material.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';

/// Preference categories that cannot be disabled (`FR-CUS-032` AC4,
/// `FR-SYS-008` AC2).
///
/// NOTE: This is duplicated in `backend/src/modules/settings/domain/locked-notification-categories.ts`
/// (`LOCKED_NOTIFICATION_CATEGORIES`) by design. Supports offline UI rendering while allowing the
/// backend to enforce the business invariant independently.
const Set<String> kLockedNotificationCategories = {'security'};

bool isLockedNotificationCategory(String category) =>
    kLockedNotificationCategories.contains(category);

/// Forced channel state for locked / security-critical categories.
const NotificationChannelPref kLockedNotificationChannelPref =
    NotificationChannelPref(inApp: true, push: true, email: true);

/// Channels exposed by `UserSettings.notifications` / `NotificationChannelPref`.
enum NotificationPrefChannel { inApp, push, email }

/// One matrix row — category id, display label, and current channel prefs.
class NotificationPreferenceCategory {
  const NotificationPreferenceCategory({
    required this.id,
    required this.label,
    required this.pref,
    this.locked = false,
    this.hint,
  });

  /// Wire key (e.g. `offer.submitted`, `security`).
  final String id;

  /// Localised display label supplied by the parent.
  final String label;

  final NotificationChannelPref pref;

  /// When true (or [id] is in [kLockedNotificationCategories]), channels stay
  /// on and non-interactive.
  final bool locked;

  /// Optional footnote under a locked row (e.g. "Required for account security").
  final String? hint;

  bool get isLocked => locked || isLockedNotificationCategory(id);

  NotificationChannelPref get effectivePref =>
      isLocked ? kLockedNotificationChannelPref : pref;
}

NotificationChannelPref notificationChannelPrefWith(
  NotificationChannelPref pref,
  NotificationPrefChannel channel,
  bool value,
) {
  switch (channel) {
    case NotificationPrefChannel.inApp:
      return NotificationChannelPref(
        inApp: value,
        push: pref.push,
        email: pref.email,
      );
    case NotificationPrefChannel.push:
      return NotificationChannelPref(
        inApp: pref.inApp,
        push: value,
        email: pref.email,
      );
    case NotificationPrefChannel.email:
      return NotificationChannelPref(
        inApp: pref.inApp,
        push: pref.push,
        email: value,
      );
  }
}

bool notificationChannelValue(
  NotificationChannelPref pref,
  NotificationPrefChannel channel,
) {
  switch (channel) {
    case NotificationPrefChannel.inApp:
      return pref.inApp;
    case NotificationPrefChannel.push:
      return pref.push;
    case NotificationPrefChannel.email:
      return pref.email;
  }
}

/// SH-NTF-03 — Notification preference matrix (category × channel).
///
/// Locks security-critical categories (`FR-CUS-032` AC4). Quiet hours belong
/// to VE-24 / the settings screen, not this matrix. Copy is parent-owned so
/// this package stays free of ARB strings.
class NotificationPreferenceMatrix extends StatelessWidget {
  const NotificationPreferenceMatrix({
    super.key,
    required this.categories,
    this.onChanged,
    this.inAppLabel = 'In-app',
    this.pushLabel = 'Push',
    this.emailLabel = 'Email',
    this.padding,
  });

  final List<NotificationPreferenceCategory> categories;

  /// Fired with the category id and the next full channel pref. Never called
  /// for locked / security-critical categories.
  final void Function(String categoryId, NotificationChannelPref next)?
      onChanged;

  final String inAppLabel;
  final String pushLabel;
  final String emailLabel;
  final EdgeInsetsGeometry? padding;

  String _channelLabel(NotificationPrefChannel channel) {
    switch (channel) {
      case NotificationPrefChannel.inApp:
        return inAppLabel;
      case NotificationPrefChannel.push:
        return pushLabel;
      case NotificationPrefChannel.email:
        return emailLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final gap = tokens.space.md;

    return Padding(
      key: const Key('notification-preference-matrix'),
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < categories.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            _CategoryBlock(
              category: categories[i],
              channelLabel: _channelLabel,
              onChanged: onChanged,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryBlock extends StatelessWidget {
  const _CategoryBlock({
    required this.category,
    required this.channelLabel,
    required this.onChanged,
  });

  final NotificationPreferenceCategory category;
  final String Function(NotificationPrefChannel channel) channelLabel;
  final void Function(String categoryId, NotificationChannelPref next)?
      onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final locked = category.isLocked;
    final pref = category.effectivePref;

    return Card(
      key: Key('notif-pref-category-${category.id}'),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.md),
        side: BorderSide(color: tokens.ink.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    category.label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (locked)
                  Icon(
                    Icons.lock_outline,
                    key: Key('notif-pref-lock-${category.id}'),
                    size: 18,
                    color: tokens.ink.withValues(alpha: 0.45),
                  ),
              ],
            ),
            if (category.hint != null && category.hint!.trim().isNotEmpty) ...[
              SizedBox(height: tokens.space.xs),
              Text(
                category.hint!,
                key: Key('notif-pref-hint-${category.id}'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: tokens.ink.withValues(alpha: 0.6),
                ),
              ),
            ],
            SizedBox(height: tokens.space.sm),
            ...NotificationPrefChannel.values.expand((channel) {
              final toggle = KhToggle(
                key: Key('notif-pref-${category.id}-${channel.name}'),
                label: channelLabel(channel),
                value: notificationChannelValue(pref, channel),
                enabled: !locked && onChanged != null,
                onChanged: locked || onChanged == null
                    ? null
                    : (value) {
                        onChanged!(
                          category.id,
                          notificationChannelPrefWith(pref, channel, value),
                        );
                      },
              );
              if (channel == NotificationPrefChannel.values.first) {
                return [toggle];
              }
              return [SizedBox(height: tokens.space.xs), toggle];
            }),
          ],
        ),
      ),
    );
  }
}
