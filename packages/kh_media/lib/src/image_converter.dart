import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_avif/flutter_avif.dart' as avif;
import 'package:path_provider/path_provider.dart';

import 'media_asset.dart';

/// Converts a picked image to AVIF on-device. Behind an interface so tests
/// can inject a fake instead of exercising the native libavif binding.
abstract class ImageConverter {
  Future<MediaAsset> convertToAvif(File source);

  Future<MediaAsset> convertBytesToAvif(Uint8List bytes);
}

/// Encodes via `flutter_avif` (libavif) on every platform, including web.
/// Native also writes a temp file so [PendingUploadCache] can retry.
///
/// Photos whose long edge exceeds [maxDimension] are downscaled first —
/// AVIF encode time scales with pixel count, and a 12 MP camera photo
/// otherwise takes seconds (tens of seconds on web WASM) per image.
class AvifImageConverter implements ImageConverter {
  const AvifImageConverter({this.maxDimension = 2048});

  final int maxDimension;

  @override
  Future<MediaAsset> convertToAvif(File source) async {
    final bytes = await source.readAsBytes();
    return convertBytesToAvif(Uint8List.fromList(bytes));
  }

  @override
  Future<MediaAsset> convertBytesToAvif(Uint8List bytes) async {
    final input = await downscaleForUpload(bytes, maxDimension: maxDimension);
    final avifBytes = await avif.encodeAvif(input);
    if (kIsWeb) {
      return MediaAsset(
        bytes: avifBytes,
        contentType: 'image/avif',
        byteSize: avifBytes.length,
      );
    }
    final dir = await getTemporaryDirectory();
    final outPath =
        '${dir.path}/kh_media_${DateTime.now().microsecondsSinceEpoch}.avif';
    final outFile = await File(outPath).writeAsBytes(avifBytes, flush: true);
    return MediaAsset(
      file: outFile,
      bytes: avifBytes,
      contentType: 'image/avif',
      byteSize: avifBytes.length,
    );
  }
}

/// Returns [bytes] unchanged when the image's long edge is already within
/// [maxDimension]; otherwise a PNG scaled to fit, aspect ratio preserved.
///
/// Decoding through the engine applies EXIF orientation, so the result is
/// upright — the same image `encodeAvif` would have decoded itself.
Future<Uint8List> downscaleForUpload(
  Uint8List bytes, {
  required int maxDimension,
}) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final source = (await codec.getNextFrame()).image;
  codec.dispose();
  try {
    final longEdge =
        source.width > source.height ? source.width : source.height;
    if (longEdge <= maxDimension) return bytes;

    final scale = maxDimension / longEdge;
    final width = (source.width * scale).round().clamp(1, maxDimension);
    final height = (source.height * scale).round().clamp(1, maxDimension);

    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder).drawImageRect(
      source,
      ui.Rect.fromLTWH(0, 0, source.width.toDouble(), source.height.toDouble()),
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.medium,
    );
    final picture = recorder.endRecording();
    final scaled = await picture.toImage(width, height);
    picture.dispose();
    try {
      final png = await scaled.toByteData(format: ui.ImageByteFormat.png);
      if (png == null) return bytes;
      return png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes);
    } finally {
      scaled.dispose();
    }
  } finally {
    source.dispose();
  }
}
