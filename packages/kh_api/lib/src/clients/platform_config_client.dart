import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class PlatformConfigClient {
  const PlatformConfigClient(this._client);
  final KhApiClient _client;

  Future<Result<PlatformConfig>> getConfig() async {
    final r = await _client.send('GET', '/v1/platform-config', unwrapData: false);
    return r.when(
      ok: (d) => Ok(PlatformConfig.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }
}
