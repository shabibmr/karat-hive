import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/router/offer_query_params.dart';
import 'package:kh_admin/features/offers/model/offer_enums.dart';
import 'package:kh_admin/features/offers/model/offer_list_filters.dart';

void main() {
  test('OfferQueryParams parses from Uri correctly', () {
    final uri = Uri.parse(
      '/offers?q=OFF-1&state=ACCEPTED&requestType=GOLD_BULLION'
      '&vendorId=ven-9&dateFrom=2026-08-01&dateTo=2026-08-31'
      '&minPrice=1000.25&maxPrice=20000',
    );
    final params = OfferQueryParams.fromUri(uri);

    expect(params.query, 'OFF-1');
    expect(params.state, OfferState.accepted);
    expect(params.requestType, RequestType.goldBullion);
    expect(params.vendorId, 'ven-9');
    expect(params.dateFrom, DateTime(2026, 8, 1));
    expect(params.dateTo, DateTime(2026, 8, 31));
    expect(params.minPrice, 1000.25);
    expect(params.maxPrice, 20000);
  });

  test('OfferQueryParams serializes dates as yyyy-MM-dd and prices as decimals',
      () {
    final params = OfferQueryParams(
      query: 'Al Noor',
      state: OfferState.pending,
      requestType: RequestType.findOrnament,
      vendorId: 'ven-1',
      dateFrom: DateTime(2026, 8, 10),
      dateTo: DateTime(2026, 8, 12),
      minPrice: 16000.5,
      maxPrice: 18900.0,
    );
    final map = params.toQueryParameters();

    expect(map['q'], 'Al Noor');
    expect(map['state'], 'PENDING');
    expect(map['requestType'], 'FIND_ORNAMENT');
    expect(map['vendorId'], 'ven-1');
    expect(map['dateFrom'], '2026-08-10');
    expect(map['dateTo'], '2026-08-12');
    expect(map['minPrice'], '16000.5');
    expect(map['maxPrice'], '18900.0');
  });

  test('OfferQueryParams omits empty and null values', () {
    const params = OfferQueryParams();
    expect(params.toQueryParameters(), isEmpty);

    final parsed = OfferQueryParams.fromUri(Uri.parse('/offers'));
    expect(parsed.toFilters(), const OfferListFilters());
  });

  test('OfferQueryParams ignores unknown enums and invalid numbers/dates', () {
    final uri = Uri.parse(
      '/offers?state=MAYBE&requestType=NOPE&minPrice=x&maxPrice=&dateFrom=not-a-date',
    );
    final params = OfferQueryParams.fromUri(uri);

    expect(params.state, isNull);
    expect(params.requestType, isNull);
    expect(params.minPrice, isNull);
    expect(params.maxPrice, isNull);
    expect(params.dateFrom, isNull);
  });

  test('OfferQueryParams round-trips through OfferListFilters', () {
    final filters = OfferListFilters(
      query: 'ven-off-2',
      state: OfferState.withdrawn,
      requestType: RequestType.goldCoin,
      vendorId: 'ven-2',
      dateFrom: DateTime(2026, 1, 2),
      dateTo: DateTime(2026, 12, 31),
      minPrice: 12.5,
      maxPrice: 99.0,
    );

    final params = OfferQueryParams.fromFilters(filters);
    expect(params.toFilters(), filters);

    final uri = Uri(path: '/offers', queryParameters: params.toQueryParameters());
    expect(OfferQueryParams.fromUri(uri).toFilters(), filters);
  });
}
