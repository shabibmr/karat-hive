import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

void main() {
  testWidgets('shows placeholder and pick label when empty', (tester) async {
    var picked = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: Scaffold(
          body: KhLogoPicker(onPick: () => picked = true),
        ),
      ),
    );

    expect(find.text('Logo'), findsOneWidget);
    expect(find.text('Upload logo'), findsOneWidget);
    expect(find.text('Remove'), findsNothing);

    await tester.tap(find.byIcon(Icons.add_a_photo_outlined));
    expect(picked, isTrue);
  });

  testWidgets('shows change/remove once a logoUrl is set', (tester) async {
    var removed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: Scaffold(
          body: KhLogoPicker(
            onPick: () {},
            onRemove: () => removed = true,
            logoUrl: '/v1/media/logo-key-abc',
          ),
        ),
      ),
    );

    expect(find.text('Change logo'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);

    await tester.tap(find.text('Remove'));
    expect(removed, isTrue);
  });

  testWidgets('prefers previewBytes over logoUrl', (tester) async {
    // Minimal 1x1 transparent PNG, so Image.memory decodes without error.
    final onePxPng = Uint8List.fromList(const [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x60, 0x60, 0x60, 0x60,
      0x00, 0x00, 0x00, 0x05, 0x00, 0x01, 0xA5, 0xF6, 0x45, 0x40, 0x00, 0x00,
      0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ]);
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: Scaffold(
          body: KhLogoPicker(
            onPick: () {},
            logoUrl: '/v1/media/logo-key-abc',
            previewBytes: onePxPng,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(KhNetworkImage), findsNothing);
  });

  testWidgets('shows a spinner and disables taps while busy', (tester) async {
    var picked = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        home: Scaffold(
          body: KhLogoPicker(onPick: () => picked = true, busy: true),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('Upload logo'), warnIfMissed: false);
    expect(picked, isFalse);
  });
}
