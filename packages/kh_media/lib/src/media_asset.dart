import 'dart:io';
import 'dart:typed_data';

/// A file ready to upload: either the original pick, or the on-device
/// converted/compressed result.
///
/// [file] is omitted on web (no `dart:io` temp path). [bytes] is always
/// populated by the AVIF converter so callers can upload without a File.
class MediaAsset {
  const MediaAsset({
    this.file,
    this.bytes,
    required this.contentType,
    required this.byteSize,
  });

  final File? file;
  final Uint8List? bytes;
  final String contentType;
  final int byteSize;

  Future<Uint8List> readBytes() async {
    final inMemory = bytes;
    if (inMemory != null) return inMemory;
    final onDisk = file;
    if (onDisk != null) {
      return Uint8List.fromList(await onDisk.readAsBytes());
    }
    throw StateError('MediaAsset has neither bytes nor file');
  }
}
