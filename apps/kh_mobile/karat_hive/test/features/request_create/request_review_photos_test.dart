import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/request_create/controller/request_create_state.dart';
import 'package:karat_hive/features/request_create/presentation/widgets/request_images_section.dart';
import 'package:kh_design_system/kh_design_system.dart';
import 'package:kh_l10n/kh_l10n.dart';

void main() {
  testWidgets('RequestMediaGallery shows thumbnails from localBytes',
      (tester) async {
    // 1x1 PNG
    final bytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
      0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
      0x00, 0x00, 0x03, 0x00, 0x01, 0x00, 0x05, 0xFE, 0x02, 0xFE, 0xDC, 0xCC,
      0x59, 0xE7, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
      0x60, 0x82,
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        localizationsDelegates: KhStrings.delegates,
        supportedLocales: KhStrings.supportedLocales,
        home: Scaffold(
          body: RequestMediaGallery(
            media: [
              MediaSlot(
                key: 'uploaded-key-1',
                localLabel: 'ring.png',
                localBytes: bytes,
                contentType: 'image/png',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('review-photo-0')), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Photos'), findsOneWidget);
  });

  testWidgets('RequestMediaGallery empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        localizationsDelegates: KhStrings.delegates,
        supportedLocales: KhStrings.supportedLocales,
        home: const Scaffold(
          body: RequestMediaGallery(media: []),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('review-photo-0')), findsNothing);
    expect(find.text('No photos attached'), findsOneWidget);
  });

  testWidgets(
      'RequestMediaGallery uses KhNetworkImage for remote AVIF reopen slots',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: khTheme(),
        localizationsDelegates: KhStrings.delegates,
        supportedLocales: KhStrings.supportedLocales,
        home: const Scaffold(
          body: RequestMediaGallery(
            media: [
              MediaSlot(
                key: 'media-uuid-1',
                contentType: 'image/avif',
                remoteUrl: 'http://127.0.0.1:9/v1/media/media-uuid-1',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('review-photo-0')), findsOneWidget);
    expect(find.byType(KhNetworkImage), findsOneWidget);
  });
}
