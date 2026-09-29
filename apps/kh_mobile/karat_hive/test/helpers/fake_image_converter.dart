import 'dart:io';
import 'dart:typed_data';

import 'package:kh_media/kh_media.dart';

/// Relabels bytes as WebP — skips the native encoder binding in unit tests.
class FakeImageConverter implements ImageConverter {
  FakeImageConverter({this.throwOnConvert = false});

  bool throwOnConvert;
  int convertCalls = 0;

  @override
  Future<MediaAsset> convert(File source) async {
    final bytes = await source.readAsBytes();
    return convertBytes(Uint8List.fromList(bytes));
  }

  @override
  Future<MediaAsset> convertBytes(Uint8List bytes) async {
    convertCalls++;
    if (throwOnConvert) {
      throw StateError('encode failed');
    }
    return MediaAsset(
      bytes: bytes,
      contentType: 'image/webp',
      byteSize: bytes.length,
    );
  }
}
