import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/router/request_query_params.dart';
import 'package:kh_admin/features/requests/model/request_enums.dart';
import 'package:kh_admin/features/requests/model/request_list_filters.dart';

void main() {
  test('RequestQueryParams parses from Uri correctly', () {
    final uri = Uri.parse(
      '/requests?q=KH-RQ-1&requestType=FIND_ORNAMENT&direction=BUY'
      '&state=PUBLISHED&categoryId=cat-1&regionId=reg-2'
      '&zeroOffers=true&minValue=1000.5&maxValue=25000',
    );
    final params = RequestQueryParams.fromUri(uri);

    expect(params.query, 'KH-RQ-1');
    expect(params.requestType, RequestType.findOrnament);
    expect(params.direction, Direction.buy);
    expect(params.state, RequestState.published);
    expect(params.categoryId, 'cat-1');
    expect(params.regionId, 'reg-2');
    expect(params.zeroOffersOnly, isTrue);
    expect(params.minValue, 1000.5);
    expect(params.maxValue, 25000);
  });

  test('RequestQueryParams serializes only non-default fields', () {
    const params = RequestQueryParams(
      query: 'KH-RQ-1',
      requestType: RequestType.goldCoin,
      direction: Direction.sell,
      state: RequestState.offersReceived,
      categoryId: 'cat-9',
      regionId: 'reg-3',
      zeroOffersOnly: true,
      minValue: 10.5,
      maxValue: 99.0,
    );
    final map = params.toQueryParameters();

    expect(map['q'], 'KH-RQ-1');
    expect(map['requestType'], 'GOLD_COIN');
    expect(map['direction'], 'SELL');
    expect(map['state'], 'OFFERS_RECEIVED');
    expect(map['categoryId'], 'cat-9');
    expect(map['regionId'], 'reg-3');
    expect(map['zeroOffers'], 'true');
    expect(map['minValue'], '10.5');
    expect(map['maxValue'], '99.0');
  });

  test('RequestQueryParams omits empty values and zeroOffers when false', () {
    const params = RequestQueryParams();
    expect(params.toQueryParameters(), isEmpty);

    final uri = Uri.parse('/requests?zeroOffers=false');
    final parsed = RequestQueryParams.fromUri(uri);
    expect(parsed.zeroOffersOnly, isFalse);
    expect(parsed.toQueryParameters().containsKey('zeroOffers'), isFalse);
    expect(parsed.toFilters(), const RequestListFilters());
  });

  test('RequestQueryParams ignores unknown enums and invalid decimals', () {
    final uri = Uri.parse(
      '/requests?requestType=NOPE&direction=SIDEWAYS&state=MAYBE'
      '&minValue=abc&maxValue=',
    );
    final params = RequestQueryParams.fromUri(uri);

    expect(params.requestType, isNull);
    expect(params.direction, isNull);
    expect(params.state, isNull);
    expect(params.minValue, isNull);
    expect(params.maxValue, isNull);
  });

  test('RequestQueryParams round-trips through RequestListFilters', () {
    const filters = RequestListFilters(
      query: 'notes',
      requestType: RequestType.sellOldGold,
      direction: Direction.buy,
      state: RequestState.accepted,
      categoryId: 'cat-x',
      regionId: 'reg-y',
      zeroOffersOnly: true,
      minValue: 12.25,
      maxValue: 8000.0,
    );

    final params = RequestQueryParams.fromFilters(filters);
    expect(params.toFilters(), filters);

    final uri = Uri(
      path: '/requests',
      queryParameters: params.toQueryParameters(),
    );
    expect(RequestQueryParams.fromUri(uri).toFilters(), filters);
  });
}
