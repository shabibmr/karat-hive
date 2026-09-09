import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../repository/notifications_repository.dart';

/// Paged notification list (CUS-S19 / VEN-S17).
class NotificationsController
    extends AutoDisposeNotifier<PagedListController<AppNotification>> {
  @override
  PagedListController<AppNotification> build() {
    final repo = ref.watch(notificationsRepositoryProvider);

    final controller = PagedListController<AppNotification>(
      itemKey: (item) => item.id,
      fetcher: (cursor) async {
        final res = await repo.list(cursor: cursor);
        return res.when(
          ok: (page) => page,
          err: (failure) => throw failure,
        );
      },
    );

    ref.onDispose(controller.dispose);
    return controller;
  }

  Future<void> loadNextPage() => state.loadNextPage();

  Future<void> refresh() => state.refresh();

  Future<void> retry() => state.retry();

  /// Marks one notification read and patches the in-memory list item.
  Future<Result<AppNotification>> markRead(String id) async {
    final current = state.value.items.where((n) => n.id == id).firstOrNull;
    if (current?.readAt != null) {
      return Ok(current!);
    }

    final res = await ref.read(notificationsRepositoryProvider).markRead(id);
    return res.when(
      ok: (updated) {
        _replaceItem(updated);
        return Ok(updated);
      },
      err: Err.new,
    );
  }

  /// Marks all notifications read and clears unread styling locally.
  Future<Result<void>> markAllRead() async {
    final res = await ref.read(notificationsRepositoryProvider).markAllRead();
    return res.when(
      ok: (_) {
        _markAllLocal(DateTime.now().toUtc());
        return const Ok(null);
      },
      err: Err.new,
    );
  }

  void _replaceItem(AppNotification updated) {
    final list = state.value;
    final items = [
      for (final n in list.items)
        if (n.id == updated.id) updated else n,
    ];
    state.value = list.copyWith(items: List.unmodifiable(items));
  }

  void _markAllLocal(DateTime readAt) {
    final list = state.value;
    final items = [
      for (final n in list.items)
        if (n.readAt != null)
          n
        else
          AppNotification(
            id: n.id,
            type: n.type,
            title: n.title,
            body: n.body,
            deepLink: n.deepLink,
            isCritical: n.isCritical,
            createdAt: n.createdAt,
            readAt: readAt,
          ),
    ];
    state.value = list.copyWith(items: List.unmodifiable(items));
  }
}

final notificationsControllerProvider = AutoDisposeNotifierProvider<
    NotificationsController, PagedListController<AppNotification>>(
  NotificationsController.new,
);
