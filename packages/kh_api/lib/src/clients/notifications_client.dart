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
      ok: (raw) {
        try {
          return Ok(parsePagedEnvelope(raw, AppNotification.fromJson));
        } catch (e) {
          return Err(
            ServerFailure(
              code: 'BAD_RESPONSE',
              message: 'Could not load notifications.',
            ),
          );
        }
      },
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

  Future<Result<int>> unreadCount() async {
    final r = await _client.send('GET', '/v1/notifications/unread-count');
    return r.when(
      ok: (d) => Ok(d is Map ? (d['count'] as int? ?? 0) : (d as int? ?? 0)),
      err: Err.new,
    );
  }

  Future<Result<void>> markAllRead() async {
    final r = await _client.send('POST', '/v1/notifications/read-all');
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }

  /// `POST /v1/devices` — idempotent upsert of this device's push token.
  /// [platform] is `IOS` or `ANDROID`.
  /// Returns the backend device id.
  Future<Result<String?>> registerDevice({
    required String platform,
    required String pushToken,
    String? label,
  }) async {
    final r = await _client.send(
      'POST',
      '/v1/devices',
      body: {
        'platform': platform,
        'pushToken': pushToken,
        if (label != null) 'label': label,
      },
    );
    return r.when(
      ok: (d) => Ok(d is Map ? d['id'] as String? : null),
      err: Err.new,
    );
  }

  /// `DELETE /v1/devices/:id` — stop pushing to this device (call while the
  /// session is still authenticated).
  Future<Result<void>> deleteDevice(String id) async {
    final r = await _client.send('DELETE', '/v1/devices/$id');
    return r.when(ok: (_) => const Ok(null), err: Err.new);
  }
}
