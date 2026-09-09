import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/core/api/api_client.dart';
import 'package:kh_admin/features/verification/repository/verification_repository.dart';

/// These fixtures mirror origin/main's `backend/src/modules/admin/` output:
/// RAW Prisma rows wrapped by the `{ data }` envelope interceptor.
/// - verification-queue: bare array of raw `VendorProfile` rows, no
///   `oldestWaitingHours` / `submittedAt` — only `createdAt`.
/// - vendors/:id: raw `VendorProfile` with nested `user`, `documents[].media`,
///   `categories[].category`, `regions[].region`.
void main() {
  late Dio dio;
  late VerificationRepository repository;

  // ~30h ago so the derived wait figure is deterministic-ish.
  final queueCreatedAt =
      DateTime.now().toUtc().subtract(const Duration(hours: 30));

  setUp(() {
    dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.path == '/v1/admin/verification-queue') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': [
                    {
                      'id': 'vendor-1',
                      'userId': 'user-1',
                      'legalBusinessName': 'Al Noor Jewellery LLC',
                      'tradingName': 'Al Noor',
                      'tradeLicenceNumber': 'CN-1092834',
                      'licenceExpiryDate': '2027-06-30T00:00:00.000Z',
                      'businessAddress': 'Deira Gold Souk, Dubai',
                      'contactPersonName': 'Ahmed Hassan',
                      'businessEmail': 'ahmed@alnoor.ae',
                      'verificationState': 'PENDING_VERIFICATION',
                      'createdAt': queueCreatedAt.toIso8601String(),
                      'updatedAt': queueCreatedAt.toIso8601String(),
                      'user': {
                        'id': 'user-1',
                        'mobileNumber': '+97145550101',
                        'email': 'ahmed@alnoor.ae',
                      },
                      'documents': <Map<String, dynamic>>[],
                    },
                  ],
                },
              ),
            );
          }

          if (options.path == '/v1/admin/vendors/vendor-1') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'id': 'vendor-1',
                    'userId': 'user-1',
                    'legalBusinessName': 'Al Noor Jewellery LLC',
                    'tradingName': 'Al Noor',
                    'tradeLicenceNumber': 'CN-1092834',
                    'licenceExpiryDate': '2027-06-30T00:00:00.000Z',
                    'businessAddress': 'Deira Gold Souk, Dubai',
                    'contactPersonName': 'Ahmed Hassan',
                    'businessEmail': 'ahmed@alnoor.ae',
                    'verificationState': 'PENDING_VERIFICATION',
                    'createdAt': '2026-08-01T09:00:00.000Z',
                    'updatedAt': '2026-08-01T09:00:00.000Z',
                    'user': {
                      'id': 'user-1',
                      'mobileNumber': '+97145550101',
                      'email': 'ahmed@alnoor.ae',
                      'accountState': 'PENDING',
                    },
                    'documents': [
                      {
                        'id': 'doc-1',
                        'vendorProfileId': 'vendor-1',
                        'documentType': 'TRADE_LICENCE',
                        'mediaId': 'media-1',
                        'expiryDate': '2027-06-30T00:00:00.000Z',
                        'verified': false,
                        'uploadedAt': '2026-08-01T09:05:00.000Z',
                        'media': {
                          'id': 'media-1',
                          'key': 'kyc/trade-licence-abc123',
                          'contentType': 'application/pdf',
                          'byteSize': 2400000,
                          'thumbnailKey': null,
                        },
                      },
                    ],
                    'categories': [
                      {
                        'vendorProfileId': 'vendor-1',
                        'categoryId': 'cat-1',
                        'category': {
                          'id': 'cat-1',
                          'nameEn': 'Gold Jewellery',
                          'nameAr': 'مجوهرات ذهبية',
                        },
                      },
                    ],
                    'regions': [
                      {
                        'vendorProfileId': 'vendor-1',
                        'regionId': 'reg-1',
                        'region': {
                          'id': 'reg-1',
                          'nameEn': 'Dubai (Deira)',
                          'nameAr': 'دبي (ديرة)',
                        },
                      },
                    ],
                    'subscriptions': <Map<String, dynamic>>[],
                  },
                },
              ),
            );
          }

          if (options.path ==
              '/v1/admin/vendors/vendor-1/documents/doc-1/url') {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': {
                    'url': '/v1/media/kyc/trade-licence-abc123',
                    'expiresAt': '2026-09-07T12:15:00.000Z',
                  },
                },
              ),
            );
          }

          return handler.next(options);
        },
      ),
    );

    repository = VerificationRepository(
      ApiClient(baseUrl: 'http://localhost:3000', dio: dio),
    );
  });

  test('fetchQueue derives oldestWaitingHours from createdAt', () async {
    final queue = await repository.fetchQueue();

    expect(queue, hasLength(1));
    expect(queue.first.legalBusinessName, 'Al Noor Jewellery LLC');
    // ~30h ago — allow a generous window for clock drift during the test run.
    expect(queue.first.oldestWaitingHours, greaterThan(29));
    expect(queue.first.oldestWaitingHours, lessThan(31));
    expect(queue.first.submittedAt, isNotNull);
  });

  test('fetchVendorDetail flattens nested category/region names', () async {
    final detail = await repository.fetchVendorDetail('vendor-1');

    expect(detail.categories, ['Gold Jewellery']);
    expect(detail.regions, ['Dubai (Deira)']);
  });

  test('fetchVendorDetail maps media contentType/byteSize, leaves fileName null',
      () async {
    final detail = await repository.fetchVendorDetail('vendor-1');

    expect(detail.documents, hasLength(1));
    final doc = detail.documents.first;
    expect(doc.documentType, 'TRADE_LICENCE');
    expect(doc.mimeType, 'application/pdf');
    expect(doc.sizeBytes, 2400000);
    expect(doc.fileName, isNull);
  });

  test('fetchVendorDetail lifts mobileNumber off the nested user', () async {
    final detail = await repository.fetchVendorDetail('vendor-1');
    expect(detail.mobileNumber, '+97145550101');
  });

  test('fetchDocumentUrl returns the relative /v1/media path unchanged',
      () async {
    final res = await repository.fetchDocumentUrl(
      vendorId: 'vendor-1',
      documentId: 'doc-1',
    );
    // Repository keeps the raw relative path; the detail pane prefixes the base.
    expect(res.url, '/v1/media/kyc/trade-licence-abc123');
  });
}
