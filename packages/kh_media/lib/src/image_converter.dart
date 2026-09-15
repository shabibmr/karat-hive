import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_avif/flutter_avif.dart' as avif;
import 'package:path_provider/path_provider.dart';

import 'media_asset.dart';

/// Converts a picked image to AVIF on-device. Behind an interface so tests
/// can inject a fake instead of exercising the native libavif binding.
abstract class ImageConverter {
  Future<MediaAsset> convertToAvif(File source);

  Future<MediaAsset> convertBytesToAvif(Uint8List bytes);
}

/// Encodes via `flutter_avif` (libavif) and writes the result to the app's
/// temp directory so it can be picked up again for cache/retry.
class AvifImageConverter implements ImageConverter {
  const AvifImageConverter();

  @override
  Future<MediaAsset> convertToAvif(File source) async {
    final bytes = await source.readAsBytes();
    return convertBytesToAvif(Uint8List.fromList(bytes));
  }

  @override
  Future<MediaAsset> convertBytesToAvif(Uint8List bytes) async {
    final avifBytes = await avif.encodeAvif(bytes);
    final dir = await getTemporaryDirectory();
    final outPath =
        '${dir.path}/kh_media_${DateTime.now().microsecondsSinceEpoch}.avif';
    final outFile = await File(outPath).writeAsBytes(avifBytes, flush: true);
    return MediaAsset(
      file: outFile,
      contentType: 'image/avif',
      byteSize: avifBytes.length,
    );
  }
}
