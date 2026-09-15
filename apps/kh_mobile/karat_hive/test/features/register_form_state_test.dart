import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/auth/model/register_form_state.dart';

void main() {
  group('RegisterFormState.toRegisterBody (vendor)', () {
    test('includes typed mobileNumber and omits a null challengeId', () {
      const form = RegisterFormState(
        contactPersonName: 'Ali',
        mobileNumber: '+971501234567',
        tradingName: 'Gold House',
        regionId: 'region-1',
        businessEmail: 'shop@example.com',
      );

      final body = form.toRegisterBody();

      expect(body['mobileNumber'], '+971501234567');
      expect(body.containsKey('challengeId'), isFalse);
    });

    test('includes challengeId when the OTP flow set one', () {
      const form = RegisterFormState(
        contactPersonName: 'Ali',
        mobileNumber: '+971501234567',
        tradingName: 'Gold House',
        regionId: 'region-1',
        challengeId: 'chal-1',
      );

      final body = form.toRegisterBody();

      expect(body['challengeId'], 'chal-1');
    });

    test('categoryIds and servedRegionIds default to empty/derived lists', () {
      const form = RegisterFormState(
        contactPersonName: 'Ali',
        mobileNumber: '+971501234567',
        tradingName: 'Gold House',
        regionId: 'region-1',
      );

      final body = form.toRegisterBody();

      expect(body['categoryIds'], isEmpty);
      expect(body['servedRegionIds'], ['region-1']);
    });
  });
}
