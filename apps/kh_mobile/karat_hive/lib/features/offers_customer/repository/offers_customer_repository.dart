import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';

final offersCustomerRepositoryProvider =
    Provider<OffersCustomerRepository>((ref) {
  return OffersCustomerRepository(ref.watch(khApiProvider));
});

class OffersCustomerRepository {
  const OffersCustomerRepository(this._api);
  final KhApi _api;

  Future<Result<PagedResult<OfferForCustomer>>> listForRequest(
    String requestId, {
    String? cursor,
    String? sort,
    String? minRating,
    String? priceMin,
    String? priceMax,
    int? excludeExpiringWithinHours,
  }) =>
      _api.offers.listForRequest(
        requestId,
        cursor: cursor,
        sort: sort,
        minRating: minRating,
        priceMin: priceMin,
        priceMax: priceMax,
        excludeExpiringWithinHours: excludeExpiringWithinHours,
      );

  Future<Result<OfferForCustomer>> get(String id) => _api.offers.get(id);

  Future<Result<VendorRatingDetail>> vendorRating(String offerId) =>
      _api.offers.vendorRating(offerId);

  Future<Result<AcceptOfferResult>> accept(String id) => _api.offers.accept(id);

  Future<Result<OfferForCustomer>> decline(
    String id, {
    String? reason,
    String? note,
  }) =>
      _api.offers.decline(id, reason: reason, note: note);
}
