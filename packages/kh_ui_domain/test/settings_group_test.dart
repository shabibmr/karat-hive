import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

Widget _host(
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
}) =>
    MaterialApp(
      theme: khTheme(),
      home: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          body: SingleChildScrollView(child: child),
        ),
      ),
    );

void main() {
  group('SettingsGroup', () {
    testWidgets('renders with title and description', (tester) async {
      await tester.pumpWidget(
        _host(
          const SettingsGroup(
            title: 'Account Settings',
            description: 'Manage your account preferences and profile details.',
            children: [
              Text('Child Row 1'),
              Text('Child Row 2'),
            ],
          ),
        ),
      );

      expect(find.text('Account Settings'), findsOneWidget);
      expect(
        find.text('Manage your account preferences and profile details.'),
        findsOneWidget,
      );
      expect(find.text('Child Row 1'), findsOneWidget);
      expect(find.text('Child Row 2'), findsOneWidget);
    });

    testWidgets('does not render header widgets when title and description are null',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const SettingsGroup(
            children: [
              Text('Only Row'),
            ],
          ),
        ),
      );

      expect(find.text('Only Row'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('verifies dividers are placed between children in SettingsGroup',
        (tester) async {
      // 3 children should have exactly 2 dividers between them
      await tester.pumpWidget(
        _host(
          const SettingsGroup(
            title: 'Notifications',
            children: [
              Text('Item A'),
              Text('Item B'),
              Text('Item C'),
            ],
          ),
        ),
      );

      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.text('Item A'), findsOneWidget);
      expect(find.text('Item B'), findsOneWidget);
      expect(find.text('Item C'), findsOneWidget);
    });

    testWidgets('renders no dividers when single child is provided', (tester) async {
      await tester.pumpWidget(
        _host(
          const SettingsGroup(
            children: [
              Text('Single Item'),
            ],
          ),
        ),
      );

      expect(find.byType(Divider), findsNothing);
      expect(find.text('Single Item'), findsOneWidget);
    });

    testWidgets('renders no dividers when children list is empty', (tester) async {
      await tester.pumpWidget(
        _host(
          const SettingsGroup(
            children: [],
          ),
        ),
      );

      expect(find.byType(Divider), findsNothing);
      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('SettingRow', () {
    testWidgets(
        'renders with String title, subtitle, leadingIcon (IconData), and trailing widget',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const SettingRow(
            title: 'Push Notifications',
            subtitle: 'Receive alerts for new offers',
            leadingIcon: Icons.notifications_active_outlined,
            trailing: Switch(value: true, onChanged: null),
          ),
        ),
      );

      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Receive alerts for new offers'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active_outlined), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
      // No chevron should be shown since trailing widget is provided
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets(
        'renders with Widget title, Widget subtitle, and Widget leadingIcon',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const SettingRow(
            title: KeyedSubtree(
              key: Key('custom-title'),
              child: Text('Custom Title Widget'),
            ),
            subtitle: KeyedSubtree(
              key: Key('custom-subtitle'),
              child: Text('Custom Subtitle Widget'),
            ),
            leadingIcon: KeyedSubtree(
              key: Key('custom-leading'),
              child: Icon(Icons.star),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom-title')), findsOneWidget);
      expect(find.text('Custom Title Widget'), findsOneWidget);
      expect(find.byKey(const Key('custom-subtitle')), findsOneWidget);
      expect(find.text('Custom Subtitle Widget'), findsOneWidget);
      expect(find.byKey(const Key('custom-leading')), findsOneWidget);
    });

    testWidgets('renders chevron in LTR when showChevron is true and trailing is null',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const SettingRow(
            title: 'Security',
            showChevron: true,
          ),
          textDirection: TextDirection.ltr,
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsNothing);
    });

    testWidgets('renders chevron in RTL when showChevron is true and trailing is null',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const SettingRow(
            title: 'الأمان',
            showChevron: true,
          ),
          textDirection: TextDirection.rtl,
        ),
      );

      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets(
        'does not render chevron when showChevron is true but trailing is provided',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const SettingRow(
            title: 'Language',
            showChevron: true,
            trailing: Text('English'),
          ),
        ),
      );

      expect(find.text('English'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byIcon(Icons.chevron_left), findsNothing);
    });

    testWidgets('does not render chevron when showChevron is false and trailing is null',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const SettingRow(
            title: 'Simple Row',
            showChevron: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byIcon(Icons.chevron_left), findsNothing);
    });

    testWidgets('tapping SettingRow triggers onTap and renders InkWell',
        (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        _host(
          SettingRow(
            title: 'Tappable Row',
            onTap: () {
              tapCount++;
            },
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);

      await tester.tap(find.text('Tappable Row'));
      await tester.pumpAndSettle();

      expect(tapCount, 1);

      await tester.tap(find.byType(SettingRow));
      await tester.pumpAndSettle();

      expect(tapCount, 2);
    });

    testWidgets('does not render InkWell when onTap is null', (tester) async {
      await tester.pumpWidget(
        _host(
          const SettingRow(
            title: 'Non-tappable Row',
            onTap: null,
          ),
        ),
      );

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('renders SettingRows inside SettingsGroup with full integration',
        (tester) async {
      var row1Tapped = false;
      var row2Tapped = false;

      await tester.pumpWidget(
        _host(
          SettingsGroup(
            title: 'Preferences',
            description: 'App preferences and configurations',
            children: [
              SettingRow(
                title: 'Row 1',
                subtitle: 'First row subtitle',
                leadingIcon: Icons.settings,
                showChevron: true,
                onTap: () => row1Tapped = true,
              ),
              SettingRow(
                title: 'Row 2',
                subtitle: 'Second row subtitle',
                leadingIcon: Icons.tune,
                trailing: const Icon(Icons.check),
                onTap: () => row2Tapped = true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('App preferences and configurations'), findsOneWidget);
      expect(find.text('Row 1'), findsOneWidget);
      expect(find.text('First row subtitle'), findsOneWidget);
      expect(find.text('Row 2'), findsOneWidget);
      expect(find.text('Second row subtitle'), findsOneWidget);

      // 2 children in SettingsGroup -> 1 divider
      expect(find.byType(Divider), findsOneWidget);

      // Row 1 has chevron
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      // Row 2 has trailing check icon
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Row 1'));
      await tester.pumpAndSettle();
      expect(row1Tapped, isTrue);

      await tester.tap(find.text('Row 2'));
      await tester.pumpAndSettle();
      expect(row2Tapped, isTrue);
    });
  });
}
