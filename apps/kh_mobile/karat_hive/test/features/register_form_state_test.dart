import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/auth/model/register_form_state.dart';

void main() {
  group('RegisterFormState validation (VO-08 / VO-09)', () {
    test('step1Complete requires E.164 mobile', () {
      const weak = RegisterFormState(
        contactPersonName: 'Ali',
        mobileNumber: '501234567',
        businessEmail: 'a@b.com',
        googleEmailLocked: true,
      );
      const ok = RegisterFormState(
        contactPersonName: 'Ali',
        mobileNumber: '+971501234567',
        businessEmail: 'a@b.com',
        googleEmailLocked: true,
      );

      expect(weak.step1Complete, isFalse);
      expect(ok.step1Complete, isTrue);
    });

    test('step3Complete requires a real address, not region alone', () {
      const regionOnly = RegisterFormState(regionId: 'region-1');
      const withAddress = RegisterFormState(
        regionId: 'region-1',
        addressBuilding: 'Gold Souk',
      );

      expect(regionOnly.step3Complete, isFalse);
      expect(withAddress.step3Complete, isTrue);
    });

    test('step4Complete requires E.164 WhatsApp and business email', () {
      const incomplete = RegisterFormState(
        whatsAppNumber: '501234567',
        businessEmail: 'shop@example.com',
        termsAccepted: true,
      );
      const ok = RegisterFormState(
        whatsAppNumber: '+971501234567',
        businessEmail: 'shop@example.com',
        termsAccepted: true,
      );

      expect(incomplete.step4Complete, isFalse);
      expect(ok.step4Complete, isTrue);
    });
  });

  group('RegisterFormState.toRegisterBody (vendor)', () {
    test('includes typed mobileNumber and omits a null challengeId', () {
      const form = RegisterFormState(
        contactPersonName: 'Ali',
        mobileNumber: '+971501234567',
        tradingName: 'Gold House',
        regionId: 'region-1',
        addressBuilding: 'Gold Souk',
        businessEmail: 'shop@example.com',
        whatsAppNumber: '+971501234567',
      );

      final body = form.toRegisterBody();

      expect(body['mobileNumber'], '+971501234567');
      expect(body['businessAddress'], 'Gold Souk');
      expect(body['contactWhatsApp'], '+971501234567');
      expect(body.containsKey('challengeId'), isFalse);
      expect(body.containsKey('firebaseToken'), isFalse);
    });

    test('includes firebaseToken when seeded from Google login (VO-01)', () {
      const form = RegisterFormState(
        contactPersonName: 'Ali',
        mobileNumber: '+971501234567',
        tradingName: 'Gold House',
        regionId: 'region-1',
        addressBuilding: 'Gold Souk',
        businessEmail: 'shop@example.com',
        firebaseIdToken: 'fb-id-token',
      );

      final body = form.toRegisterBody();

      expect(body['firebaseToken'], 'fb-id-token');
    });

    test('locked Google email ignores copyWith edits', () {
      const form = RegisterFormState(
        businessEmail: 'vendor@gmail.com',
        googleEmailLocked: true,
        tradingName: 'Gold House',
      );

      final next = form.copyWith(businessEmail: 'other@example.com');

      expect(next.businessEmail, 'vendor@gmail.com');
      expect(next.googleEmailLocked, isTrue);
    });

    test('locked Google email is sent as-is (no placeholder)', () {
      const form = RegisterFormState(
        contactPersonName: 'Ali',
        mobileNumber: '+971501234567',
        tradingName: 'Gold House',
        regionId: 'region-1',
        addressBuilding: 'Gold Souk',
        businessEmail: 'vendor@gmail.com',
        googleEmailLocked: true,
        firebaseIdToken: 'fb-id-token',
      );

      expect(form.toRegisterBody()['businessEmail'], 'vendor@gmail.com');
    });

    test('never invents @karathive.ae email or UAE address (VO-09)', () {
      const form = RegisterFormState(
        contactPersonName: 'Ali',
        mobileNumber: '+971501234567',
        tradingName: 'Gold House',
        regionId: 'region-1',
      );

      final body = form.toRegisterBody();

      expect(body['businessEmail'], '');
      expect(body['businessAddress'], '');
      expect(body['businessEmail'].toString().contains('@karathive.ae'), isFalse);
      expect(body['businessAddress'], isNot('UAE'));
    });

    test('includes challengeId when the OTP flow set one', () {
      const form = RegisterFormState(
        contactPersonName: 'Ali',
        mobileNumber: '+971501234567',
        tradingName: 'Gold House',
        regionId: 'region-1',
        addressBuilding: 'Gold Souk',
        businessEmail: 'shop@example.com',
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
        addressBuilding: 'Gold Souk',
        businessEmail: 'shop@example.com',
      );

      final body = form.toRegisterBody();

      expect(body['categoryIds'], isEmpty);
      expect(body['servedRegionIds'], ['region-1']);
    });

    test('empty trade licence uses unique PENDING_ provisional (VO-02)', () {
      const form = RegisterFormState(
        contactPersonName: 'Ali',
        mobileNumber: '+971501234567',
        tradingName: 'Gold House',
        regionId: 'region-1',
        addressBuilding: 'Gold Souk',
        businessEmail: 'shop@example.com',
      );

      final a = form.toRegisterBody()['tradeLicenceNumber'] as String;
      final b = form.toRegisterBody()['tradeLicenceNumber'] as String;

      expect(a, startsWith('PENDING_'));
      expect(b, startsWith('PENDING_'));
      expect(a, isNot('PENDING_UPLOAD'));
      expect(a, isNot(b));
      expect(a.length, lessThanOrEqualTo(50));
    });

    test('explicit trade licence is sent unchanged', () {
      const form = RegisterFormState(
        contactPersonName: 'Ali',
        mobileNumber: '+971501234567',
        tradingName: 'Gold House',
        regionId: 'region-1',
        addressBuilding: 'Gold Souk',
        businessEmail: 'shop@example.com',
        tradeLicenceNumber: 'CN-1092834',
      );

      expect(form.toRegisterBody()['tradeLicenceNumber'], 'CN-1092834');
    });
  });
}
