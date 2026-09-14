import 'dart:io';

/// A file ready to upload: either the original pick, or the on-device
/// converted/compressed result.
class MediaAsset {
  const MediaAsset({
    required this.file,
    required this.contentType,
    required this.byteSize,
  });

  final File file;
  final String contentType;
  final int byteSize;
}
