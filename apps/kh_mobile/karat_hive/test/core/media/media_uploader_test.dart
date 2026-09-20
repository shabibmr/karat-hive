import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:karat_hive/features/onboarding/repository/onboarding_repository.dart';
import 'package:kh_api/kh_api.dart';
import 'package:kh_core/kh_core.dart';
import 'package:kh_domain/kh_domain.dart';
import 'package:kh_media/kh_media.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements KhApi {}

Dio _putDio() {
  final dio = Dio()..options.validateStatus = (_) => true;
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) =>
          handler.resolve(Response<void>(requestOptions: options, statusCode: 200)),
    ),
  );
  return dio;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('OnboardingRepository KYC path uses kh_media MediaUploader with KYC_DOCUMENT', () async {
    final api = _MockApi();
    final file = File(
      '${Directory.systemTemp.path}/kh_media_${DateTime.now().microsecondsSinceEpoch}.bin',
    );
    await file.writeAsBytes(const [1, 2, 3, 4]);
    addTearDown(() async {
      if (await file.exists()) await file.delete();
    });

    String? capturedPurpose;
    when(
      () => api.uploadIntent(
        purpose: any(named: 'purpose'),
        contentType: any(named: 'contentType'),
        byteSize: any(named: 'byteSize'),
      ),
    ).thenAnswer((inv) async {
      capturedPurpose = inv.namedArguments[#purpose] as String;
      return Ok(
        UploadIntent(
          key: 'kyc-key',
          uploadUrl: 'https://storage.example/put',
          requiredHeaders: const {},
          maxBytes: 1024,
        ),
      );
    });
    when(() => api.completeUpload('kyc-key')).thenAnswer((_) async => const Ok('READY'));

    final repo = OnboardingRepository(
      api,
      media: MediaPickController(
        uploader: MediaUploader(
          api,
          putClient: _putDio(),
          pollInterval: Duration.zero,
          sleep: (_) async {},
        ),
        purpose: MediaUploadPurpose.kycDocument,
        cache: PendingUploadCache(baseDir: Directory.systemTemp),
      ),
    );
    // PDFs skip AVIF conversion (uploadRaw path) — safe to exercise without
    // faking the image converter.
    final result = await repo.uploadKycDocument(
      VendorDocumentType.tradeLicence,
      file,
      'application/pdf',
    );

    expect(capturedPurpose, 'KYC_DOCUMENT');
    expect(result.valueOrNull, 'kyc-key');
  });
}
