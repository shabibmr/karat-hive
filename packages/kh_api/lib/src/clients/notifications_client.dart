import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../paged.dart';

class NotificationsClient {
  const NotificationsClient(this._client);
  final KhApiClient _client;

  Future<Result<PagedResult<AppNotification>>> list({
    bool? unread,
    String? cursor,
    int limit = 20,
  }) async {
    final r = await _client.send(
      'GET',
      '/v1/notifications',
      query: {
        if (unread != null) 'unread': unread.toString(),
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        'limit': limit.toString(),
      },
      unwrapData: false,
    );
    return r.when(
      ok: (raw) => Ok(parsePagedEnvelope(raw, AppNotification.fromJson)),
      err: Err.new,
    );
  }

  Future<Result<AppNotification>> markRead(String id) async {
    final r = await _client.send('POST', '/v1/notifications/$id/read');
    return r.when(
      ok: (d) => Ok(AppNotification.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<void>> markAllRead() async {
    final r = await _client.send('POST', '/v1/notifications/read-all');
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }
}
