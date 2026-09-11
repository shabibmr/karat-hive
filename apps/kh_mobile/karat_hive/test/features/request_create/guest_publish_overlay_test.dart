import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/auth/controller/customer_onboarding_controller.dart';
import 'package:karat_hive/features/request_create/controller/request_create_controller.dart';
import 'package:karat_hive/features/request_create/pending_publish_intent.dart';
import 'package:karat_hive/features/request_create/presentation/request_review_publish_screen.dart';
import 'package:karat_hive/features/request_create/repository/request_create_repository.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_session.dart';

class _MockRepo extends Mock implements RequestCreateRepository {}

class _FakeOnboarding extends CustomerOnboardingController {
  _FakeOnboarding(this._state);
  final CustomerOnboardingState _state;
  @override
  CustomerOnboardingState build() => _state;
}

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
  });

  test('guest publish() does not call createDraft (GL-46)', () async {
    final container = ProviderContainer(
      overrides: [
        requestCreateRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(
          () => FakeSessionController(const SignedOut()),
        ),
      ],
    );
    addTearDown(container.dispose);

    final ctrl = container.read(requestCreateControllerProvider.notifier);
    ctrl.selectType(RequestType.findOrnament);

    final ok = await ctrl.publish();
    expect(ok, isFalse);
    verifyNever(() => repo.createDraft(any()));
    verifyNever(() => repo.publish(any(), idempotencyKey: any(named: 'idempotencyKey')));
  });

  testWidgets('Guest Publish opens Login overlay and keeps notes on dismiss', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        requestCreateRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(
          () => FakeSessionController(const SignedOut()),
        ),
        customerOnboardingControllerProvider.overrideWith(
          () => _FakeOnboarding(const OnboardingIdle()),
        ),
      ],
    );
    addTearDown(container.dispose);

    container
        .read(requestCreateControllerProvider.notifier)
        .selectType(RequestType.findOrnament);
    container.read(requestCreateControllerProvider.notifier).setNotes('keep-me');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: khTheme(),
          localizationsDelegates: KhStrings.delegates,
          supportedLocales: KhStrings.supportedLocales,
          home: const RequestReviewPublishScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('review-notes-field')), findsOneWidget);
    expect(container.read(requestCreateControllerProvider).notes, 'keep-me');

    await tester.tap(find.text('Publish'));
    await tester.pumpAndSettle();

    expect(container.read(pendingPublishIntentProvider), isTrue);
    expect(find.byKey(const Key('customer-google-signin')), findsOneWidget);
    expect(find.byKey(const Key('google-continue-dismiss')), findsOneWidget);
    expect(find.byKey(const Key('biometric-unlock-toggle')), findsNothing);

    await tester.tap(find.byKey(const Key('google-continue-dismiss')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('customer-google-signin')), findsNothing);
    expect(container.read(pendingPublishIntentProvider), isTrue);
    expect(container.read(requestCreateControllerProvider).notes, 'keep-me');
    expect(find.byKey(const Key('review-notes-field')), findsOneWidget);
  });
}
