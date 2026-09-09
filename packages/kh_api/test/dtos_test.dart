import 'package:flutter_test/flutter_test.dart';
import 'package:kh_api/kh_api.dart';

void main() {
  group('OtpChallenge.fromJson', () {
    test('parses challenge id and expiry', () {
      final challenge = OtpChallenge.fromJson({
        'challengeId': 'ch-1',
        'expiresAt': '2026-09-07T12:00:00.000Z',
      });
      expect(challenge.challengeId, 'ch-1');
      expect(challenge.expiresAt.toUtc().toIso8601String(),
          '2026-09-07T12:00:00.000Z');
    });
  });

  group('SessionBundle.fromJson', () {
    test('lifts flat token fields into SessionTokens', () {
      final bundle = SessionBundle.fromJson({
        'accessToken': 'access',
        'refreshToken': 'refresh',
        'accessExpiresAt': '2026-09-07T13:00:00.000Z',
        'refreshExpiresAt': '2026-10-07T13:00:00.000Z',
        'user': {
          'userId': 'u-1',
          'userType': 'VENDOR',
          'mobileNumber': '+971501234567',
          'preferredLanguage': 'en',
        },
      });
      expect(bundle.tokens.accessToken, 'access');
      expect(bundle.tokens.refreshToken, 'refresh');
      expect(bundle.user.userId, 'u-1');
      expect(bundle.user.userType, 'VENDOR');
    });

    test('accepts nested tokens object', () {
      final bundle = SessionBundle.fromJson({
        'tokens': {
          'accessToken': 'a2',
          'refreshToken': 'r2',
          'accessExpiresAt': '2026-09-07T13:00:00.000Z',
          'refreshExpiresAt': '2026-10-07T13:00:00.000Z',
        },
        'user': {
          'userId': 'u-2',
          'userType': 'CUSTOMER',
          'mobileNumber': '',
          'preferredLanguage': 'ar',
        },
      });
      expect(bundle.tokens.accessToken, 'a2');
      expect(bundle.user.preferredLanguage, 'ar');
    });
  });

  group('OtpVerifyResult.fromJson', () {
    test('REGISTER_VENDOR ack shape', () {
      final result = OtpVerifyResult.fromJson({
        'mobileVerified': true,
        'challengeId': 'ch-reg',
      });
      expect(result.mobileVerified, isTrue);
      expect(result.challengeId, 'ch-reg');
      expect(result.session, isNull);
    });

    test('LOGIN SessionBundle shape via top-level accessToken', () {
      final result = OtpVerifyResult.fromJson({
        'accessToken': 'access',
        'refreshToken': 'refresh',
        'accessExpiresAt': '2026-09-07T13:00:00.000Z',
        'refreshExpiresAt': '2026-10-07T13:00:00.000Z',
        'user': {
          'userId': 'u-login',
          'userType': 'VENDOR',
          'mobileNumber': '+971509999999',
          'preferredLanguage': 'en',
        },
      });
      expect(result.session, isNotNull);
      expect(result.session!.tokens.accessToken, 'access');
      expect(result.session!.user.userId, 'u-login');
      expect(result.mobileVerified, isFalse);
    });
  });

  group('UploadIntent.fromJson', () {
    test('coerces requiredHeaders and defaults maxBytes', () {
      final intent = UploadIntent.fromJson({
        'key': 'kyc/doc-1.pdf',
        'uploadUrl': 'https://upload.test/put',
        'requiredHeaders': {'Content-Type': 'application/pdf', 'x-amz': 1},
      });
      expect(intent.key, 'kyc/doc-1.pdf');
      expect(intent.uploadUrl, 'https://upload.test/put');
      expect(intent.requiredHeaders, {
        'Content-Type': 'application/pdf',
        'x-amz': '1',
      });
      expect(intent.maxBytes, 0);
    });
  });

  group('VendorPerformanceDto.fromJson', () {
    test('parses ratingTrend and byOutcome; never surfaces a competitor price field', () {
      final perf = VendorPerformanceDto.fromJson({
        'offersSubmitted': 4,
        'acceptanceRate': '0.50',
        'averageResponseMinutes': 30,
        'byOutcome': [
          {'state': 'ACCEPTED', 'count': 2},
          {'state': 'REJECTED', 'count': 2},
        ],
        'ratingTrend': [
          {'period': '2026-04', 'average': 4.0, 'count': 1},
          {'period': '2026-05', 'average': 4.5, 'count': 2},
        ],
      });
      expect(perf.offersSubmitted, 4);
      expect(perf.acceptanceRate, '0.50');
      expect(perf.byOutcome.map((e) => e.state).toList(),
          ['ACCEPTED', 'REJECTED']);
      expect(perf.ratingTrend.first.period, '2026-04');
      expect(perf.ratingTrend.last.average, 4.5);
    });

    test('unwraps nested data envelope', () {
      final perf = VendorPerformanceDto.fromJson({
        'data': {
          'offersSubmitted': 0,
          'acceptanceRate': '0.00',
          'averageResponseMinutes': 0,
          'byOutcome': <Object>[],
          'ratingTrend': <Object>[],
        },
      });
      expect(perf.offersSubmitted, 0);
      expect(perf.ratingTrend, isEmpty);
    });
  });

  group('PerformanceExportDto.fromJson', () {
    test('parses signed URL payload', () {
      final exp = PerformanceExportDto.fromJson({
        'downloadUrl': 'https://cdn.test/export.csv',
        'expiresAt': '2026-09-08T12:00:00.000Z',
      });
      expect(exp.downloadUrl, 'https://cdn.test/export.csv');
      expect(exp.expiresAt.toUtc().toIso8601String(),
          '2026-09-08T12:00:00.000Z');
    });
  });
}
