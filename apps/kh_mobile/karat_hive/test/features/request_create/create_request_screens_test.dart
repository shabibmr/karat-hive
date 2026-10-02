import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/request_create/controller/request_create_controller.dart';
import 'package:karat_hive/features/request_create/controller/request_create_state.dart';
import 'package:karat_hive/features/request_create/presentation/find_ornament_screen.dart';
import 'package:karat_hive/features/request_create/presentation/request_review_publish_screen.dart';
import 'package:karat_hive/features/request_create/presentation/widgets/create_fields.dart';
import 'package:karat_hive/features/request_create/presentation/widgets/create_flow_chrome.dart';
import 'package:karat_hive/features/request_create/presentation/widgets/request_images_section.dart';
import 'package:karat_hive/features/request_create/repository/request_create_repository.dart';


import 'package:kh_core/kh_core.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_l10n/kh_l10n.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_session.dart';

class _MockRepo extends Mock implements RequestCreateRepository {}

Widget _buildTestApp(Widget child, ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: khTheme(),
      localizationsDelegates: KhStrings.delegates,
      supportedLocales: KhStrings.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
    when(() => repo.platformConfig()).thenAnswer((_) async => const Ok(PlatformConfig()));
    when(() => repo.regions()).thenAnswer((_) async => const Ok([]));
    when(() => repo.goldRates()).thenAnswer(
      (_) async => const Ok(
        GoldRateSnapshot(available: false, stale: true, rates: []),
      ),
    );
  });



  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        requestCreateRepositoryProvider.overrideWithValue(repo),
        sessionProvider.overrideWith(
          () => FakeSessionController(const SignedOut()),
        ),
      ],
    );
  }

  group('Create Request Screens', () {
    testWidgets('FindOrnamentScreen renders ornament chips and budget editor', (tester) async {
      final container = createContainer();
      container.read(requestCreateControllerProvider.notifier).selectType(RequestType.findOrnament);

      await tester.pumpWidget(_buildTestApp(const FindOrnamentScreen(), container));
      await tester.pumpAndSettle();

      expect(find.text('Find An Ornament'), findsOneWidget);
      expect(find.text('SPECIFY THE PIECE · BUY'), findsOneWidget);
      expect(find.byType(OrnamentTypeChips), findsOneWidget);
      expect(find.byType(BudgetEditor), findsOneWidget);
      expect(find.text('Includes gemstones'), findsOneWidget);
    });

    testWidgets('SellOldGoldScreen renders actual item notice and hides budget editor', (tester) async {
      final container = createContainer();
      container.read(requestCreateControllerProvider.notifier).selectType(RequestType.sellOldGold);

      await tester.pumpWidget(_buildTestApp(const SellOldGoldScreen(), container));
      await tester.pumpAndSettle();

      expect(find.text('Sell Old Gold'), findsOneWidget);
      expect(find.text('DESCRIBE YOUR ITEM'), findsOneWidget);
      expect(
        find.textContaining('Photos must be of the actual item'),
        findsOneWidget,
      );
      expect(find.byType(OrnamentTypeChips), findsOneWidget);
      expect(find.byType(ConditionChips), findsOneWidget);
      expect(find.byType(SellIconFieldGroup), findsOneWidget);
      expect(find.byType(BudgetEditor), findsNothing);
    });

    testWidgets('Sell condition chip uses ctaFill when selected', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => repo.goldRates()).thenAnswer(
        (_) async => const Ok(
          GoldRateSnapshot(
            available: true,
            stale: false,
            rates: [
              GoldRateRow(karat: Karat.k22, ratePerGramAed: '200'),
            ],
          ),
        ),
      );


      final container = createContainer();
      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.sellOldGold);
      ctrl.setWeightGrams('45');
      ctrl.setPurity(Karat.k22);

      await tester.pumpWidget(_buildTestApp(const SellOldGoldScreen(), container));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('condition-chip-USED')));
      await tester.pumpAndSettle();

      expect(
        container.read(requestCreateControllerProvider).condition,
        ItemCondition.used,
      );
      expect(find.byKey(const Key('sell-indicative-panel')), findsOneWidget);
      expect(find.textContaining('AED'), findsWidgets);
    });


    testWidgets(
        'coins and bullion never require images (including SELL)',
        (tester) async {
      final coins = createContainer();
      final coinsCtrl = coins.read(requestCreateControllerProvider.notifier);
      coinsCtrl.selectType(RequestType.goldCoin);
      coinsCtrl.setDirection(Direction.sell);
      expect(coins.read(requestCreateControllerProvider).imagesAllowed, isFalse);
      expect(coins.read(requestCreateControllerProvider).imagesRequired, isFalse);

      await tester.pumpWidget(_buildTestApp(const GoldCoinsScreen(), coins));
      await tester.pumpAndSettle();
      expect(find.byType(RequestImagesSection), findsNothing);

      final ok = await coinsCtrl.persistAndGo(RequestCreateStep.review);
      expect(ok, isTrue);
      expect(
        coins.read(requestCreateControllerProvider).step,
        RequestCreateStep.review,
      );

      final bullion = createContainer();
      bullion.read(requestCreateControllerProvider.notifier).selectType(
            RequestType.goldBullion,
          );
      expect(
        bullion.read(requestCreateControllerProvider).imagesAllowed,
        isFalse,
      );
      expect(
        bullion.read(requestCreateControllerProvider).imagesRequired,
        isFalse,
      );
    });

    testWidgets(
        'GoldCoinsScreen updates total weight when denomination/quantity changes, and toggles budget editor visibility based on Direction',
        (tester) async {
      final container = createContainer();
      container.read(requestCreateControllerProvider.notifier).selectType(RequestType.goldCoin);

      await tester.pumpWidget(_buildTestApp(const GoldCoinsScreen(), container));
      await tester.pumpAndSettle();

      expect(find.text('Buy/Sell Gold Coins'), findsOneWidget);
      expect(find.text('SPECIFY THE PIECE · BUY'), findsOneWidget);
      expect(find.byType(DirectionControl), findsOneWidget);
      expect(find.byType(CoinDenominationChips), findsOneWidget);
      expect(find.byType(QuantityStepper), findsOneWidget);

      // Initially direction == buy -> BudgetEditor visible
      expect(find.byType(BudgetEditor), findsOneWidget);

      // Switch direction to Sell
      await tester.tap(find.byKey(const Key('direction-sell')));
      await tester.pumpAndSettle();

      expect(find.text('SPECIFY THE PIECE · SELL'), findsOneWidget);
      expect(find.byType(BudgetEditor), findsNothing);

      // Switch direction back to Buy
      await tester.tap(find.byKey(const Key('direction-buy')));
      await tester.pumpAndSettle();

      expect(find.text('SPECIFY THE PIECE · BUY'), findsOneWidget);
      expect(find.byType(BudgetEditor), findsOneWidget);

      // Select 10g denomination
      await tester.ensureVisible(find.byKey(const Key('denom-chip-10')));
      await tester.tap(find.byKey(const Key('denom-chip-10')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Total weight: 10.00 g'), findsOneWidget);

      // Tap + on quantity stepper to make quantity 2
      final addButton = find.descendant(
        of: find.byType(QuantityStepper),
        matching: find.byIcon(Icons.add),
      );
      await tester.ensureVisible(addButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('Total weight: 20.00 g'), findsOneWidget);
    });

    testWidgets(
        'GoldBullionScreen displays Direction control, bar weight/quantity, and assay toggle',
        (tester) async {
      final container = createContainer();
      container.read(requestCreateControllerProvider.notifier).selectType(RequestType.goldBullion);

      await tester.pumpWidget(_buildTestApp(const GoldBullionScreen(), container));
      await tester.pumpAndSettle();

      expect(find.text('Buy/Sell Bullions'), findsOneWidget);
      expect(find.byType(DirectionControl), findsOneWidget);
      expect(find.text('Bar weight'), findsOneWidget);
      expect(find.byType(QuantityStepper), findsOneWidget);
      expect(find.text('24K · 999.9'), findsOneWidget);
      expect(find.text('Serial / assay certificate present'), findsOneWidget);
    });

    testWidgets(
        'compose screens share formSurface chrome and ctaFill primary CTA',
        (tester) async {
      Future<void> expectC01Chrome(Widget screen, ProviderContainer container) async {
        await tester.pumpWidget(_buildTestApp(screen, container));
        await tester.pumpAndSettle();

        expect(find.byType(CreateFlowChrome), findsOneWidget);
        expect(find.byType(DraftActions), findsOneWidget);

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(scaffold.backgroundColor, KhTokens.light.formSurface);

        expect(find.byKey(const Key('create-save-draft')), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('create-save-draft')),
            matching: find.byType(Text),
          ),
          findsOneWidget,
        );
        expect(find.byType(FilledButton), findsOneWidget);

        final theme = Theme.of(tester.element(find.byType(FilledButton)));
        final bg = theme.filledButtonTheme.style?.backgroundColor?.resolve({});
        expect(bg, KhTokens.light.ctaFill);
        final shape = theme.filledButtonTheme.style?.shape?.resolve({});
        expect(
          shape,
          isA<RoundedRectangleBorder>().having(
            (b) => b.borderRadius,
            'borderRadius',
            BorderRadius.circular(KhTokens.light.radius.button),
          ),
        );
      }

      final findContainer = createContainer();
      findContainer
          .read(requestCreateControllerProvider.notifier)
          .selectType(RequestType.findOrnament);
      await expectC01Chrome(const FindOrnamentScreen(), findContainer);

      final coinsContainer = createContainer();
      coinsContainer
          .read(requestCreateControllerProvider.notifier)
          .selectType(RequestType.goldCoin);
      await expectC01Chrome(const GoldCoinsScreen(), coinsContainer);
      expect(find.byType(DirectionControl), findsOneWidget);
      expect(find.byType(CoinDenominationChips), findsOneWidget);
      expect(find.byType(BudgetEditor), findsOneWidget);
      expect(find.byType(SellIconFieldGroup), findsNothing);
      expect(find.byType(SellIndicativeValuePanel), findsNothing);
      expect(find.byType(ConditionChips), findsNothing);

      final bullionContainer = createContainer();
      bullionContainer
          .read(requestCreateControllerProvider.notifier)
          .selectType(RequestType.goldBullion);
      await expectC01Chrome(const GoldBullionScreen(), bullionContainer);
      expect(find.byType(DirectionControl), findsOneWidget);
      expect(find.byType(BudgetEditor), findsOneWidget);
      expect(find.byType(SellIconFieldGroup), findsNothing);
      expect(find.byType(SellIndicativeValuePanel), findsNothing);
    });

    testWidgets(
        'Find review shows mosaic, icon rows, Edit text, Publish Request only',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = createContainer();
      final ctrl = container.read(requestCreateControllerProvider.notifier);
      ctrl.selectType(RequestType.findOrnament);
      ctrl.setOrnamentType(OrnamentType.necklace);
      ctrl.setWeightGrams('45');
      ctrl.setWeightApproximate(true);
      ctrl.setPurity(Karat.k22);
      ctrl.setBudgetMax('12000');
      ctrl.setNotes('Bridal set notes');

      await tester.pumpWidget(
        _buildTestApp(const RequestReviewPublishScreen(), container),
      );
      await tester.pumpAndSettle();

      expect(find.text('Find An Ornament'), findsOneWidget);
      expect(find.text('REVIEW YOUR REQUEST'), findsOneWidget);
      expect(find.byType(RequestReviewMosaic), findsOneWidget);
      expect(find.text('Necklace'), findsOneWidget);
      expect(find.text('Approx. 45 grams'), findsOneWidget);
      expect(find.text('22 Karat'), findsOneWidget);
      expect(find.text('Up to AED 12000'), findsOneWidget);
      expect(find.text('Bridal set notes'), findsOneWidget);
      expect(find.byKey(const Key('review-edit')), findsOneWidget);
      expect(find.text('Publish Request'), findsOneWidget);
      expect(find.byKey(const Key('create-save-draft')), findsNothing);
      expect(find.byKey(const Key('review-notes-field')), findsNothing);
    });
  });
}



