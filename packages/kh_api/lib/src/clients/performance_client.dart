import 'package:kh_core/kh_core.dart';

import '../dtos/performance_dtos.dart';

/// `GET /v1/me/vendor/performance` and `/export` (`FR-VEN-023`, VEN-S14).
class PerformanceClient {
  const PerformanceClient(this._client);
  final KhApiClient _client;

  /// Performance aggregates including `ratingTrend` (`CP5-A05.2`, `CP6-A03.1`).
  Future<Result<VendorPerformanceDto>> getPerformance({
    DateTime? from,
    DateTime? to,
    String? requestType,
    String? categoryId,
    String? regionId,
  }) async {
    final r = await _client.send(
      'GET',
      '/v1/me/vendor/performance',
      query: _filters(
        from: from,
        to: to,
        requestType: requestType,
        categoryId: categoryId,
        regionId: regionId,
      ),
    );
    return r.when(
      ok: (d) => Ok(VendorPerformanceDto.fromJson(
            Map<String, dynamic>.from(d as Map),
          )),
      err: Err.new,
    );
  }

  /// Signed CSV `{ downloadUrl, expiresAt }` — own Offer rows only (`BR-008`).
  Future<Result<PerformanceExportDto>> exportPerformance({
    DateTime? from,
    DateTime? to,
    String? requestType,
    String? categoryId,
    String? regionId,
  }) async {
    final r = await _client.send(
      'GET',
      '/v1/me/vendor/performance/export',
      query: _filters(
        from: from,
        to: to,
        requestType: requestType,
        categoryId: categoryId,
        regionId: regionId,
      ),
    );
    return r.when(
      ok: (d) => Ok(PerformanceExportDto.fromJson(
            Map<String, dynamic>.from(d as Map),
          )),
      err: Err.new,
    );
  }

  Map<String, dynamic> _filters({
    DateTime? from,
    DateTime? to,
    String? requestType,
    String? categoryId,
    String? regionId,
  }) =>
      {
        if (from != null) 'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
        if (requestType != null) 'requestType': requestType,
        if (categoryId != null) 'categoryId': categoryId,
        if (regionId != null) 'regionId': regionId,
      };
}
