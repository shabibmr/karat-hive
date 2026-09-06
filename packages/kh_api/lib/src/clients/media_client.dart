import 'package:kh_core/kh_core.dart';
import '../dtos.dart';

class MediaClient {
  const MediaClient(this._client);
  final KhApiClient _client;

  Future<Result<UploadIntent>> uploadIntent({
    required String purpose,
    required String contentType,
    required int byteSize,
  }) async {
    final r = await _client.send('POST', '/v1/media/upload-intent', body: {
      'purpose': purpose,
      'contentType': contentType,
      'byteSize': byteSize,
    });
    return r.when(
      ok: (d) => Ok(UploadIntent.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<String>> completeUpload(String key) async {
    final r = await _client.send('POST', '/v1/media/$key/complete');
    return r.when(
      ok: (d) => Ok((d as Map<String, dynamic>)['state'] as String? ?? 'READY'),
      err: Err.new,
    );
  }
}
