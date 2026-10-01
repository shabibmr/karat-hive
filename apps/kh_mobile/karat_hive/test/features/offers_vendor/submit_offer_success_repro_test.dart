import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:karat_hive/app/di.dart';
import 'package:karat_hive/features/offers_vendor/controller/submit_offer_controller.dart';
import 'package:karat_hive/features/offers_vendor/presentation/submit_offer_screen.dart';
import 'package:karat_hive/features/offers_vendor/repository/offers_vendor_repository.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

import 'submit_offer_screen_test.dart' show FakeOffersVendorRepository;

void main() {
  testWidgets('[repro] successful submit leaves the Submit Offer screen',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repo = FakeOffersVendorRepository();
    // Mirrors lib/app/router.dart: Requests and Offers are separate
    // StatefulShellRoute branches.
    late StatefulNavigationShell shell;
    final router = GoRouter(
      initialLocation: '/vendor/requests/req-offer-1/offer',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, __, s) {
            shell = s;
            return s;
          },
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/vendor/requests',
                builder: (_, __) => const Scaffold(body: Text('FEED')),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (_, __) => const Scaffold(body: Text('DETAIL')),
                    routes: [
                      GoRoute(
                        path: 'offer',
                        builder: (_, s) => SubmitOfferScreen(
                          requestId: s.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/vendor/offers',
                builder: (_, __) => const Scaffold(body: Text('MY-OFFERS')),
              ),
            ]),
          ],
        ),
      ],
    );

    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          offersVendorRepositoryProvider.overrideWithValue(repo),
          offerUploadSkipsConversionProvider.overrideWithValue(true),
          offerImageUploaderProvider.overrideWithValue(
            OfferImageUploader(
              (bytes, ct, {onProgress}) async => const Ok('media-key-1'),
            ),
          ),
        ],
        child: Consumer(builder: (context, ref, _) {
          container = ProviderScope.containerOf(context);
          return MaterialApp.router(
            theme: khTheme(),
            localizationsDelegates: KhStrings.delegates,
            supportedLocales: KhStrings.supportedLocales,
            routerConfig: router,
          );
        }),
      ),
    );
    await tester.pumpAndSettle();

    await container
        .read(submitOfferControllerProvider('req-offer-1').notifier)
        .addPickedImage(
          bytes: Uint8List.fromList([1, 2, 3]),
          filename: 'a.jpg',
          contentType: 'image/jpeg',
        );
    await tester.pump();
    await tester.enterText(find.byKey(const Key('offer-price-field')), '5200');
    await tester.pump();

    await tester.tap(find.byKey(const Key('submit-offer-button')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(repo.submitCalls, 1, reason: 'submit reached the repository');
    expect(find.text('MY-OFFERS'), findsOneWidget,
        reason: 'page should leave Submit Offer after success');

    // Vendor returns to the Requests tab.
    shell.goBranch(0);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('submit-offer-screen')), findsNothing,
        reason: 'Requests tab must not be stuck on the Submit Offer spinner');
  });
}
