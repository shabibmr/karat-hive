import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_avif/flutter_avif.dart' as avif;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import 'media_asset.dart';

/// Re-encodes a picked image on-device before upload. Behind an interface so
/// tests can inject a fake instead of exercising a native encoder binding.
abstract class ImageConverter {
  Future<MediaAsset> convert(File source);

  Future<MediaAsset> convertBytes(Uint8List bytes);
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
  Future<MediaAsset> convert(File source) async {
    final bytes = await source.readAsBytes();
    return convertBytes(Uint8List.fromList(bytes));
  }

  @override
  Future<MediaAsset> convertBytes(Uint8List bytes) async {
    final input = await downscaleForUpload(bytes, maxDimension: maxDimension);
    final avifBytes = await avif.encodeAvif(input);
    return _toAsset(avifBytes, contentType: 'image/avif', extension: 'avif');
  }
}

/// Encodes via `flutter_image_compress` (libwebp on Android, SDWebImage on
/// iOS) — several times faster than AVIF for a modest size cost, which is
/// why Request images use it. Metadata is dropped (`keepExif` defaults to
/// false) and EXIF orientation is applied before encoding.
///
/// Native-only: the plugin has no WebP encoder on web.
class WebpImageConverter implements ImageConverter {
  const WebpImageConverter({this.maxDimension = 2048, this.quality = 80});

  final int maxDimension;

  /// libwebp lossy quality, 0–100.
  final int quality;

  @override
  Future<MediaAsset> convert(File source) async {
    final bytes = await source.readAsBytes();
    return convertBytes(Uint8List.fromList(bytes));
  }

  @override
  Future<MediaAsset> convertBytes(Uint8List bytes) async {
    final input = await downscaleForUpload(bytes, maxDimension: maxDimension);
    // The plugin only ever shrinks to fit min{Width,Height}; `input` already
    // fits inside maxDimension², so this bound never resizes again.
    final webpBytes = await FlutterImageCompress.compressWithList(
      input,
      minWidth: maxDimension,
      minHeight: maxDimension,
      quality: quality,
      format: CompressFormat.webp,
    );
    return _toAsset(webpBytes, contentType: 'image/webp', extension: 'webp');
  }
}

Future<MediaAsset> _toAsset(
  Uint8List bytes, {
  required String contentType,
  required String extension,
}) async {
  if (kIsWeb) {
    return MediaAsset(
      bytes: bytes,
      contentType: contentType,
      byteSize: bytes.length,
    );
  }
  final dir = await getTemporaryDirectory();
  final outPath =
      '${dir.path}/kh_media_${DateTime.now().microsecondsSinceEpoch}.$extension';
  final outFile = await File(outPath).writeAsBytes(bytes, flush: true);
  return MediaAsset(
    file: outFile,
    bytes: bytes,
    contentType: contentType,
    byteSize: bytes.length,
  );
}

/// Returns [bytes] unchanged when the image's long edge is already within
/// [maxDimension]; otherwise a PNG scaled to fit, aspect ratio preserved.
///
/// Decoding through the engine applies EXIF orientation, so the result is
/// upright — the same image the encoder would have decoded itself.
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
