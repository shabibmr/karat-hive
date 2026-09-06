import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

class FilterPresetsClient {
  const FilterPresetsClient(this._client);
  final KhApiClient _client;

  Future<Result<List<FilterPresetItem>>> list() async {
    final r = await _client.send('GET', '/v1/filter-presets');
    return r.when(
      ok: (d) => Ok(((d as List?) ?? const [])
          .map((e) => FilterPresetItem.fromJson(e as Map<String, dynamic>))
          .toList(growable: false)),
      err: Err.new,
    );
  }

  Future<Result<FilterPresetItem>> create({
    required String name,
    required Map<String, dynamic> filters,
  }) async {
    final r = await _client.send('POST', '/v1/filter-presets', body: {
      'name': name,
      'filters': filters,
    });
    return r.when(
      ok: (d) => Ok(FilterPresetItem.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<FilterPresetItem>> update(
    String id, {
    String? name,
    Map<String, dynamic>? filters,
  }) async {
    final r = await _client.send('PATCH', '/v1/filter-presets/$id', body: {
      if (name != null) 'name': name,
      if (filters != null) 'filters': filters,
    });
    return r.when(
      ok: (d) => Ok(FilterPresetItem.fromJson(d as Map<String, dynamic>)),
      err: Err.new,
    );
  }

  Future<Result<void>> delete(String id) async {
    final r = await _client.send('DELETE', '/v1/filter-presets/$id');
    return r.when(
      ok: (_) => const Ok(null),
      err: Err.new,
    );
  }
}
