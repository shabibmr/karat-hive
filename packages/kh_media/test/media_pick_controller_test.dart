import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_media/kh_media.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements KhApi {}

class _MockImagePicker extends Mock implements ImagePicker {}

/// Converts by just relabeling the bytes as AVIF — avoids exercising the
/// real libavif platform binding in unit tests.
class _FakeImageConverter implements ImageConverter {
  int convertCalls = 0;

  @override
  Future<MediaAsset> convertToAvif(File source) async {
    final bytes = await source.readAsBytes();
    return convertBytesToAvif(Uint8List.fromList(bytes));
  }

  @override
  Future<MediaAsset> convertBytesToAvif(Uint8List bytes) async {
    convertCalls++;
    final outPath =
        '${Directory.systemTemp.path}/kh_media_fake_${DateTime.now().microsecondsSinceEpoch}.avif';
    final outFile = await File(outPath).writeAsBytes(bytes);
    return MediaAsset(
      file: outFile,
      bytes: bytes,
      contentType: 'image/avif',
      byteSize: bytes.length,
    );
  }
}

Dio _putDio({int statusCode = 200}) {
  final dio = Dio()..options.validateStatus = (_) => true;
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) =>
          handler.resolve(Response<void>(requestOptions: options, statusCode: statusCode)),
    ),
  );
  return dio;
}

