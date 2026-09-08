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

  Future<Result<MeUser>> changeMobile(String challengeId) async {
    final r = await _client.send('POST', '/v1/me/mobile/change', body: {
      'challengeId': challengeId,
    });
    return r.when(
      ok: (d) => Ok(MeUser.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<MeUser>> deactivate() async {
    final r = await _client.send('POST', '/v1/me/deactivate');
    return r.when(
      ok: (d) => Ok(MeUser.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<AccountDeletionRequest>> createDeletionRequest() async {
    final r = await _client.send('POST', '/v1/me/deletion-requests');
    return r.when(
      ok: (d) =>
          Ok(AccountDeletionRequest.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<AccountDeletionRequest>> confirmDeletionRequest(
    String id, {
    required String challengeId,
  }) async {
    final r = await _client.send(
      'POST',
      '/v1/me/deletion-requests/$id/confirm',
      body: {'challengeId': challengeId},
    );
    return r.when(
      ok: (d) =>
          Ok(AccountDeletionRequest.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }
}
