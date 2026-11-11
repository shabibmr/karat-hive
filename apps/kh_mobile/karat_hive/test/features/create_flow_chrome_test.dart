import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/request_create/presentation/widgets/create_flow_chrome.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

void main() {
  Widget host(Widget child, {double width = 400, double textScale = 1}) {
    return MaterialApp(
      theme: khTheme(),
      locale: const Locale('en'),
      localizationsDelegates: KhStrings.delegates,
      supportedLocales: KhStrings.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    );
  }

  DraftActions actions() => DraftActions(
    busy: false,
    onSaveDraft: () {},
    onContinue: () {},
  );

  test('header height is 60 at scale 1 and 90 at scale 2', () {
    expect(createFlowHeaderHeight(TextScaler.noScaling), 60);
    expect(createFlowHeaderHeight(const TextScaler.linear(2)), 90);
  });

  testWidgets('header grows to 90 at text scale 2', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            appBar: CreateFlowHeader(
              title: 'Find',
              height: 90,
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(CreateFlowHeader)).height, 90);
    expect(tester.takeException(), isNull);
  });

  testWidgets('draft actions stay in a row at 400 and scale 1', (tester) async {
    await tester.pumpWidget(host(actions()));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Flex>(find.byKey(const Key('create-draft-actions'))),
      isA<Row>(),
    );
  });

  testWidgets('draft actions stay in a row at 390 and scale 1', (tester) async {
    await tester.pumpWidget(host(actions(), width: 390));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Flex>(find.byKey(const Key('create-draft-actions'))),
      isA<Row>(),
    );
  });

  testWidgets('draft actions stack below 360', (tester) async {
    await tester.pumpWidget(host(actions(), width: 320));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Flex>(find.byKey(const Key('create-draft-actions'))),
      isA<Column>(),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('create-save-draft'))).dy,
      lessThan(tester.getTopLeft(find.text('Continue')).dy),
    );
  });

  testWidgets('draft actions stack at text scale 1.4', (tester) async {
    await tester.pumpWidget(host(actions(), textScale: 1.4));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Flex>(find.byKey(const Key('create-draft-actions'))),
      isA<Column>(),
    );
  });

  testWidgets('create column is 560 wide on a 1024 surface', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        localizationsDelegates: KhStrings.delegates,
        supportedLocales: KhStrings.supportedLocales,
        home: CreateFlowChrome(
          title: 'Find',
          child: const SizedBox(
            key: Key('create-probe'),
            width: double.infinity,
            height: 8,
          ),
          bottom: actions(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byKey(const Key('create-probe'))).width, 560);
  });
}
