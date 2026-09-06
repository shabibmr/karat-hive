import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class TaxonomyClient {
  const TaxonomyClient(this._client);
  final KhApiClient _client;

  Future<Result<List<TaxonomyNode>>> categories() => _taxonomy('/v1/categories');
  Future<Result<List<TaxonomyNode>>> regions() => _taxonomy('/v1/regions');

  Future<Result<List<TaxonomyNode>>> _taxonomy(String path) async {
    final r = await _client.send('GET', path);
    return r.when(
      ok: (d) => Ok(((d as List?) ?? const [])
          .map((e) => TaxonomyNode.fromJson(e as Map<String, dynamic>))
          .toList(growable: false)),
      err: Err.new,
    );
  }
}
