import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/request_create/presentation/widgets/create_flow_chrome.dart';
import 'package:kh_design_system/kh_design_system.dart';

void main() {
  testWidgets('create header and action sit clear of the phone system bars', (
    tester,
  ) async {
    const size = Size(390, 844);
    const statusBar = 47.0;
    const homeIndicator = 34.0;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: KhTheme.light(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.only(top: statusBar, bottom: homeIndicator),
              viewPadding: const EdgeInsets.only(
                top: statusBar,
                bottom: homeIndicator,
              ),
            ),
            child: child!,
          );
        },
        home: CreateFlowChrome(
          title: 'Find an ornament',
          eyebrow: 'Specify the piece',
          onBack: () {},
          bottom: const Text('Continue', key: Key('continue-label')),
          child: const SizedBox.expand(),
        ),
      ),
    );

    final back = tester.getRect(find.byKey(const Key('create-flow-back')));
    expect(back.top, greaterThanOrEqualTo(statusBar));
    expect(back.width, inInclusiveRange(32, 40));
    expect(back.height, inInclusiveRange(32, 40));

    final title = tester.getTopLeft(find.text('Find an ornament'));
    expect(title.dy, greaterThanOrEqualTo(statusBar));

    final action = tester.getRect(find.byKey(const Key('continue-label')));
    expect(action.bottom, lessThanOrEqualTo(size.height - homeIndicator));
    expect(tester.takeException(), isNull);
  });

  testWidgets('app inset and create header do not pad the status bar twice', (
    tester,
  ) async {
    const size = Size(390, 844);
    const statusBar = 47.0;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: KhTheme.light(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.only(top: statusBar, bottom: 34),
              viewPadding: const EdgeInsets.only(top: statusBar, bottom: 34),
            ),
            child: KhSystemInset(child: child!),
          );
        },
        home: CreateFlowChrome(
          title: 'Find an ornament',
          onBack: () {},
          child: const SizedBox.expand(),
        ),
      ),
    );

    final back = tester.getRect(find.byKey(const Key('create-flow-back')));
    expect(back.top, greaterThanOrEqualTo(statusBar));
    expect(back.top, lessThan(statusBar + 24));
  });
}
