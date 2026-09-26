import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/app/session/session_controller.dart';
import 'package:karat_hive/features/request_create/controller/request_create_controller.dart';
import 'package:karat_hive/features/request_create/presentation/find_ornament_screen.dart';
import 'package:karat_hive/features/request_create/presentation/widgets/create_fields.dart';
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
    when(() => repo.categories()).thenAnswer((_) async => const Ok([]));
    when(() => repo.regions()).thenAnswer((_) async => const Ok([]));
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
      expect(find.text('SPECIFY THE PIECE · SELL'), findsOneWidget);
      expect(
        find.textContaining('Photos must be of the actual item'),
        findsOneWidget,
      );
      expect(find.byType(OrnamentTypeChips), findsOneWidget);
      expect(find.byType(BudgetEditor), findsNothing);
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
  });
}
