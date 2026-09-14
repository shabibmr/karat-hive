import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kh_media/kh_media.dart';

void main() {
  late Directory tmpDir;
  late PendingUploadCache cache;

  setUp(() async {
    tmpDir = await Directory.systemTemp.createTemp('kh_media_cache_test_');
    cache = PendingUploadCache(baseDir: tmpDir);
  });

  tearDown(() async {
    if (await tmpDir.exists()) await tmpDir.delete(recursive: true);
  });

  Future<File> writeFixture(String name, List<int> bytes) async {
    final f = File('${tmpDir.path}/$name');
    await f.writeAsBytes(bytes);
    return f;
  }

  test('returns null for an unknown correlation id', () async {
    expect(await cache.get('missing'), isNull);
  });

  test('put then get round-trips the asset', () async {
    final f = await writeFixture('a.avif', [1, 2, 3]);
    await cache.put('slot-1', MediaAsset(file: f, contentType: 'image/avif', byteSize: 3));

    final got = await cache.get('slot-1');

    expect(got, isNotNull);
    expect(got!.file.path, f.path);
    expect(got.contentType, 'image/avif');
    expect(got.byteSize, 3);
  });

  test('survives being re-created (simulated app restart) against the same dir', () async {
    final f = await writeFixture('b.avif', [1, 2, 3, 4]);
    await cache.put('slot-2', MediaAsset(file: f, contentType: 'image/avif', byteSize: 4));

    final reopened = PendingUploadCache(baseDir: tmpDir);
    final got = await reopened.get('slot-2');

    expect(got, isNotNull);
    expect(got!.byteSize, 4);
  });

  test('evict removes both the manifest entry and the file', () async {
    final f = await writeFixture('c.avif', [9]);
    await cache.put('slot-3', MediaAsset(file: f, contentType: 'image/avif', byteSize: 1));

    await cache.evict('slot-3');

    expect(await cache.get('slot-3'), isNull);
    expect(await f.exists(), isFalse);
  });

  test('get returns null if the underlying file was deleted out-of-band', () async {
    final f = await writeFixture('d.avif', [1]);
    await cache.put('slot-4', MediaAsset(file: f, contentType: 'image/avif', byteSize: 1));
    await f.delete();

    expect(await cache.get('slot-4'), isNull);
  });
}
