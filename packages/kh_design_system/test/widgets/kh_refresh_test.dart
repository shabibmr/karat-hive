import 'dart:async';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

Widget createRefreshTestApp({
  required RefreshCallback onRefresh,
  TargetPlatform platform = TargetPlatform.android,
  DateTime? lastUpdated,
  Color? color,
  Color? backgroundColor,
}) {
  return MaterialApp(
    theme: ThemeData(
      platform: platform,
      extensions: const [KhTokens.light],
    ),
    home: Scaffold(
      body: KhRefresh(
        onRefresh: onRefresh,
        lastUpdated: lastUpdated,
        color: color,
        backgroundColor: backgroundColor,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: 20,
          itemBuilder: (context, index) => ListTile(
            title: Text('Item $index'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('KhRefresh / KhPullToRefresh (SH-SHELL-06)', () {
    testWidgets('renders wrapped scrollable child items', (tester) async {
      await tester.pumpWidget(
        createRefreshTestApp(onRefresh: () async {}),
      );

      expect(find.byKey(const Key('kh-refresh-indicator')), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('invokes onRefresh and shows indicator during drag, then completes',
        (tester) async {
      final completer = Completer<void>();
      var refreshCount = 0;

      await tester.pumpWidget(
        createRefreshTestApp(
          onRefresh: () async {
            refreshCount++;
            return completer.future;
          },
        ),
      );

      // Perform downward pull gesture
      await tester.fling(find.text('Item 0'), const Offset(0.0, 300.0), 1000.0);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1)); // allow animation to settle at displacement

      expect(refreshCount, 1);
      // Progress indicator is active
      expect(find.byType(RefreshProgressIndicator), findsOneWidget);

      // Complete async refresh
      completer.complete();
      await tester.pumpAndSettle();

      // Indicator should be dismissed after completion
      expect(find.byType(RefreshProgressIndicator), findsNothing);
    });

    testWidgets('adapts to iOS platform showing CupertinoActivityIndicator',
        (tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(
        createRefreshTestApp(
          platform: TargetPlatform.iOS,
          onRefresh: () => completer.future,
        ),
      );

      await tester.fling(find.text('Item 0'), const Offset(0.0, 300.0), 1000.0);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // On iOS, adaptive indicator uses CupertinoActivityIndicator
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('supports custom colors and lastUpdated timestamp', (tester) async {
      final timestamp = DateTime(2026, 9, 7, 10, 30);
      const customGold = Color(0xFFFFD700);
      const customBg = Color(0xFF1E1E1E);

      final widget = KhRefresh(
        onRefresh: () async {},
        lastUpdated: timestamp,
        color: customGold,
        backgroundColor: customBg,
        child: const SingleChildScrollView(child: Text('Content')),
      );

      expect(widget.lastUpdated, timestamp);
      expect(widget.color, customGold);
      expect(widget.backgroundColor, customBg);
    });
  });
}
