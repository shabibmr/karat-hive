import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class MeClient {
  const MeClient(this._client);
  final KhApiClient _client;

  Future<Result<MeUser>> me() async {
    final r = await _client.send('GET', '/v1/me');
    return r.when(
      ok: (d) => Ok(MeUser.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }
}