UploadIntent _intent({String key = 'key-1', int maxBytes = 5 * 1024 * 1024}) => UploadIntent(
      key: key,
      uploadUrl: 'https://storage.example/put',
      requiredHeaders: const {},
      maxBytes: maxBytes,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(ImageSource.gallery);
  });

  late _MockApi api;
  late _MockImagePicker picker;
  late _FakeImageConverter converter;
  late Directory tmpDir;
  late PendingUploadCache cache;
  late File sourceFile;

  setUp(() async {
    api = _MockApi();
    picker = _MockImagePicker();
    converter = _FakeImageConverter();
    tmpDir = await Directory.systemTemp.createTemp('kh_media_controller_test_');
    cache = PendingUploadCache(baseDir: tmpDir);
    sourceFile = File('${tmpDir.path}/source.jpg');
    await sourceFile.writeAsBytes([1, 2, 3, 4]);

    when(() => api.completeUpload(any())).thenAnswer((_) async => const Ok('READY'));
  });

  tearDown(() async {
    if (await tmpDir.exists()) await tmpDir.delete(recursive: true);
  });

  const slot = 'slot-1';

  MediaPickController controller({MediaUploadPurpose purpose = MediaUploadPurpose.requestImage}) =>
      MediaPickController(
        uploader: MediaUploader(api, putClient: _putDio(), pollInterval: Duration.zero, sleep: (_) async {}),
        purpose: purpose,
        imageConverter: converter,
        cache: cache,
        imagePicker: picker,
      );

  group('prefetchIntent', () {
    test('is idempotent — a second call issues no extra network request', () async {
      when(
        () => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        ),
      ).thenAnswer((_) async => Ok(_intent()));

      final c = controller();
      await c.prefetchIntent();
      await c.prefetchIntent();

      verify(
        () => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        ),
      ).called(1);
      expect(c.hasPrefetchedIntent, isTrue);
    });

    test('requests image/avif content type for image purposes', () async {
      String? capturedContentType;
      when(
        () => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        ),
      ).thenAnswer((inv) async {
        capturedContentType = inv.namedArguments[#contentType] as String;
        return Ok(_intent());
      });

      await controller(purpose: MediaUploadPurpose.offerImage).prefetchIntent();

      expect(capturedContentType, 'image/avif');
    });

    test('requests application/pdf content type for KYC (dominant case)', () async {
      String? capturedContentType;
      when(
        () => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        ),
      ).thenAnswer((inv) async {
        capturedContentType = inv.namedArguments[#contentType] as String;
        return Ok(_intent(maxBytes: 10 * 1024 * 1024));
      });

      await controller(purpose: MediaUploadPurpose.kycDocument).prefetchIntent();

      expect(capturedContentType, 'application/pdf');
    });
  });

  group('pickImageConvertAndUpload / convertAndUpload', () {
    test('reuses a valid prefetched intent for the converted image', () async {
      when(
        () => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        ),
      ).thenAnswer((_) async => Ok(_intent(key: 'prefetched')));
      when(() => picker.pickImage(source: any(named: 'source')))
          .thenAnswer((_) async => XFile(sourceFile.path));

      final c = controller();
      await c.prefetchIntent();
      final result =
          await c.pickImageConvertAndUpload(correlationId: slot, source: ImageSource.gallery);

      expect(result?.valueOrNull, 'prefetched');
      expect(converter.convertCalls, 1);
      verify(
        () => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        ),
      ).called(1); // only the prefetch call — not a second one at upload time
    });

    test('falls back to a fresh intent when nothing was prefetched', () async {
      when(
        () => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        ),
      ).thenAnswer((_) async => Ok(_intent(key: 'fresh')));
      when(() => picker.pickImage(source: any(named: 'source')))
          .thenAnswer((_) async => XFile(sourceFile.path));

      final result =
          await controller().pickImageConvertAndUpload(correlationId: slot, source: ImageSource.gallery);

      expect(result?.valueOrNull, 'fresh');
    });

    test('returns null when the user cancels the picker', () async {
      when(() => picker.pickImage(source: any(named: 'source')))
          .thenAnswer((_) async => null);

      final result =
          await controller().pickImageConvertAndUpload(correlationId: slot, source: ImageSource.gallery);

      expect(result, isNull);
      expect(converter.convertCalls, 0);
    });

    test('caches the converted file so it survives for retry', () async {
      when(
        () => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        ),
      ).thenAnswer((_) async => const Err(ServerFailure(message: 'boom')));
      when(() => picker.pickImage(source: any(named: 'source')))
          .thenAnswer((_) async => XFile(sourceFile.path));

      final c = controller();
      await c.pickImageConvertAndUpload(correlationId: slot, source: ImageSource.gallery);

      final cached = await cache.get('slot-1');
      expect(cached, isNotNull);
      expect(cached!.contentType, 'image/avif');
    });
  });

  group('retry', () {
    test('reuses the cached converted file without re-invoking the converter', () async {
      when(
        () => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        ),
      ).thenAnswer((_) async => const Err(ServerFailure(message: 'network down')));
      when(() => picker.pickImage(source: any(named: 'source')))
          .thenAnswer((_) async => XFile(sourceFile.path));

      final c = controller();
      final first = await c.pickImageConvertAndUpload(correlationId: slot, source: ImageSource.gallery);
      expect(first?.isOk, isFalse);
      expect(converter.convertCalls, 1);

      when(
        () => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        ),
      ).thenAnswer((_) async => Ok(_intent(key: 'retry-key')));

      final retried = await c.retry(slot);

      expect(retried?.valueOrNull, 'retry-key');
      expect(converter.convertCalls, 1); // unchanged — no re-pick/re-convert
    });

    test('returns null when nothing is cached for this slot', () async {
      final retried = await controller().retry(slot);
      expect(retried, isNull);
    });

    test('evicts the cache entry once the upload succeeds', () async {
      when(
        () => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        ),
      ).thenAnswer((_) async => Ok(_intent(key: 'ok-key')));
      when(() => picker.pickImage(source: any(named: 'source')))
          .thenAnswer((_) async => XFile(sourceFile.path));

      await controller().pickImageConvertAndUpload(correlationId: slot, source: ImageSource.gallery);

      expect(await cache.get('slot-1'), isNull);
    });
  });

  group('uploadRaw', () {
    test('uploads without converting (KYC PDFs)', () async {
      when(
        () => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        ),
      ).thenAnswer((_) async => Ok(_intent(key: 'pdf-key', maxBytes: 10 * 1024 * 1024)));

      final result = await controller(purpose: MediaUploadPurpose.kycDocument)
          .uploadRaw(sourceFile, 'application/pdf', correlationId: slot);

      expect(result.valueOrNull, 'pdf-key');
      expect(converter.convertCalls, 0);
    });
  });
}
