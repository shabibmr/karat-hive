import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_media/kh_media.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements KhApi {}

Dio _putDio({
  int statusCode = 200,
  void Function(RequestOptions options)? onPut,
}) {
  final dio = Dio()..options.validateStatus = (_) => true;
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        onPut?.call(options);
        handler.resolve(Response<void>(requestOptions: options, statusCode: statusCode));
      },
    ),
  );
  return dio;
}

UploadIntent _intent({
  String key = 'media-key-1',
  String uploadUrl = 'https://storage.example/put',
  Map<String, String> headers = const {'x-amz-acl': 'private'},
  int maxBytes = 1024,
}) =>
    UploadIntent(key: key, uploadUrl: uploadUrl, requiredHeaders: headers, maxBytes: maxBytes);

void main() {
  late _MockApi api;
  late File file;

  setUp(() async {
    api = _MockApi();
    file = File(
      '${Directory.systemTemp.path}/kh_media_${DateTime.now().microsecondsSinceEpoch}.bin',
    );
    await file.writeAsBytes(const [1, 2, 3, 4]);
  });

  tearDown(() async {
    if (await file.exists()) await file.delete();
  });

  MediaUploader uploader({
    Dio? putClient,
    int maxPolls = 15,
  }) =>
      MediaUploader(
        api,
        putClient: putClient ?? _putDio(),
        pollInterval: Duration.zero,
        maxPolls: maxPolls,
        sleep: (_) async {},
      );

  test('returns intent failure without putting bytes', () async {
    when(
      () => api.uploadIntent(
        purpose: any(named: 'purpose'),
        contentType: any(named: 'contentType'),
        byteSize: any(named: 'byteSize'),
      ),
    ).thenAnswer((_) async => const Err(ValidationFailure(code: 'TOO_LARGE', message: 'too big')));

    var putCalled = false;
    final result = await uploader(putClient: _putDio(onPut: (_) => putCalled = true)).upload(
      file,
      purpose: MediaUploadPurpose.kycDocument,
      contentType: 'application/pdf',
    );

    expect(putCalled, isFalse);
    expect(result.failureOrNull, isA<ValidationFailure>());
    verifyNever(() => api.completeUpload(any()));
  });

  test('sends KYC_DOCUMENT purpose and returns the media key when READY', () async {
    String? capturedPurpose;
    when(
      () => api.uploadIntent(
        purpose: any(named: 'purpose'),
        contentType: any(named: 'contentType'),
        byteSize: any(named: 'byteSize'),
      ),
    ).thenAnswer((inv) async {
      capturedPurpose = inv.namedArguments[#purpose] as String;
      return Ok(_intent());
    });
    when(() => api.completeUpload('media-key-1')).thenAnswer((_) async => const Ok('READY'));

    RequestOptions? put;
    final result = await uploader(putClient: _putDio(onPut: (o) => put = o)).upload(
      file,
      purpose: MediaUploadPurpose.kycDocument,
      contentType: 'application/pdf',
    );

    expect(capturedPurpose, 'KYC_DOCUMENT');
    expect(result.valueOrNull, 'media-key-1');
    expect(put?.method, 'PUT');
    expect(put?.uri.toString(), 'https://storage.example/put');
    expect(put?.headers['x-amz-acl'], 'private');
    expect(put?.headers['content-length']?.toString(), '4');
    verify(() => api.completeUpload('media-key-1')).called(1);
  });

  test('sends REQUEST_IMAGE purpose for customer request photos', () async {
    String? capturedPurpose;
    when(
      () => api.uploadIntent(
        purpose: any(named: 'purpose'),
        contentType: any(named: 'contentType'),
        byteSize: any(named: 'byteSize'),
      ),
    ).thenAnswer((inv) async {
      capturedPurpose = inv.namedArguments[#purpose] as String;
      return Ok(_intent(key: 'img-1'));
    });
    when(() => api.completeUpload('img-1')).thenAnswer((_) async => const Ok('READY'));

    final result = await uploader().upload(
      file,
      purpose: MediaUploadPurpose.requestImage,
      contentType: 'image/jpeg',
    );

    expect(capturedPurpose, 'REQUEST_IMAGE');
    expect(result.valueOrNull, 'img-1');
  });

  test('returns ServerFailure when the byte PUT is not 2xx', () async {
    when(
      () => api.uploadIntent(
        purpose: any(named: 'purpose'),
        contentType: any(named: 'contentType'),
        byteSize: any(named: 'byteSize'),
      ),
    ).thenAnswer((_) async => Ok(_intent()));

    final result = await uploader(putClient: _putDio(statusCode: 403)).upload(
      file,
      purpose: MediaUploadPurpose.kycDocument,
      contentType: 'application/pdf',
    );

    expect(result.failureOrNull, isA<ServerFailure>());
    expect(result.failureOrNull?.message, 'Upload failed. Try again.');
    verifyNever(() => api.completeUpload(any()));
  });

  test('polls complete until READY', () async {
    when(
      () => api.uploadIntent(
        purpose: any(named: 'purpose'),
        contentType: any(named: 'contentType'),
        byteSize: any(named: 'byteSize'),
      ),
    ).thenAnswer((_) async => Ok(_intent()));

    var completes = 0;
    when(() => api.completeUpload('media-key-1')).thenAnswer((_) async {
      completes++;
      return Ok(completes >= 3 ? 'READY' : 'PROCESSING');
    });

    final result = await uploader().upload(
      file,
      purpose: MediaUploadPurpose.requestImage,
      contentType: 'image/jpeg',
    );

    expect(result.valueOrNull, 'media-key-1');
    expect(completes, 3);
  });

  test('awaitReady: false returns the key without polling', () async {
    when(
      () => api.uploadIntent(
        purpose: any(named: 'purpose'),
        contentType: any(named: 'contentType'),
        byteSize: any(named: 'byteSize'),
      ),
    ).thenAnswer((_) async => Ok(_intent()));

    var completes = 0;
    when(() => api.completeUpload('media-key-1')).thenAnswer((_) async {
      completes++;
      return const Ok('PENDING_PROCESSING');
    });

    final result = await uploader().upload(
      file,
      purpose: MediaUploadPurpose.requestImage,
      contentType: 'image/avif',
      awaitReady: false,
    );

    expect(result.valueOrNull, 'media-key-1');
    expect(completes, 1);
  });

  test('reports progress including completion', () async {
    when(
      () => api.uploadIntent(
        purpose: any(named: 'purpose'),
        contentType: any(named: 'contentType'),
        byteSize: any(named: 'byteSize'),
      ),
    ).thenAnswer((_) async => Ok(_intent()));
    when(() => api.completeUpload('media-key-1')).thenAnswer((_) async => const Ok('READY'));

    final ticks = <double>[];
    await uploader().upload(
      file,
      purpose: MediaUploadPurpose.kycDocument,
      contentType: 'application/pdf',
      onProgress: ticks.add,
    );

    expect(ticks, isNotEmpty);
    expect(ticks.last, 1);
  });

  group('prefetched intent reuse', () {
    test('reuses a prefetched intent that fits, skipping uploadIntent', () async {
      when(() => api.completeUpload('prefetched-key')).thenAnswer((_) async => const Ok('READY'));

      RequestOptions? put;
      final result = await uploader(putClient: _putDio(onPut: (o) => put = o)).upload(
        file,
        purpose: MediaUploadPurpose.requestImage,
        contentType: 'image/avif',
        prefetchedIntent: _intent(key: 'prefetched-key', maxBytes: 5 * 1024 * 1024),
      );

      expect(result.valueOrNull, 'prefetched-key');
      expect(put?.uri.toString(), 'https://storage.example/put');
      verifyNever(
        () => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        ),
      );
    });

    test('falls back to a fresh intent when the prefetched one is too small', () async {
      when(
        () => api.uploadIntent(
          purpose: any(named: 'purpose'),
          contentType: any(named: 'contentType'),
          byteSize: any(named: 'byteSize'),
        ),
      ).thenAnswer((_) async => Ok(_intent(key: 'fresh-key')));
      when(() => api.completeUpload('fresh-key')).thenAnswer((_) async => const Ok('READY'));

      final result = await uploader().upload(
        file,
        purpose: MediaUploadPurpose.requestImage,
        contentType: 'image/avif',
        // file is 4 bytes but the "prefetched" ceiling here is smaller — unrealistic
        // in practice (ceilings are MiB-sized) but exercises the fallback path.
        prefetchedIntent: _intent(key: 'stale-key', maxBytes: 1),
      );

      expect(result.valueOrNull, 'fresh-key');
    });
  });

  test('OnboardingRepository-style KYC path uses MediaUploader with KYC_DOCUMENT', () async {
    String? capturedPurpose;
    when(
      () => api.uploadIntent(
        purpose: any(named: 'purpose'),
        contentType: any(named: 'contentType'),
        byteSize: any(named: 'byteSize'),
      ),
    ).thenAnswer((inv) async {
      capturedPurpose = inv.namedArguments[#purpose] as String;
      return Ok(_intent(key: 'kyc-key'));
    });
    when(() => api.completeUpload('kyc-key')).thenAnswer((_) async => const Ok('READY'));

    final result = await uploader().upload(
      file,
      purpose: MediaUploadPurpose.kycDocument,
      contentType: 'application/pdf',
    );

    expect(capturedPurpose, 'KYC_DOCUMENT');
    expect(result.valueOrNull, 'kyc-key');
  });
}
