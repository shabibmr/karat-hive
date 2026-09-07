import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';

import '../../../app/di.dart';

final offersVendorRepositoryProvider = Provider<OffersVendorRepository>((ref) {
  return OffersVendorRepository(ref.watch(khApiProvider));
});

class OffersVendorRepository {
  const OffersVendorRepository(this._api);
  final KhApi _api;

  Future<Result<PlatformConfig>> getPlatformConfig() =>
      _api.platformConfig.getConfig();

  Future<Result<VendorRequestItem>> getRequest(String requestId) =>
      _api.requests.getRequest(requestId);

  Future<Result<OfferForVendor>> getOffer(String offerId) =>
      _api.offers.getOffer(offerId);

  Future<Result<OfferForVendor>> submitOffer({
    required String requestId,
    required OfferTermsInput terms,
  }) =>
      _api.offers.submitOffer(requestId: requestId, terms: terms);

  Future<Result<OfferForVendor>> reviseOffer({
    required String offerId,
    required OfferTermsInput terms,
  }) =>
      _api.offers.reviseOffer(offerId: offerId, terms: terms);

  Future<Result<OfferForVendor>> withdrawOffer(String offerId) =>
      _api.offers.withdrawOffer(offerId);

  Future<Result<PagedResult<OfferForVendor>>> listMyOffers({
    required String tab,
    String? requestType,
    DateTime? from,
    DateTime? to,
    String? q,
    String? cursor,
  }) =>
      _api.offers.listMyOffers(
        tab: tab,
        requestType: requestType,
        from: from,
        to: to,
        q: q,
        cursor: cursor,
      );
}
