import 'dart:io';

import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  group('PartyRole', () {
    test('maps inventory UserType wires used as party role', () {
      expect(PartyRole.parse('CUSTOMER'), PartyRole.customer);
      expect(PartyRole.parse('VENDOR'), PartyRole.vendor);
    });

    test('unknown value falls back to .unknown (NFR-027)', () {
      expect(PartyRole.parse('ADMIN'), PartyRole.unknown);
      expect(PartyRole.parse(null), PartyRole.unknown);
    });
  });

  group('AccountState', () {
    test('maps inventory wires', () {
      expect(AccountState.parse('ACTIVE'), AccountState.active);
      expect(AccountState.parse('SUSPENDED'), AccountState.suspended);
      expect(AccountState.parse('DEACTIVATED'), AccountState.deactivated);
    });

    test('unknown value falls back to .unknown (NFR-027)', () {
      expect(AccountState.parse('PENDING'), AccountState.unknown);
      expect(AccountState.parse(null), AccountState.unknown);
    });
  });

  group('MaskedParty (AD-FE-07)', () {
    test('parses MaskedVendor wire without identity fields', () {
      final party = MaskedParty.fromJson({
        'label': 'Verified Jeweller · Deira',
        'region': {
          'id': 'reg-1',
          'nameEn': 'Deira',
          'nameAr': 'ديرة',
        },
        'rating': {
          'average': '4.6',
          'count': 12,
          'distribution': {'1': 0, '2': 0, '3': 1, '4': 3, '5': 8},
          'limitedHistory': false,
        },
        'connectionCount': 12,
      }, role: PartyRole.vendor);

      expect(party.role, PartyRole.vendor);
      expect(party.pseudonym, 'Verified Jeweller · Deira');
      expect(party.region.id, 'reg-1');
      expect(party.completedConnections, 12);
      expect(party.rating?.average, '4.6');
      expect(party.rating?.limitedHistory, isFalse);
    });

    test('source declares no identity fields to read', () {
      final src = File('lib/src/party.dart').readAsStringSync();
      final start = src.indexOf('class MaskedParty');
      final next = src.indexOf('\nclass ', start + 1);
      final body = src.substring(start, next == -1 ? src.length : next);
      const forbidden = [
        'displayName',
        'mobileNumber',
        'mobile',
        'tradingName',
        'legalBusinessName',
        'contactPersonName',
        'phone',
        'businessEmail',
        'businessAddress',
      ];
      for (final name in forbidden) {
        expect(
          body.contains(name),
          isFalse,
          reason: 'MaskedParty must not declare $name (BR-006, AD-FE-07)',
        );
      }
    });
  });

  group('RevealedParty', () {
    test('parses RevealedVendor identity from Connection payload', () {
      final party = RevealedParty.fromVendorJson({
        'tradingName': 'Al Noor',
        'legalBusinessName': 'Al Noor LLC',
        'contactPersonName': 'Fatima',
        'mobileNumber': '+971501234567',
        'businessEmail': 'shop@example.ae',
        'businessAddress': 'Deira, Dubai',
        'region': {'id': 'reg-1', 'nameEn': 'Deira', 'nameAr': 'ديرة'},
        'rating': {'average': '4.8', 'count': 20, 'limitedHistory': false},
        'connectionCount': 20,
      });
      expect(party.displayName, 'Al Noor');
      expect(party.mobile.e164, '+971501234567');
      expect(party.business?.tradingName, 'Al Noor');
      expect(party.business?.legalBusinessName, 'Al Noor LLC');
    });

    test('accepts backend Connection vendor phone alias', () {
      final party = RevealedParty.fromVendorJson({
        'tradingName': 'Al Noor',
        'legalBusinessName': 'Al Noor LLC',
        'phone': '+971509999999',
      });
      expect(party.mobile.e164, '+971509999999');
    });
  });

  group('PhoneNumber', () {
    test('normalises to wa.me digits (Architecture-Frontend §10.3)', () {
      expect(PhoneNumber.parse('+971 50 123 4567').waMeDigits, '971501234567');
      expect(PhoneNumber.parse('+971501234567').e164, '+971501234567');
    });
  });
}
