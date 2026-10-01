import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

class FakeFailingCacheManager implements BaseCacheManager {
  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool? withProgress,
  }) async* {
    throw Exception('Failed to load image');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    KhNetworkImage.defaultCacheManager = FakeFailingCacheManager();
  });

  tearDown(() {
    KhNetworkImage.defaultCacheManager = null;
    KhNetworkImage.urlResolver = null;
  });

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
    expect(find.byType(CachedNetworkImage), findsNothing);
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

  testWidgets('routes non-AVIF content types through CachedNetworkImage', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KhNetworkImage(url: 'https://example.com/logo.jpg'),
        ),
      ),
    );

    expect(find.byType(CachedNetworkImage), findsOneWidget);
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
    await tester.pump();

    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });

  testWidgets('invokes a custom errorBuilder instead of the default icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KhNetworkImage(
            url: 'https://example.com/logo.jpg',
            errorBuilder: (_, _, _) => const Text('custom-error'),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('custom-error'), findsOneWidget);
    expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
  });

  group('resolve', () {
    tearDown(() => KhNetworkImage.urlResolver = null);

    test('resolves relative backend media paths through urlResolver', () {
      KhNetworkImage.urlResolver = (p) => 'https://api.example$p';
      expect(
        KhNetworkImage.resolve('/v1/media/abc.thumb'),
        'https://api.example/v1/media/abc.thumb',
      );
    });

    test('passes absolute URLs through untouched', () {
      KhNetworkImage.urlResolver = (p) => 'https://api.example$p';
      expect(
        KhNetworkImage.resolve('https://cdn.example/x.jpg'),
        'https://cdn.example/x.jpg',
      );
    });

    test('returns the input when no resolver is set', () {
      expect(KhNetworkImage.resolve('/v1/media/abc'), '/v1/media/abc');
    });
  });
}
