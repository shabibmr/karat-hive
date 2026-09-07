import 'dart:io';

import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  group('UserRole / PartyRole', () {
    test('parses known roles', () {
      expect(UserRole.parse('CUSTOMER'), UserRole.customer);
      expect(UserRole.parse('customer'), UserRole.customer);
      expect(UserRole.parse('VENDOR'), UserRole.vendor);
      expect(UserRole.parse('vendor'), UserRole.vendor);
    });

    test('falls back to unknown on null or unrecognised string (NFR-027)', () {
      expect(UserRole.parse(null), UserRole.unknown);
      expect(UserRole.parse(''), UserRole.unknown);
      expect(UserRole.parse('SUPERADMIN'), UserRole.unknown);
      expect(PartyRole.parse('ADMIN'), PartyRole.unknown);
      expect(PartyRole.parse(null), PartyRole.unknown);
    });

    test('wireName returns uppercase wire representation', () {
      expect(UserRole.customer.wireName, 'CUSTOMER');
      expect(UserRole.vendor.wireName, 'VENDOR');
      expect(UserRole.unknown.wireName, 'UNKNOWN');
      expect(UserRole.customer.wire, 'CUSTOMER');
      expect(UserRole.vendor.wire, 'VENDOR');
    });

    test('PartyRole is typedef alias for UserRole', () {
      const PartyRole role = UserRole.vendor;
      expect(role, UserRole.vendor);
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

  group('RatingSummary', () {
    test('parses from full JSON map', () {
      final summary = RatingSummary.fromJson({
        'average': '4.8',
        'count': 15,
        'distribution': {'5': 12, '4': 3},
        'limitedHistory': false,
      });
      expect(summary, isNotNull);
      expect(summary!.average, 4.8);
      expect(summary.count, 15);
      expect(summary.distribution['5'], 12);
      expect(summary.limitedHistory, isFalse);
    });

    test('parses from numeric score directly', () {
      final summary = RatingSummary.fromJson(4.5);
      expect(summary, isNotNull);
      expect(summary!.average, 4.5);
      expect(summary.count, 1);
      expect(summary.limitedHistory, isTrue); // count < 3
    });

    test('parses from numeric string', () {
      final summary = RatingSummary.fromJson('4.2');
      expect(summary, isNotNull);
      expect(summary!.average, 4.2);
    });

    test('returns null for null or invalid JSON', () {
      expect(RatingSummary.fromJson(null), isNull);
      expect(RatingSummary.fromJson('not-a-number'), isNull);
      expect(RatingSummary.fromJson([]), isNull);
    });

    test('serializes to JSON correctly', () {
      const summary = RatingSummary(
        average: 4.67,
        count: 5,
        distribution: {'5': 4, '4': 1},
        limitedHistory: false,
      );
      final json = summary.toJson();
      expect(json['average'], '4.7');
      expect(json['count'], 5);
      expect(json['limitedHistory'], isFalse);
    });

    test('value equality and hashCode', () {
      const s1 = RatingSummary(average: 4.5, count: 10, limitedHistory: false);
      const s2 = RatingSummary(average: 4.5, count: 10, limitedHistory: false);
      const s3 = RatingSummary(average: 4.0, count: 10, limitedHistory: false);
      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
    });
  });

  group('MaskedParty', () {
    test('constructs with role, region, rating, dealCount, and pseudonym', () {
      const party = MaskedParty(
        role: UserRole.vendor,
        region: 'Deira',
        pseudonym: 'Gold Merchant in Deira',
        rating: RatingSummary(average: 4.8, count: 25, limitedHistory: false),
        dealCount: 14,
      );

      expect(party.role, UserRole.vendor);
      expect(party.region, 'Deira');
      expect(party.pseudonym, 'Gold Merchant in Deira');
      expect(party.displayPseudonym, 'Gold Merchant in Deira');
      expect(party.dealCount, 14);
      expect(party.completedConnections, 14);
      expect(party.ratingScore, 4.8);
      expect(party.isMasked, isTrue);
      expect(party.isRevealed, isFalse);
    });

    test('generates fallback displayPseudonym when pseudonym is absent', () {
      const partyWithRegion = MaskedParty(
        role: UserRole.vendor,
        region: 'Deira',
      );
      expect(partyWithRegion.displayPseudonym, 'Vendor in Deira');

      const customerWithRegion = MaskedParty(
        role: UserRole.customer,
        region: 'Bur Dubai',
      );
      expect(customerWithRegion.displayPseudonym, 'Customer in Bur Dubai');

      const partyWithoutRegion = MaskedParty(role: UserRole.vendor);
      expect(partyWithoutRegion.displayPseudonym, 'Vendor');

      const unknownParty = MaskedParty(role: UserRole.unknown);
      expect(unknownParty.displayPseudonym, 'Counterparty');
    });

    test('parses from JSON correctly', () {
      final party = MaskedParty.fromJson({
        'role': 'VENDOR',
        'region': 'Gold Souk',
        'pseudonym': 'Al Noor Jewellery',
        'rating': {'average': 4.9, 'count': 50},
        'dealCount': 42,
      });

      expect(party.role, UserRole.vendor);
      expect(party.region, 'Gold Souk');
      expect(party.pseudonym, 'Al Noor Jewellery');
      expect(party.rating?.average, 4.9);
      expect(party.dealCount, 42);
      expect(party.completedConnections, 42);
    });

    test('parses region from nested object if provided by API', () {
      final party = MaskedParty.fromJson({
        'role': 'CUSTOMER',
        'region': {'id': 'reg-dxb', 'nameEn': 'Dubai Gold Souk'},
      });

      expect(party.role, UserRole.customer);
      expect(party.region, 'Dubai Gold Souk');
    });

    test('parses connection count aliases in JSON', () {
      final party1 = MaskedParty.fromJson({
        'role': 'VENDOR',
        'connectionCount': 17,
      });
      expect(party1.dealCount, 17);

      final party2 = MaskedParty.fromJson({
        'role': 'VENDOR',
        'completedConnections': 23,
      });
      expect(party2.dealCount, 23);
    });

    test('serializes to JSON with isMasked flag and no identity fields', () {
      const party = MaskedParty(
        role: UserRole.customer,
        region: 'Downtown',
        pseudonym: 'Gold Collector',
        dealCount: 5,
      );

      final json = party.toJson();
      expect(json['role'], 'CUSTOMER');
      expect(json['region'], 'Downtown');
      expect(json['pseudonym'], 'Gold Collector');
      expect(json['dealCount'], 5);
      expect(json['isMasked'], isTrue);

      expect(json.containsKey('name'), isFalse);
      expect(json.containsKey('displayName'), isFalse);
      expect(json.containsKey('mobile'), isFalse);
      expect(json.containsKey('mobileNumber'), isFalse);
      expect(json.containsKey('address'), isFalse);
    });

    test('copyWith updates fields without mutating original', () {
      const original = MaskedParty(
        role: UserRole.vendor,
        region: 'Deira',
        dealCount: 3,
      );

      final updated = original.copyWith(dealCount: 4, pseudonym: 'Renamed');

      expect(original.dealCount, 3);
      expect(original.pseudonym, isNull);
      expect(updated.dealCount, 4);
      expect(updated.pseudonym, 'Renamed');
      expect(updated.region, 'Deira');
    });

    test('value equality and hashCode', () {
      const p1 = MaskedParty(role: UserRole.vendor, region: 'Deira');
      const p2 = MaskedParty(role: UserRole.vendor, region: 'Deira');
      const p3 = MaskedParty(role: UserRole.vendor, region: 'Sharjah');
      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1, isNot(equals(p3)));
    });

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
      expect(party.region, 'Deira');
      expect(party.completedConnections, 12);
      expect(party.rating?.average, 4.6);
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
    test('constructs with name, mobile, address, role, business, rating, dealCount', () {
      final party = RevealedParty(
        name: 'Tariq Al Hashimi',
        mobile: '+971501234567',
        role: UserRole.vendor,
        address: 'Shop 102, Deira Gold Souk, Dubai',
        business: 'Al Hashimi Bullion Trading LLC',
        rating: const RatingSummary(average: 4.95, count: 120, limitedHistory: false),
        dealCount: 88,
      );

      expect(party.name, 'Tariq Al Hashimi');
      expect(party.displayName, 'Tariq Al Hashimi');
      expect(party.mobile.e164, '+971501234567');
      expect(party.role, UserRole.vendor);
      expect(party.address, 'Shop 102, Deira Gold Souk, Dubai');
      expect(party.business?.tradingName, 'Al Hashimi Bullion Trading LLC');
      expect(party.dealCount, 88);
      expect(party.completedConnections, 88);
      expect(party.ratingScore, 4.95);
      expect(party.isRevealed, isTrue);
      expect(party.isMasked, isFalse);
    });

    test('parses from revealed JSON payload', () {
      final party = RevealedParty.fromJson({
        'name': 'Fatima Al Mansoori',
        'mobile': '+971559876543',
        'role': 'CUSTOMER',
        'address': 'Villa 14, Jumeirah 2, Dubai',
        'dealCount': 12,
        'rating': {'average': 5.0, 'count': 8},
      });

      expect(party.name, 'Fatima Al Mansoori');
      expect(party.mobile.e164, '+971559876543');
      expect(party.role, UserRole.customer);
      expect(party.address, 'Villa 14, Jumeirah 2, Dubai');
      expect(party.dealCount, 12);
      expect(party.rating?.average, 5.0);
    });

    test('parses alias fields displayName and mobileNumber', () {
      final party = RevealedParty.fromJson({
        'displayName': 'Saeed Gold Works',
        'mobileNumber': '+971502223333',
        'role': 'VENDOR',
      });

      expect(party.name, 'Saeed Gold Works');
      expect(party.displayName, 'Saeed Gold Works');
      expect(party.mobile.e164, '+971502223333');
      expect(party.role, UserRole.vendor);
    });

    test('serializes to JSON with isRevealed flag and identity fields', () {
      final party = RevealedParty(
        name: 'Rashid Khan',
        mobile: '+971504445555',
        role: UserRole.customer,
        address: 'Downtown Dubai',
        dealCount: 7,
      );

      final json = party.toJson();
      expect(json['name'], 'Rashid Khan');
      expect(json['mobile'], '+971504445555');
      expect(json['role'], 'CUSTOMER');
      expect(json['address'], 'Downtown Dubai');
      expect(json['dealCount'], 7);
      expect(json['isRevealed'], isTrue);
    });

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

  group('AD-FE-07 Sealed Type Invariants and Masking Enforcement', () {
    test('Party.fromJson constructs MaskedParty when identity fields are absent', () {
      final payload = {
        'role': 'VENDOR',
        'region': 'Deira',
        'pseudonym': 'Gold Dealer in Deira',
        'rating': {'average': 4.7, 'count': 15},
        'dealCount': 10,
      };

      final party = Party.fromJson(payload);

      expect(party, isA<MaskedParty>());
      expect(party is RevealedParty, isFalse);
      expect(party.isMasked, isTrue);
      expect(party.isRevealed, isFalse);

      final masked = party as MaskedParty;
      expect(masked.role, UserRole.vendor);
      expect(masked.region, 'Deira');
      expect(masked.displayPseudonym, 'Gold Dealer in Deira');
    });

    test('Party.fromJson constructs MaskedParty when identity fields are explicitly null', () {
      final payload = {
        'name': null,
        'displayName': null,
        'mobile': null,
        'mobileNumber': null,
        'role': 'CUSTOMER',
        'region': 'Bur Dubai',
        'dealCount': 2,
      };

      final party = Party.fromJson(payload);

      expect(party, isA<MaskedParty>());
      expect(party.isMasked, isTrue);
      expect(party.isRevealed, isFalse);
    });

    test('Party.fromJson constructs MaskedParty when identity fields are blank / whitespace', () {
      final payload = {
        'name': '   ',
        'mobile': '  ',
        'role': 'VENDOR',
        'region': 'Sharjah',
      };

      final party = Party.fromJson(payload);

      expect(party, isA<MaskedParty>());
      expect(party.isMasked, isTrue);
    });

    test('Party.fromJson constructs MaskedParty when payload is explicitly marked masked', () {
      final payload = {
        'name': 'Leaked Name Should Be Ignored',
        'mobile': '+971501111111',
        'role': 'VENDOR',
        'isMasked': true,
        'region': 'Deira',
      };

      final party = Party.fromJson(payload);

      expect(party, isA<MaskedParty>());
      expect(party is RevealedParty, isFalse);
      expect(party.isMasked, isTrue);
    });

    test('CRITICAL: RevealedParty.fromJson throws on masked payload (cannot construct RevealedParty)', () {
      final maskedPayload = {
        'role': 'VENDOR',
        'region': 'Deira',
        'pseudonym': 'Jeweller in Deira',
        'dealCount': 5,
      };

      expect(
        () => RevealedParty.fromJson(maskedPayload),
        throwsA(isA<FormatException>()),
      );
    });

    test('Party.fromJson constructs RevealedParty when valid identity fields exist', () {
      final revealedPayload = {
        'name': 'Emirates Gold LLC',
        'mobile': '+971501234567',
        'role': 'VENDOR',
        'address': 'Building 4, Gold Souk',
        'rating': {'average': 4.9, 'count': 40},
        'dealCount': 30,
      };

      final party = Party.fromJson(revealedPayload);

      expect(party, isA<RevealedParty>());
      expect(party is MaskedParty, isFalse);
      expect(party.isRevealed, isTrue);

      final revealed = party as RevealedParty;
      expect(revealed.name, 'Emirates Gold LLC');
      expect(revealed.mobile.e164, '+971501234567');
      expect(revealed.address, 'Building 4, Gold Souk');
    });

    test('Pattern matching over Party sealed class is exhaustive', () {
      final Party masked = MaskedParty.fromJson({'role': 'VENDOR', 'region': 'Deira'});
      final Party revealed = RevealedParty.fromJson({
        'name': 'Al Noor',
        'mobile': '+971501234567',
        'role': 'VENDOR',
      });

      String renderLabel(Party p) => switch (p) {
            MaskedParty m => 'Masked: ${m.displayPseudonym}',
            RevealedParty r => 'Revealed: ${r.name} (${r.mobile})',
          };

      expect(renderLabel(masked), 'Masked: Vendor in Deira');
      expect(renderLabel(revealed), 'Revealed: Al Noor (+971501234567)');
    });

    test('VendorRequestItem.fromJson maps customer via MaskedParty even if identity leaks', () {
      final item = VendorRequestItem.fromJson({
        'id': 'req-mask-1',
        'reference': 'REQ-MASK-1',
        'requestType': 'FIND_ORNAMENT',
        'direction': 'BUY',
        'state': 'PUBLISHED',
        'categoryId': 'cat-ring',
        'regionId': 'reg-dxb',
        'customer': {
          'name': 'Fatima Al Zahra',
          'mobile': '+971559876543',
          'address': 'Villa 12, Jumeirah',
          'role': 'CUSTOMER',
          'region': 'Dubai',
          'dealCount': 4,
        },
      });

      expect(item.customer, isA<MaskedParty>());
      expect(item.customer is RevealedParty, isFalse);
      expect(item.customer.isMasked, isTrue);
      expect(item.customer.displayPseudonym, 'Customer in Dubai');

      final customerJson = item.customer.toJson();
      expect(customerJson.containsKey('name'), isFalse);
      expect(customerJson.containsKey('mobile'), isFalse);
      expect(customerJson.containsKey('address'), isFalse);
      expect(customerJson['isMasked'], isTrue);
    });
  });
}
