import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class AbuseClient {
  const AbuseClient(this._client);
  final KhApiClient _client;

  Future<Result<AbuseReport>> submit({
    required AbuseEntityType entityType,
    required String entityId,
    required String category,
    required String description,
  }) async {
    final r = await _client.send('POST', '/v1/abuse-reports', body: {
      'entityType': entityType.wire,
      'entityId': entityId,
      'category': category,
      'description': description,
    });
    return r.when(
      ok: (d) => Ok(AbuseReport.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }
}
