import 'dart:io';
import 'dart:typed_data';

import 'package:kh_media/kh_media.dart';

/// Relabels bytes as AVIF — skips the native libavif binding in unit tests.
class FakeImageConverter implements ImageConverter {
  FakeImageConverter({this.throwOnConvert = false});

  bool throwOnConvert;
  int convertCalls = 0;

  @override
  Future<MediaAsset> convertToAvif(File source) async {
    final bytes = await source.readAsBytes();
    return convertBytesToAvif(Uint8List.fromList(bytes));
  }

  @override
  Future<MediaAsset> convertBytesToAvif(Uint8List bytes) async {
    convertCalls++;
    if (throwOnConvert) {
      throw StateError('encode failed');
    }
    return MediaAsset(
      bytes: bytes,
      contentType: 'image/avif',
      byteSize: bytes.length,
    );
  }
}
