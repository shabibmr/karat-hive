import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(ref.watch(khApiProvider));
});

class NotificationsRepository {
  const NotificationsRepository(this._api);
  final KhApi _api;

  Future<Result<PagedResult<AppNotification>>> list({
    bool? unread,
    String? cursor,
    int limit = 20,
  }) =>
      _api.notifications.list(unread: unread, cursor: cursor, limit: limit);

  Future<Result<AppNotification>> markRead(String id) =>
      _api.notifications.markRead(id);

  Future<Result<void>> markAllRead() => _api.notifications.markAllRead();
}
