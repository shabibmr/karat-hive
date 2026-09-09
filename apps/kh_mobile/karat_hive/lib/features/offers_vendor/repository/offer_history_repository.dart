import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';

final offerHistoryRepositoryProvider = Provider<OfferHistoryRepository>((ref) {
  return OfferHistoryRepository(ref.watch(khApiProvider));
});

/// VEN-S14 performance aggregates via [PerformanceClient] (CP6-B04.1 / B04.2)
/// and terminal offer history via [OffersClient] (CP6-B04.4).
class OfferHistoryRepository {
  const OfferHistoryRepository(this._api);
  final KhApi _api;

  Future<Result<VendorPerformanceDto>> getPerformance({
    DateTime? from,
    DateTime? to,
    String? requestType,
    String? categoryId,
    String? regionId,
  }) =>
      _api.performance.getPerformance(
        from: from,
        to: to,
        requestType: requestType,
        categoryId: categoryId,
        regionId: regionId,
      );

  Future<Result<PerformanceExportDto>> exportPerformance({
    DateTime? from,
    DateTime? to,
    String? requestType,
    String? categoryId,
    String? regionId,
  }) =>
      _api.performance.exportPerformance(
        from: from,
        to: to,
        requestType: requestType,
        categoryId: categoryId,
        regionId: regionId,
      );

  Future<Result<PagedResult<OfferForVendor>>> getTerminalOffers({
    String? tab = 'CLOSED',
    String? requestType,
    DateTime? from,
    DateTime? to,
    String? cursor,
    int limit = 50,
  }) =>
      _api.offers.listMyOffers(
        tab: tab,
        requestType: requestType,
        from: from,
        to: to,
        cursor: cursor,
        limit: limit,
      );
}
