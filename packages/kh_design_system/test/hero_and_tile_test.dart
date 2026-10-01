import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_design_system/kh_design_system.dart';

import 'golden_runner.dart';

// 1×1 solid PNG (renders blue): stands in for photography without a bundled asset.
final _photo = MemoryImage(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
  ),
);

/// Fails to decode, to exercise the `errorBuilder` fallbacks.
class _BrokenImage extends ImageProvider<_BrokenImage> {
  @override
  Future<_BrokenImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _BrokenImage key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(Future<ImageInfo>.error('broken'));
}

List<KhHeroSlide> _slides({ImageProvider? image}) => [
  for (var i = 1; i <= 3; i++)
    KhHeroSlide(
      lead: 'Lead $i',
      line2: 'Second line',
      line3: 'Third line',
      image: image,
    ),
];

Widget _hero({ImageProvider? image}) => KhHeroCarousel(
  slides: _slides(image: image),
  autoplay: false,
  dotLabel: (i, n) => 'Slide ${i + 1} of $n',
  nextLabel: 'Next slide',
);

Widget _host(Widget child, {double width = 390, double textScale = 1}) =>
    MaterialApp(
      theme: khTheme(),
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 800),
          textScaler: TextScaler.linear(textScale),
        ),
        // Scrollable, like the Home ListView: children get unbounded height.
        child: Scaffold(
          body: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(width: width, child: child),
            ),
          ),
        ),
      ),
    );

void main() {
  group('KhServiceCard', () {
    testWidgets('LTR+RTL golden with photo', (tester) async {
      await expectKhGoldens(
        tester,
        name: 'kh_service_card',
        size: const Size(240, 220),
        builder: () => SizedBox(
          width: 170,
          child: KhServiceCard(
            title: 'Find An Ornament',
            image: _photo,
            onTap: () {},
          ),
        ),
      );
    });

    testWidgets('LTR+RTL golden, placeholder stripes', (tester) async {
      await expectKhGoldens(
        tester,
        name: 'kh_service_card_placeholder',
        size: const Size(240, 220),
        builder: () => SizedBox(
          width: 170,
          child: KhServiceCard(title: 'Sell Old Gold', onTap: () {}),
        ),
      );
    });

    testWidgets('is one tappable semantics node and fires onTap', (t) async {
      var taps = 0;
      await t.pumpWidget(
        _host(
          KhServiceCard(
            title: 'Gold Bullion',
            tapKey: const Key('tile'),
            onTap: () => taps++,
          ),
          width: 170,
        ),
      );
      expect(find.bySemanticsLabel('Gold Bullion'), findsOneWidget);
      await t.tap(find.byKey(const Key('tile')));
      expect(taps, 1);
    });

    testWidgets('falls back to stripes when the photo fails', (t) async {
      await t.pumpWidget(
        _host(
          KhServiceCard(
            title: 'Gold Coin(s)',
            image: _BrokenImage(),
            onTap: () {},
          ),
          width: 170,
        ),
      );
      await t.pump();
      expect(t.takeException(), isNull);
      expect(find.text('Gold Coin(s)'), findsOneWidget);
    });

    testWidgets('grows with the text scale', (t) async {
      Future<double> heightAt(double scale) async {
        await t.pumpWidget(
          _host(
            KhServiceCard(title: 'Find An Ornament', onTap: () {}),
            width: 170,
            textScale: scale,
          ),
        );
        return t.getSize(find.byType(KhServiceCard)).height;
      }

      final base = await heightAt(1);
      final large = await heightAt(1.5);
      expect(large, greaterThan(base));
      // Capped so the grid can't run away at extreme settings.
      expect(await heightAt(3), lessThanOrEqualTo(base * 1.6 + 0.5));
    });
  });

  group('KhHeroCarousel', () {
    testWidgets('LTR+RTL golden with photo', (tester) async {
      await expectKhGoldens(
        tester,
        name: 'kh_hero_carousel',
        size: const Size(390, 300),
        builder: () => SizedBox(width: 358, child: _hero(image: _photo)),
      );
    });

    testWidgets('next button is a labelled 48 px target that advances', (
      t,
    ) async {
      final handle = t.ensureSemantics();
      await t.pumpWidget(_host(_hero(image: _photo)));
      await t.pumpAndSettle();

      final next = find.bySemanticsLabel('Next slide');
      expect(next, findsOneWidget);
      final size = t.getSize(
        find.descendant(of: next, matching: find.byType(SizedBox)).first,
      );
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));

      // Slide 1 is current; the semantics dot for slide 2 becomes selected
      // after the tap. Check via the visible lead text.
      expect(find.text('Lead 1'), findsWidgets);
      await t.tap(next);
      await t.pumpAndSettle();
      final page = t.widget<PageView>(find.byType(PageView));
      expect(page.controller!.page?.round(), 1);
      handle.dispose();
    });

    testWidgets('next wraps from the last slide to the first', (t) async {
      await t.pumpWidget(_host(_hero()));
      final next = find.bySemanticsLabel('Next slide');
      for (var i = 0; i < 3; i++) {
        await t.tap(next);
        await t.pumpAndSettle();
      }
      final page = t.widget<PageView>(find.byType(PageView));
      expect(page.controller!.page?.round(), 0);
    });

    testWidgets('falls back to stripes when the photo fails', (t) async {
      await t.pumpWidget(_host(_hero(image: _BrokenImage())));
      await t.pump();
      expect(t.takeException(), isNull);
      expect(find.text('Lead 1'), findsWidgets);
    });

    testWidgets('is taller on a wide column than on a phone', (t) async {
      // A previous golden may have left a narrow surface behind.
      await t.binding.setSurfaceSize(const Size(1200, 800));
      addTearDown(() => t.binding.setSurfaceSize(null));
      Future<double> heightAt(double w) async {
        await t.pumpWidget(_host(_hero(image: _photo), width: w));
        return t.getSize(find.byType(KhHeroCarousel)).height;
      }

      final phone = await heightAt(358);
      final wide = await heightAt(960);
      expect(phone, greaterThanOrEqualTo(208));
      expect(wide, greaterThan(phone));
      expect(wide, lessThanOrEqualTo(320.5));
    });
  });
}
