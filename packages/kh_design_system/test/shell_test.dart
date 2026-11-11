import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: khTheme(),
    home: child,
  );
}

const _destinations = [
  KhNavDestination(label: 'Home', icon: Icons.home_outlined, selectedIcon: Icons.home),
  KhNavDestination(label: 'Connections', icon: Icons.link_outlined, selectedIcon: Icons.link),
  KhNavDestination(
    label: 'Alerts',
    icon: Icons.notifications_outlined,
    selectedIcon: Icons.notifications,
    badgeCount: 2,
  ),
];

void main() {
  testWidgets('KhAppBar shows title and actions (SH-SHELL-02)', (tester) async {
    var back = false;
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          appBar: KhAppBar(
            title: 'Request detail',
            onBack: () => back = true,
            actions: const [Icon(Icons.filter_list)],
          ),
          body: const SizedBox.shrink(),
        ),
      ),
    );

    expect(find.text('Request detail'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    expect(back, isTrue);
    expect(find.byIcon(Icons.filter_list), findsOneWidget);
  });

  testWidgets('KhBottomNav uses parameter labels, not hardcoded destinations (SH-SHELL-03)',
      (tester) async {
    var index = 0;
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: const SizedBox.shrink(),
          bottomNavigationBar: KhBottomNav(
            destinations: _destinations,
            currentIndex: index,
            onDestinationSelected: (i) => index = i,
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Connections'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Feed'), findsNothing);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('Connections'));
    expect(index, 1);
  });

  testWidgets('KhAppShell composes app bar, body, and configurable nav (SH-SHELL-01)',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        KhAppShell(
          title: 'Home',
          destinations: _destinations,
          currentIndex: 0,
          onDestinationSelected: (_) {},
          body: const Text('shell-body'),
        ),
      ),
    );

    expect(find.byType(KhAppBar), findsOneWidget);
    expect(find.byType(KhBottomNav), findsOneWidget);
    expect(find.text('shell-body'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('KhPullToRefresh shows lastUpdated and hosts RefreshIndicator (SH-SHELL-06)',
      (tester) async {
    var refreshed = false;
    await tester.pumpWidget(
      _wrap(
        Scaffold(
          body: KhPullToRefresh(
            lastUpdated: 'Updated 2 m ago',
            onRefresh: () async {
              refreshed = true;
            },
            child: ListView(
              children: const [SizedBox(height: 800, child: Text('list-item'))],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Updated 2 m ago'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);
    await tester.fling(find.text('list-item'), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(refreshed, isTrue);
    await tester.pumpAndSettle();
  });

  testWidgets('KhScaffold keeps the page full bleed and caps the body at 560',
      (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _wrap(
        const KhScaffold(
          title: 'Dashboard',
          body: SizedBox(key: Key('probe'), width: double.infinity, height: 8),
        ),
      ),
    );

    expect(tester.getSize(find.byType(Scaffold)).width, 1024);
    expect(tester.getSize(find.byKey(const Key('probe'))).width, 560);
  });

  testWidgets('KhScaffold pull-to-refresh still fires at 1024 wide', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var refreshed = false;
    await tester.pumpWidget(
      _wrap(
        KhScaffold(
          title: 'Dashboard',
          onRefresh: () async {
            refreshed = true;
          },
          body: ListView(
            children: const [SizedBox(height: 1200, child: Text('wide-item'))],
          ),
        ),
      ),
    );

    await tester.fling(find.text('wide-item'), const Offset(0, 300), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(refreshed, isTrue);
    await tester.pumpAndSettle();
  });

  test('nav bar height grows with text scale and labels collapse under 360', () {
    expect(khNavBarHeight(TextScaler.noScaling), 80);
    expect(khNavBarHeight(const TextScaler.linear(2)), 82);
    expect(
      khNavLabelBehavior(359),
      NavigationDestinationLabelBehavior.onlyShowSelected,
    );
    expect(
      khNavLabelBehavior(360),
      NavigationDestinationLabelBehavior.alwaysShow,
    );
  });

  testWidgets('editorial nav keeps every label at text scale 2', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(2),
            ),
            child: child!,
          );
        },
        home: Scaffold(
          bottomNavigationBar: KhBottomNav(
            editorial: true,
            currentIndex: 0,
            onDestinationSelected: (_) {},
            destinations: const [
              KhNavDestination(label: 'Home', icon: Icons.home_outlined),
              KhNavDestination(
                label: 'My Requests',
                icon: Icons.list_alt_outlined,
              ),
              KhNavDestination(label: 'Connections', icon: Icons.link_outlined),
              KhNavDestination(label: 'Profile', icon: Icons.person_outline),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('My Requests'), findsOneWidget);
    expect(find.text('Connections'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(tester.getSize(find.byType(NavigationBar)).height, 82);
    expect(tester.takeException(), isNull);
  });
}
