import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/subscription/controller/subscription_controller.dart';
import 'package:karat_hive/features/subscription/presentation/subscriptions_screen.dart';
import 'package:karat_hive/features/subscription/repository/subscription_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

class FakeSubscriptionRepository implements SubscriptionRepository {
  FakeSubscriptionRepository({
    this.hangSubscriptions = false,
    this.subscriptionsError,
    List<VendorSubscriptionItem>? subscriptions,
  }) : subscriptions = subscriptions ??
            [
              VendorSubscriptionItem(
                requestType: 'FIND_ORNAMENT',
                state: 'ACTIVE',
                priceAed: '499.00',
                canOffer: true,
                renewalDate: DateTime.utc(2026, 10, 1),
              ),
              VendorSubscriptionItem(
                requestType: 'CUSTOM_DESIGN',
                state: 'GRACE',
                priceAed: '299.00',
                canOffer: true,
                graceEndsAt: DateTime.utc(2026, 9, 15),
              ),
              VendorSubscriptionItem(
                requestType: 'BULLION',
                state: 'EXPIRED',
                priceAed: '699.00',
                canOffer: false,
              ),
            ];

  final bool hangSubscriptions;
  final Failure? subscriptionsError;
  final List<VendorSubscriptionItem> subscriptions;

  @override
  Future<Result<List<VendorSubscriptionItem>>> getSubscriptions() async {
    if (hangSubscriptions) await Completer<void>().future;
    if (subscriptionsError != null) return Err(subscriptionsError!);
    return Ok(subscriptions);
  }

  @override
  Future<Result<PlatformConfig>> getPlatformConfig() async {
    return Ok(
      PlatformConfig(
        requestLifetimeHours: 48,
        offerValidityHours: [12, 24, 48],
        defaultOfferValidityHours: 24,
        bullionMinimumAed: '5000',
        maxConcurrentLiveRequests: 3,
        maxOfferRevisions: 3,
        requestExpiryWarningHours: 6,
        karatList: ['18', '21', '22', '24'],
        supportContactUrl: 'https://karathive.ae/support',
        subscriptionContactUrl: 'https://karathive.ae/subscriptions',
        termsUrl: 'https://karathive.ae/terms',
        privacyUrl: 'https://karathive.ae/privacy',
      ),
    );
  }
}

void main() {
  group('SubscriptionsScreen (VEN-S22)', () {
    testWidgets('renders all 4 request categories and their entitlement states', (tester) async {
      final fakeRepo = FakeSubscriptionRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subscriptionRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            localizationsDelegates: KhStrings.delegates,
            supportedLocales: KhStrings.supportedLocales,
            home: const SubscriptionsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('subscriptions-screen')), findsOneWidget);
      expect(find.text('Subscriptions & Entitlements'), findsOneWidget);

      // 4 types present
      expect(find.text('Find Ornament'), findsOneWidget);
      expect(find.text('Custom Design'), findsOneWidget);
      expect(find.text('Bullion & Investment'), findsOneWidget);
      expect(find.text('Repair & Resize'), findsOneWidget);

      // Badges
      expect(find.byType(SubscriptionBadge), findsNWidgets(4));
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('GRACE'), findsOneWidget);
      expect(find.text('EXPIRED'), findsOneWidget);
      expect(find.text('NONE'), findsOneWidget);

      // Distinct Grace messaging
      expect(find.textContaining('Grace period active until 2026-09-15'), findsOneWidget);

      // Distinct Expired messaging
      expect(find.textContaining('Subscription expired. Matching requests for this category are currently paused.'), findsOneWidget);

      // CTA deep link button
      await tester.scrollUntilVisible(find.byType(KhButton), 300);
      expect(find.byType(KhButton), findsOneWidget);
    });

    testWidgets('shows KhLoadingView while subscriptions are loading', (tester) async {
      final fakeRepo = FakeSubscriptionRepository(hangSubscriptions: true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subscriptionRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            localizationsDelegates: KhStrings.delegates,
            supportedLocales: KhStrings.supportedLocales,
            home: const SubscriptionsScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(KhLoadingView), findsOneWidget);
      expect(find.byKey(const Key('loading-view')), findsOneWidget);
    });

    testWidgets('shows KhErrorView when subscriptions fail (SH-FND-13)', (tester) async {
      final fakeRepo = FakeSubscriptionRepository(
        subscriptionsError: const ServerFailure(message: 'subscriptions unavailable'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subscriptionRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: MaterialApp(
            localizationsDelegates: KhStrings.delegates,
            supportedLocales: KhStrings.supportedLocales,
            home: const SubscriptionsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(KhErrorView), findsOneWidget);
      expect(find.byKey(const Key('error-view')), findsOneWidget);
      expect(find.text('Could not load subscription details.'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });
}
