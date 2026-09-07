import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_ui_domain/kh_ui_domain.dart';

TalkPayload _talk({
  bool available = true,
  String waUrl = 'https://wa.me/971501234567?text=Hello',
  String callUrl = 'tel:+971501234567',
}) =>
    TalkPayload(
      waUrl: waUrl,
      mobileNumber: '+971501234567',
      available: available,
      callUrl: callUrl,
    );

Widget _host(Widget child) => MaterialApp(
      theme: khTheme(),
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('SH-CON-01 shows name, reference, price; Talk only when Active',
      (tester) async {
    await tester.pumpWidget(
      _host(
        ConnectionSummaryRow(
          connectionId: 'conn-1',
          counterpartyName: 'Fatima Al Zahra',
          state: ConnectionState.active,
          requestReference: 'KH-RQ-24A1',
          offeredPrice: '12500.00',
          connectedAt: DateTime.utc(2026, 9, 1, 12),
          onTalk: () {},
          onTap: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('connection-summary-conn-1')), findsOneWidget);
    expect(find.text('Fatima Al Zahra'), findsOneWidget);
    expect(find.text('KH-RQ-24A1'), findsOneWidget);
    expect(find.textContaining('AED'), findsWidgets);
    expect(find.byKey(const Key('connection-talk-shortcut-conn-1')), findsOneWidget);
  });

  testWidgets('SH-CON-01 hides Talk shortcut when Closed', (tester) async {
    await tester.pumpWidget(
      _host(
        ConnectionSummaryRow(
          connectionId: 'conn-2',
          counterpartyName: 'Fatima Al Zahra',
          state: ConnectionState.closed,
          onTalk: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('connection-talk-shortcut-conn-2')), findsNothing);
  });

  testWidgets('SH-CON-02 does not invent a wa.me URL when waUrl is missing',
      (tester) async {
    await tester.pumpWidget(
      _host(
        TalkButton(
          talk: _talk(waUrl: '', available: true),
          onTalk: () {},
        ),
      ),
    );

    expect(find.byKey(const Key('talk-button')), findsNothing);
    expect(find.byKey(const Key('inline-error')), findsOneWidget);
    expect(find.textContaining('wa.me'), findsNothing);
  });

  testWidgets('SH-CON-02 Talk is enabled when waUrl is present', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _host(
        TalkButton(
          talk: _talk(),
          onTalk: () => tapped = true,
        ),
      ),
    );

    expect(find.byKey(const Key('talk-button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('talk-button')));
    expect(tapped, isTrue);
  });

  testWidgets('SH-CON-03 disables call when callUrl is absent', (tester) async {
    await tester.pumpWidget(
      _host(
        TapToCallControl(
          mobileNumber: '+971501234567',
          callUrl: '',
          onCall: () {},
        ),
      ),
    );

    final button = tester.widget<IconButton>(
      find.byKey(const Key('tap-to-call-button')),
    );
    expect(button.onPressed, isNull);
    expect(find.byKey(const Key('kh-copy-control')), findsOneWidget);
  });

  testWidgets('SH-ID-02 renders revealed name and mobile', (tester) async {
    await tester.pumpWidget(
      _host(
        RevealedPartyCard(
          party: RevealedParty(
            displayName: 'Fatima Al Zahra',
            mobile: PhoneNumber.parse('+971501234567'),
            role: UserRole.customer,
            dealCount: 3,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('revealed-party-card')), findsOneWidget);
    expect(find.text('Fatima Al Zahra'), findsOneWidget);
    expect(find.textContaining('+971501234567'), findsOneWidget);
  });

  testWidgets('SH-CON-04 closed banner is visible', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ConnectionClosedBanner()),
    ));
    expect(find.byKey(const Key('connection-closed-banner')), findsOneWidget);
  });
}
