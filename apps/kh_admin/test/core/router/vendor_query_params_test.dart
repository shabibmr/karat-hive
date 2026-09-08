import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/router/vendor_query_params.dart';
import 'package:kh_admin/features/vendors/model/vendor_enums.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_filters.dart';

void main() {
  test('VendorQueryParams parses from Uri correctly', () {
    final uri = Uri.parse(
      '/vendors?q=Al%20Noor&verificationState=PENDING_VERIFICATION&accountState=SUSPENDED',
    );
    final params = VendorQueryParams.fromUri(uri);

    expect(params.query, 'Al Noor');
    expect(
      params.verificationState,
      VendorVerificationState.pendingVerification,
    );
    expect(params.accountState, VendorAccountState.suspended);
  });

  test('VendorQueryParams serializes only non-default fields', () {
    const params = VendorQueryParams(
      query: 'Al Noor',
      verificationState: VendorVerificationState.verified,
      accountState: VendorAccountState.active,
    );
    final map = params.toQueryParameters();

    expect(map, {
      'q': 'Al Noor',
      'verificationState': 'VERIFIED',
      'accountState': 'ACTIVE',
    });
  });

  test('VendorQueryParams omits empty and null values', () {
    const params = VendorQueryParams();
    expect(params.toQueryParameters(), isEmpty);

    final uri = Uri.parse('/vendors');
    final parsed = VendorQueryParams.fromUri(uri);
    expect(parsed.query, isNull);
    expect(parsed.verificationState, isNull);
    expect(parsed.accountState, isNull);
    expect(parsed.toFilters(), const VendorListFilters());
  });

  test('VendorQueryParams ignores unknown enum values', () {
    final uri = Uri.parse(
      '/vendors?verificationState=NOPE&accountState=UNKNOWN',
    );
    final params = VendorQueryParams.fromUri(uri);

    expect(params.verificationState, isNull);
    expect(params.accountState, isNull);
  });

  test('VendorQueryParams round-trips through VendorListFilters', () {
    const filters = VendorListFilters(
      query: 'licence-42',
      verificationState: VendorVerificationState.rejected,
      accountState: VendorAccountState.deactivated,
    );

    final params = VendorQueryParams.fromFilters(filters);
    expect(params.toFilters(), filters);

    final uri = Uri(path: '/vendors', queryParameters: params.toQueryParameters());
    expect(VendorQueryParams.fromUri(uri).toFilters(), filters);
  });

  test('VendorQueryParams copyWith preserves and replaces fields', () {
    const params = VendorQueryParams(
      query: 'gold',
      verificationState: VendorVerificationState.registered,
    );

    final updated = params.copyWith(
      accountState: VendorAccountState.active,
    );
    expect(updated.query, 'gold');
    expect(updated.verificationState, VendorVerificationState.registered);
    expect(updated.accountState, VendorAccountState.active);

    final cleared = updated.copyWith(clearQuery: true, clearVerification: true);
    expect(cleared.query, isNull);
    expect(cleared.verificationState, isNull);
    expect(cleared.accountState, VendorAccountState.active);
  });
}
