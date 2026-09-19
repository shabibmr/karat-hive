import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

import '../../../app/notification_deep_link.dart';
import '../controller/notifications_controller.dart';

/// CUS-S19 — Customer notification centre list (`FR-CUS-032`, SH-NTF-01/02).
///
/// Same paged/mark-read machinery as [VendorNotificationCentreScreen]
/// (VEN-S17) — the backend endpoint and controller are role-agnostic; only
/// deep-link resolution (`isVendor: false`) differs.
class CustomerNotificationCentreScreen extends ConsumerWidget {
  const CustomerNotificationCentreScreen({super.key});

  static const Key screenKey = Key('customer-notification-centre-screen');
  static const Key markAllReadKey = Key('notifications-mark-all-read');

  void _openDeepLink(BuildContext context, WidgetRef ref, AppNotification n) {
    NotificationDeepLink.open(
      context,
      n.deepLink,
      isVendor: false,
    );
  }

  Future<void> _onNotificationTap(
    BuildContext context,
    WidgetRef ref,
    AppNotification n,
  ) async {
    if (n.readAt == null) {
      await ref.read(notificationsControllerProvider.notifier).markRead(n.id);
    }
    if (!context.mounted) return;
    _openDeepLink(context, ref, n);
  }

  Future<void> _onMarkAllRead(BuildContext context, WidgetRef ref) async {
    final result =
        await ref.read(notificationsControllerProvider.notifier).markAllRead();
    if (!context.mounted) return;
    result.when(
      ok: (_) {},
      err: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failure.message ?? 'Could not mark notifications as read.',
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(notificationsControllerProvider);
    final strings = KhStrings.of(context);

    return Scaffold(
      key: screenKey,
      appBar: AppBar(
        title: const Text('Alerts'),
        actions: [
          ValueListenableBuilder<PagedListState<AppNotification>>(
            valueListenable: controller,
            builder: (context, listState, _) {
              final hasUnread =
                  listState.items.any((n) => n.readAt == null);
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                key: markAllReadKey,
                onPressed: () => _onMarkAllRead(context, ref),
                child: Text(strings.s('notifications.markAllRead')),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<PagedListState<AppNotification>>(
        valueListenable: controller,
        builder: (context, listState, _) {
          if (listState.isInitialLoading || listState.isInitial) {
            return const KhLoadingView();
          }

          if (listState.isInitialError) {
            return KhErrorView(
              message: switch (listState.error) {
                final Failure f =>
                  f.message ?? 'Could not load notifications.',
                _ => 'Could not load notifications.',
              },
              onRetry: () =>
                  ref.read(notificationsControllerProvider.notifier).retry(),
            );
          }

          // Empty (API or 90-day window) is owned by SH-NTF-02.
          if (listState.items.isEmpty) {
            return const NotificationCentreList(notifications: []);
          }

          return KhPullToRefresh(
            onRefresh: () =>
                ref.read(notificationsControllerProvider.notifier).refresh(),
            child: Column(
              children: [
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 200) {
                        ref
                            .read(notificationsControllerProvider.notifier)
                            .loadNextPage();
                      }
                      return false;
                    },
                    child: NotificationCentreList(
                      notifications: listState.items,
                      onNotificationTap: (n) =>
                          _onNotificationTap(context, ref, n),
                    ),
                  ),
                ),
                if (listState.hasMore)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
