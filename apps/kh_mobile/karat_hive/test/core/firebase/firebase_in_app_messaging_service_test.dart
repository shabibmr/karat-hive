import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/core/firebase/firebase_in_app_messaging_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseInAppMessaging extends Mock
    implements FirebaseInAppMessaging {}

void main() {
  late MockFirebaseInAppMessaging mockFiam;
  late FirebaseInAppMessagingService service;

  setUp(() {
    mockFiam = MockFirebaseInAppMessaging();
    service = FirebaseInAppMessagingService(inAppMessaging: mockFiam);
  });

  group('FirebaseInAppMessagingService', () {
    test('triggerEvent delegates to FirebaseInAppMessaging', () async {
      when(() => mockFiam.triggerEvent('onboarding_complete'))
          .thenAnswer((_) async {});

      await service.triggerEvent('onboarding_complete');

      verify(() => mockFiam.triggerEvent('onboarding_complete')).called(1);
    });

    test('triggerEvent catches errors without rethrowing', () async {
      when(() => mockFiam.triggerEvent(any()))
          .thenThrow(Exception('Platform error'));

      await expectLater(
        service.triggerEvent('failing_event'),
        completes,
      );
      verify(() => mockFiam.triggerEvent('failing_event')).called(1);
    });

    test('setMessagesSuppressed delegates to FirebaseInAppMessaging', () async {
      when(() => mockFiam.setMessagesSuppressed(true))
          .thenAnswer((_) async {});

      await service.setMessagesSuppressed(true);

      verify(() => mockFiam.setMessagesSuppressed(true)).called(1);

      when(() => mockFiam.setMessagesSuppressed(false))
          .thenAnswer((_) async {});

      await service.setMessagesSuppressed(false);

      verify(() => mockFiam.setMessagesSuppressed(false)).called(1);
    });

    test('setMessagesSuppressed catches errors without rethrowing', () async {
      when(() => mockFiam.setMessagesSuppressed(any()))
          .thenThrow(Exception('Platform error'));

      await expectLater(
        service.setMessagesSuppressed(true),
        completes,
      );
      verify(() => mockFiam.setMessagesSuppressed(true)).called(1);
    });

    test('setAutomaticDataCollectionEnabled delegates to FirebaseInAppMessaging', () async {
      when(() => mockFiam.setAutomaticDataCollectionEnabled(false))
          .thenAnswer((_) async {});

      await service.setAutomaticDataCollectionEnabled(false);

      verify(() => mockFiam.setAutomaticDataCollectionEnabled(false)).called(1);
    });

    test('setAutomaticDataCollectionEnabled catches errors without rethrowing', () async {
      when(() => mockFiam.setAutomaticDataCollectionEnabled(any()))
          .thenThrow(Exception('Platform error'));

      await expectLater(
        service.setAutomaticDataCollectionEnabled(false),
        completes,
      );
      verify(() => mockFiam.setAutomaticDataCollectionEnabled(false)).called(1);
    });

    test('firebaseInAppMessagingServiceProvider resolves via ProviderContainer', () {
      final container = ProviderContainer(
        overrides: [
          firebaseInAppMessagingServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);

      final resolved = container.read(firebaseInAppMessagingServiceProvider);
      expect(resolved, same(service));
    });
  });
}
