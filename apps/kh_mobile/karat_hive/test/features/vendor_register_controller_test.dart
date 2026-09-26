import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/di.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/auth/controller/vendor_register_controller.dart';
import 'package:karat_hive/features/auth/model/register_form_state.dart';
import 'package:karat_hive/features/auth/repository/auth_repository.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_media/kh_media.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/customer_auth.dart';
import '../helpers/fake_session.dart';

class _MockAuthRepo extends Mock implements AuthRepository {}

class _MockKhApi extends Mock implements KhApi {}

class _MockMediaPickController extends Mock implements MediaPickController {}

void main() {
  late _MockAuthRepo repo;
  late RecordingSessionController session;

  setUp(() {
    repo = _MockAuthRepo();
    session = RecordingSessionController();
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(Uint8List(0));
  });

  ProviderContainer container({
    KhApi? api,
    MediaPickController? logoMedia,
  }) =>
      ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(() => session),
        if (api != null) khApiProvider.overrideWithValue(api),
        if (logoMedia != null)
          vendorLogoMediaControllerProvider.overrideWithValue(logoMedia),
      ]);

  SessionBundle vendorBundle() => SessionBundle(
        tokens: SessionTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
          accessExpiresAt: DateTime.utc(2030),
          refreshExpiresAt: DateTime.utc(2030),
        ),
        user: testVendorUser(),
      );

  VendorRegisterController seeded(ProviderContainer c) {
    final ctrl = c.read(vendorRegisterControllerProvider.notifier);
    ctrl.begin(
      firebaseIdToken: 'fb-token',
      suggestedName: 'Ali',
      suggestedEmail: 'ali@shop.ae',
    );
    ctrl.patch(
      (s) => s.copyWith(
        mobileNumber: '+971501234567',
        tradingName: 'Gold House',
        regionId: '11111111-1111-1111-1111-111111111111',
        addressBuilding: 'Gold Souk',
        whatsAppNumber: '+971501234567',
        termsAccepted: true,
      ),
    );
    return ctrl;
  }

  test('begin() is idempotent — re-seeding does not wipe entered input', () {
    final c = container();
    addTearDown(c.dispose);
    final ctrl = seeded(c);

    ctrl.begin(firebaseIdToken: 'fb-token');

    expect(
      c.read(vendorRegisterControllerProvider).tradingName,
      'Gold House',
    );
    expect(
      c.read(vendorRegisterControllerProvider).firebaseIdToken,
      'fb-token',
    );
  });

  test('begin() locks Google email so later patches cannot change it', () {
    final c = container();
    addTearDown(c.dispose);
    final ctrl = seeded(c);

    ctrl.patch((s) => s.copyWith(businessEmail: 'hacker@evil.com'));

    final form = c.read(vendorRegisterControllerProvider);
    expect(form.businessEmail, 'ali@shop.ae');
    expect(form.googleEmailLocked, isTrue);
  });

  test('begin() without Google email surfaces a validation failure', () {
    final c = container();
    addTearDown(c.dispose);
    final ctrl = c.read(vendorRegisterControllerProvider.notifier);

    ctrl.begin(firebaseIdToken: 'fb-token');

    final form = c.read(vendorRegisterControllerProvider);
    expect(form.googleEmailLocked, isFalse);
    expect(form.failure, isA<ValidationFailure>());
  });

  test('submitDirect sends firebaseToken so Google is bound (VO-01)', () async {
    final bundle = vendorBundle();
    Map<String, dynamic>? captured;
    when(() => repo.registerVendor(any())).thenAnswer((invocation) async {
      captured = Map<String, dynamic>.from(
        invocation.positionalArguments.first as Map,
      );
      return Ok(bundle);
    });

    final c = container();
    addTearDown(c.dispose);
    await seeded(c).submitDirect();

    final form = c.read(vendorRegisterControllerProvider);
    expect(form.step, RegisterStep.done);
    expect(session.authenticated.single, bundle);
    expect(captured?['firebaseToken'], 'fb-token');
    expect(captured?['mobileNumber'], '+971501234567');
  });

  test('submitDirect without Google token omits firebaseToken', () async {
    final bundle = vendorBundle();
    Map<String, dynamic>? captured;
    when(() => repo.registerVendor(any())).thenAnswer((invocation) async {
      captured = Map<String, dynamic>.from(
        invocation.positionalArguments.first as Map,
      );
      return Ok(bundle);
    });

    final c = container();
    addTearDown(c.dispose);
    final ctrl = c.read(vendorRegisterControllerProvider.notifier);
    ctrl.patch(
      (s) => s.copyWith(
        contactPersonName: 'Ali',
        mobileNumber: '+971501234567',
        tradingName: 'Gold House',
        regionId: '11111111-1111-1111-1111-111111111111',
        addressBuilding: 'Gold Souk',
        businessEmail: 'ali@shop.ae',
        whatsAppNumber: '+971501234567',
        termsAccepted: true,
      ),
    );
    await ctrl.submitDirect();

    expect(captured?.containsKey('firebaseToken'), isFalse);
    expect(captured?['contactWhatsApp'], '+971501234567');
    expect(captured?['businessAddress'], 'Gold Souk');
  });

  group('logo upload after register (Phase 5)', () {
    late _MockKhApi api;
    late _MockMediaPickController media;

    setUp(() {
      api = _MockKhApi();
      media = _MockMediaPickController();
      when(() => repo.registerVendor(any()))
          .thenAnswer((_) async => Ok(vendorBundle()));
    });

    test('uploads the picked logo and patches the profile with the returned key',
        () async {
      final bytes = Uint8List.fromList(const [1, 2, 3]);
      when(
        () => media.convertBytesAndUpload(
          any(),
          correlationId: any(named: 'correlationId'),
        ),
      ).thenAnswer((_) async => const Ok('media-key-new-logo'));
      when(() => api.patchVendorProfile(logoMediaKey: any(named: 'logoMediaKey')))
          .thenAnswer((_) async => Ok(testVendorMe()));

      final c = container(api: api, logoMedia: media);
      addTearDown(c.dispose);
      final ctrl = seeded(c);
      ctrl.patch((s) => s.copyWith(logoBytes: bytes));
      await ctrl.submitDirect();

      expect(c.read(vendorRegisterControllerProvider).step, RegisterStep.done);
      final captured = verify(
        () => media.convertBytesAndUpload(
          captureAny(),
          correlationId: 'vendor-logo',
        ),
      ).captured;
      expect(captured.single, bytes);
      verify(() => api.patchVendorProfile(logoMediaKey: 'media-key-new-logo'))
          .called(1);
    });

    test('registration still completes when logo upload fails', () async {
      when(
        () => media.convertBytesAndUpload(
          any(),
          correlationId: any(named: 'correlationId'),
        ),
      ).thenAnswer(
        (_) async => const Err(ServerFailure(message: 'Upload failed.')),
      );

      final c = container(api: api, logoMedia: media);
      addTearDown(c.dispose);
      final ctrl = seeded(c);
      ctrl.patch((s) => s.copyWith(logoBytes: Uint8List.fromList(const [1, 2, 3])));
      await ctrl.submitDirect();

      expect(c.read(vendorRegisterControllerProvider).step, RegisterStep.done);
      verifyNever(
        () => api.patchVendorProfile(logoMediaKey: any(named: 'logoMediaKey')),
      );
    });

    test('skips the upload entirely when no logo was picked', () async {
      final c = container(api: api, logoMedia: media);
      addTearDown(c.dispose);
      await seeded(c).submitDirect();

      expect(c.read(vendorRegisterControllerProvider).step, RegisterStep.done);
      verifyNever(
        () => media.convertBytesAndUpload(
          any(),
          correlationId: any(named: 'correlationId'),
        ),
      );
      verifyNever(
        () => api.patchVendorProfile(logoMediaKey: any(named: 'logoMediaKey')),
      );
    });
  });
}
