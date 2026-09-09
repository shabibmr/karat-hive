import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/router/verification_query_params.dart';

void main() {
  group('TR-S7-07 · VerificationQueryParams', () {
    test('round-trips selectedId through query parameters', () {
      const params = VerificationQueryParams(selectedId: 'ven-42');

      final encoded = params.toQueryParameters();
      expect(encoded['selectedId'], 'ven-42');

      final decoded = VerificationQueryParams.fromUri(
        Uri(path: '/verification', queryParameters: encoded),
      );
      expect(decoded.selectedId, 'ven-42');
    });

    test('emits no query parameters when nothing is selected', () {
      expect(const VerificationQueryParams().toQueryParameters(), isEmpty);
    });

    test('fromUri reads selectedId straight off the URL', () {
      final decoded = VerificationQueryParams.fromUri(
        Uri.parse('/verification?selectedId=ven-99'),
      );
      expect(decoded.selectedId, 'ven-99');
    });

    test('fromUri yields a null selectedId for a bare path', () {
      expect(
        VerificationQueryParams.fromUri(Uri.parse('/verification')).selectedId,
        isNull,
      );
    });

    test('copyWith clearSelected drops the id', () {
      const params = VerificationQueryParams(selectedId: 'ven-1');
      expect(params.copyWith(clearSelected: true).selectedId, isNull);
      expect(params.copyWith(selectedId: 'ven-2').selectedId, 'ven-2');
    });
  });
}
