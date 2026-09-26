import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

void main() {
  testWidgets('routes image/avif content type through AvifImage', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KhNetworkImage(
            url: 'https://example.com/logo',
            contentType: 'image/avif',
          ),
        ),
      ),
    );

    expect(find.byType(AvifImage), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('routes a .avif URL through AvifImage even with a default contentType',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KhNetworkImage(url: 'https://example.com/logo.AVIF'),
        ),
      ),
    );

    expect(find.byType(AvifImage), findsOneWidget);
  });

  testWidgets('routes non-AVIF content types through Image.network', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KhNetworkImage(url: 'https://example.com/logo.jpg'),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(AvifImage), findsNothing);
  });

  testWidgets('falls back to a broken-image icon when no errorBuilder is supplied',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KhNetworkImage(url: 'https://example.com/logo.jpg'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });

  testWidgets('invokes a custom errorBuilder instead of the default icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KhNetworkImage(
            url: 'https://example.com/logo.jpg',
            errorBuilder: (_, __, ___) => const Text('custom-error'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('custom-error'), findsOneWidget);
    expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
  });
}
