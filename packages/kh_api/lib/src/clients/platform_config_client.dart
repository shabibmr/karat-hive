import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class PlatformConfigClient {
  const PlatformConfigClient(this._client);
  final KhApiClient _client;

  Future<Result<PlatformConfig>> call() => getConfig();

  Future<Result<PlatformConfig>> getConfig() async {
    final r = await _client.send('GET', '/v1/platform-config');
    return r.when(
      ok: (d) {
        final map = d is Map<String, dynamic>
            ? (d['data'] is Map<String, dynamic> ? d['data'] as Map<String, dynamic> : d)
            : const <String, dynamic>{};
        return Ok(PlatformConfig.fromJson(map));
      },
      err: Err.new,
    );
  }
}
