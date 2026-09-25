import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:kh_media/kh_media.dart';

Future<Uint8List> _png(int width, int height) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()..color = const ui.Color(0xFFD4AF37),
  );
  final image = await recorder.endRecording().toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

Future<(int, int)> _size(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final image = (await codec.getNextFrame()).image;
  return (image.width, image.height);
}

void main() {
  test('downscales the long edge to maxDimension, keeping aspect ratio',
      () async {
    final input = await _png(400, 300);
    final out = await downscaleForUpload(input, maxDimension: 200);
    expect(await _size(out), (200, 150));
  });

  test('portrait images are bounded by height', () async {
    final input = await _png(300, 400);
    final out = await downscaleForUpload(input, maxDimension: 200);
    expect(await _size(out), (150, 200));
  });

  test('images already within bounds are returned untouched', () async {
    final input = await _png(120, 80);
    final out = await downscaleForUpload(input, maxDimension: 200);
    expect(identical(out, input), isTrue);
  });
}
