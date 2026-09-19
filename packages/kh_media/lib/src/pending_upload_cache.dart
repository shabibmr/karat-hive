import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'media_asset.dart';

/// Persists a picked-and-converted file on disk, keyed by a caller-chosen
/// correlation id, so a failed/interrupted upload can retry without
/// re-picking or re-converting. Backed by the app's temp directory plus a
/// small JSON manifest — survives app restarts; entries are evicted once
/// the upload succeeds.
class PendingUploadCache {
  PendingUploadCache({Directory? baseDir}) : _baseDirOverride = baseDir;

  final Directory? _baseDirOverride;
  static const _manifestName = 'manifest.json';

  Future<Directory> _dir() async {
    final override = _baseDirOverride;
    if (override != null) return override;
    final tmp = await getTemporaryDirectory();
    final dir = Directory('${tmp.path}/kh_media_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _manifestFile() async {
    final dir = await _dir();
    return File('${dir.path}/$_manifestName');
  }

  Future<Map<String, dynamic>> _readManifest() async {
    final f = await _manifestFile();
    if (!await f.exists()) return {};
    try {
      final raw = await f.readAsString();
      if (raw.trim().isEmpty) return {};
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeManifest(Map<String, dynamic> data) async {
    final f = await _manifestFile();
    await f.writeAsString(jsonEncode(data), flush: true);
  }

  Future<void> put(String correlationId, MediaAsset asset) async {
    final file = asset.file;
    if (file == null) return;
    final manifest = await _readManifest();
    manifest[correlationId] = {
      'path': file.path,
      'contentType': asset.contentType,
      'byteSize': asset.byteSize,
    };
    await _writeManifest(manifest);
  }

  Future<MediaAsset?> get(String correlationId) async {
    final manifest = await _readManifest();
    final entry = manifest[correlationId];
    if (entry is! Map) return null;
    final path = entry['path'] as String?;
    if (path == null) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    return MediaAsset(
      file: file,
      contentType: entry['contentType'] as String? ?? 'application/octet-stream',
      byteSize: entry['byteSize'] as int? ?? await file.length(),
    );
  }

  Future<void> evict(String correlationId) async {
    final manifest = await _readManifest();
    final entry = manifest.remove(correlationId);
    await _writeManifest(manifest);
    if (entry is Map) {
      final path = entry['path'] as String?;
      if (path != null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
      }
    }
  }
}
