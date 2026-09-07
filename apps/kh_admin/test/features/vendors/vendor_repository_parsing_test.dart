import 'package:flutter_test/flutter_test.dart';
import 'package:kh_admin/features/vendors/model/vendor_detail.dart';
import 'package:kh_admin/features/vendors/model/vendor_enums.dart';
import 'package:kh_admin/features/vendors/model/vendor_list_item.dart';
import 'package:kh_admin/features/vendors/repository/vendor_repository.dart';

/// These fixtures mirror the RAW Prisma rows that `origin/main`'s
/// `backend/src/modules/admin/` returns (no DTO layer): `accountState` nested
/// under `user`, `aggregateRating` as a `Decimal` JSON string, nested taxonomy
/// join rows, and `Media` with `contentType`/`byteSize` (no filename).
void main() {
  group('VendorRepository.normalizeListItem + VendorListItem.fromJson', () {
    Map<String, dynamic> rawListRow() => <String, dynamic>{
          'id': 'vendor-1',
          'userId': 'user-1',
          'legalBusinessName': 'Al Noor Jewellery LLC',
          'tradingName': 'Al Noor',
          'tradeLicenceNumber': 'CN-1092834',
          'licenceExpiryDate': '2027-01-01',
          'businessAddress': 'Deira, Dubai',
          'contactPersonName': 'Ahmed Hassan',
          'businessEmail': 'contact@alnoor.ae',
          'verificationState': 'VERIFIED',
          'activatedAt': '2026-08-01T10:00:00.000Z',
          'verifiedAt': '2026-08-01T09:00:00.000Z',
          'verificationNotes': null,
          'verificationMessage': null,
          'aggregateRating': '4.5', // Decimal -> JSON string
          'reviewCount': 12,
          'ratingTrend': null,
          'offersSubmittedCount': 8,
          'offersAcceptedCount': 2,
          'createdAt': '2026-07-15T08:00:00.000Z',
          'updatedAt': '2026-08-01T10:00:00.000Z',
          'user': <String, dynamic>{
            'mobileNumber': '+97145550101',
            'email': 'contact@alnoor.ae',
            'accountState': 'ACTIVE',
          },
        };

    test('lifts user.accountState, parses string rating, maps rollups', () {
      final item = VendorListItem.fromJson(
        VendorRepository.normalizeListItem(rawListRow()),
      );

      expect(item.id, 'vendor-1');
      expect(item.legalBusinessName, 'Al Noor Jewellery LLC');
      expect(item.verificationState, VendorVerificationState.verified);
      expect(item.accountState, VendorAccountState.active);
      expect(item.rating, 4.5);
      expect(item.offerCount, 8);
      expect(item.acceptanceRate, closeTo(0.25, 1e-9));
      expect(item.region, isNull);
      expect(item.waitingHours, isNull);
      expect(item.registeredAt, DateTime.parse('2026-07-15T08:00:00.000Z'));
    });

    test('suspended account state is read from the nested user row', () {
      final raw = rawListRow();
      (raw['user'] as Map<String, dynamic>)['accountState'] = 'SUSPENDED';

      final item = VendorListItem.fromJson(
        VendorRepository.normalizeListItem(raw),
      );

      expect(item.accountState, VendorAccountState.suspended);
    });

    test('null rating / missing user fall back without throwing', () {
      final raw = rawListRow()
        ..remove('user')
        ..['aggregateRating'] = null
        ..['offersSubmittedCount'] = 0
        ..['offersAcceptedCount'] = 0;

      final item = VendorListItem.fromJson(
        VendorRepository.normalizeListItem(raw),
      );

      expect(item.accountState, VendorAccountState.active);
      expect(item.rating, isNull);
      expect(item.offerCount, 0);
      expect(item.acceptanceRate, isNull);
    });
  });

  group('VendorDetail.fromJson against raw main shape', () {
    Map<String, dynamic> rawDetail() => <String, dynamic>{
          'id': 'vendor-1',
          'userId': 'user-1',
          'legalBusinessName': 'Al Noor Jewellery LLC',
          'tradingName': 'Al Noor',
          'tradeLicenceNumber': 'CN-1092834',
          'licenceExpiryDate': '2027-01-01',
          'businessAddress': 'Deira, Dubai',
          'contactPersonName': 'Ahmed Hassan',
          'businessEmail': 'contact@alnoor.ae',
          'verificationState': 'VERIFIED',
          'aggregateRating': '4.5',
          'createdAt': '2026-07-15T08:00:00.000Z',
          'user': <String, dynamic>{
            'mobileNumber': '+97145550101',
            'email': 'contact@alnoor.ae',
            'accountState': 'SUSPENDED',
          },
          'categories': <dynamic>[
            <String, dynamic>{
              'vendorProfileId': 'vendor-1',
              'categoryId': 'cat-1',
              'category': <String, dynamic>{
                'id': 'cat-1',
                'nameEn': 'Gold Jewellery',
                'nameAr': 'مجوهرات ذهبية',
              },
            },
          ],
          'regions': <dynamic>[
            <String, dynamic>{
              'vendorProfileId': 'vendor-1',
              'regionId': 'reg-1',
              'region': <String, dynamic>{
                'id': 'reg-1',
                'nameEn': 'Dubai',
                'nameAr': 'دبي',
              },
            },
          ],
          'documents': <dynamic>[
            <String, dynamic>{
              'id': 'doc-1',
              'vendorProfileId': 'vendor-1',
              'documentType': 'TRADE_LICENCE',
              'mediaId': 'media-1',
              'expiryDate': null,
              'verified': true,
              'uploadedAt': '2026-07-15T08:05:00.000Z',
              'media': <String, dynamic>{
                'id': 'media-1',
                'contentType': 'application/pdf',
                'byteSize': 204800,
              },
            },
          ],
        };

    test('reads nested category/region names and user.accountState', () {
      final detail = VendorDetail.fromJson(rawDetail());

      expect(detail.legalBusinessName, 'Al Noor Jewellery LLC');
      expect(detail.categories, ['Gold Jewellery']);
      expect(detail.regions, ['Dubai']);
      expect(detail.accountState, VendorAccountState.suspended);
      expect(detail.verificationState, VendorVerificationState.verified);
      expect(detail.mobileNumber, '+97145550101');
      // Detail route sends no submittedAt -> falls back to createdAt.
      expect(detail.submittedAt, DateTime.parse('2026-07-15T08:00:00.000Z'));
    });

    test('maps Media contentType/byteSize; leaves fileName null', () {
      final detail = VendorDetail.fromJson(rawDetail());

      expect(detail.documents, hasLength(1));
      final doc = detail.documents.single;
      expect(doc.id, 'doc-1');
      expect(doc.documentType, 'TRADE_LICENCE');
      expect(doc.verified, isTrue);
      expect(doc.fileName, isNull);
      expect(doc.mimeType, 'application/pdf');
      expect(doc.sizeBytes, 204800);
    });
  });
}
