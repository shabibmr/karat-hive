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
    });

    test('wireName returns uppercase wire representation', () {
      expect(UserRole.customer.wireName, 'CUSTOMER');
      expect(UserRole.vendor.wireName, 'VENDOR');
      expect(UserRole.unknown.wireName, 'UNKNOWN');
    });

    test('PartyRole is typedef alias for UserRole', () {
      const PartyRole role = UserRole.vendor;
      expect(role, UserRole.vendor);
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
        rating: RatingSummary(average: 4.8, count: 20),
        dealCount: 35,
      );

      expect(party.role, UserRole.vendor);
      expect(party.region, 'Deira');
      expect(party.pseudonym, 'Gold Merchant in Deira');
      expect(party.displayPseudonym, 'Gold Merchant in Deira');
      expect(party.rating?.average, 4.8);
      expect(party.ratingScore, 4.8);
      expect(party.dealCount, 35);
      expect(party.completedConnections, 35);
      expect(party.isMasked, isTrue);
      expect(party.isRevealed, isFalse);
    });

    test('generates fallback displayPseudonym when pseudonym is absent', () {
      const vendorParty = MaskedParty(
        role: UserRole.vendor,
        region: 'Deira',
      );
      expect(vendorParty.displayPseudonym, 'Vendor in Deira');

      const customerParty = MaskedParty(
        role: UserRole.customer,
        region: 'Sharjah',
      );
      expect(customerParty.displayPseudonym, 'Customer in Sharjah');

      const unknownRegionParty = MaskedParty(
        role: UserRole.vendor,
      );
      expect(unknownRegionParty.displayPseudonym, 'Vendor');
    });

    test('parses from JSON correctly', () {
      final party = MaskedParty.fromJson({
        'role': 'VENDOR',
        'region': 'Gold Souk',
        'pseudonym': 'Vendor in Gold Souk',
        'rating': {'average': 4.7, 'count': 8},
        'dealCount': 12,
      });

      expect(party.role, UserRole.vendor);
      expect(party.region, 'Gold Souk');
      expect(party.pseudonym, 'Vendor in Gold Souk');
      expect(party.rating?.average, 4.7);
      expect(party.dealCount, 12);
    });

    test('parses region from nested object if provided by API', () {
      final party = MaskedParty.fromJson({
        'role': 'CUSTOMER',
        'region': {'id': 'reg-1', 'nameEn': 'Downtown Dubai'},
      });
      expect(party.region, 'Downtown Dubai');
    });

    test('parses connection count aliases in JSON', () {
      final party1 = MaskedParty.fromJson({
        'role': 'VENDOR',
        'completedConnections': 18,
      });
      expect(party1.dealCount, 18);

      final party2 = MaskedParty.fromJson({
        'role': 'VENDOR',
        'connectionCount': 22,
      });
      expect(party2.dealCount, 22);
    });

    test('serializes to JSON with isMasked flag and no identity fields', () {
      const party = MaskedParty(
        role: UserRole.vendor,
        region: 'Deira',
        pseudonym: 'Vendor in Deira',
        dealCount: 5,
      );
      final json = party.toJson();
      expect(json['role'], 'VENDOR');
      expect(json['region'], 'Deira');
      expect(json['pseudonym'], 'Vendor in Deira');
      expect(json['dealCount'], 5);
      expect(json['isMasked'], isTrue);
      // Verify identity keys are NOT present
      expect(json.containsKey('name'), isFalse);
      expect(json.containsKey('mobile'), isFalse);
      expect(json.containsKey('address'), isFalse);
    });

    test('copyWith updates fields without mutating original', () {
      const original = MaskedParty(
        role: UserRole.vendor,
        region: 'Deira',
        dealCount: 1,
      );
      final modified = original.copyWith(region: 'Bur Dubai', dealCount: 2);
      expect(original.region, 'Deira');
      expect(original.dealCount, 1);
      expect(modified.region, 'Bur Dubai');
      expect(modified.dealCount, 2);
      expect(modified.role, UserRole.vendor);
    });

    test('value equality and hashCode', () {
      const p1 = MaskedParty(role: UserRole.vendor, region: 'Deira');
      const p2 = MaskedParty(role: UserRole.vendor, region: 'Deira');
      const p3 = MaskedParty(role: UserRole.vendor, region: 'Sharjah');
      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1, isNot(equals(p3)));
    });
  });

  group('RevealedParty', () {
    test('constructs with name, mobile, address, role, business, rating, dealCount', () {
      const party = RevealedParty(
        name: 'Tariq Al Hashimi',
        mobile: '+971501234567',
        role: UserRole.vendor,
        address: 'Shop 102, Deira Gold Souk, Dubai',
        business: 'Al Hashimi Jewellery LLC',
        rating: RatingSummary(average: 4.9, count: 50),
        dealCount: 75,
      );

      expect(party.name, 'Tariq Al Hashimi');
      expect(party.displayName, 'Tariq Al Hashimi');
      expect(party.mobile, '+971501234567');
      expect(party.role, UserRole.vendor);
      expect(party.address, 'Shop 102, Deira Gold Souk, Dubai');
      expect(party.business, 'Al Hashimi Jewellery LLC');
      expect(party.rating?.average, 4.9);
      expect(party.dealCount, 75);
      expect(party.completedConnections, 75);
      expect(party.isRevealed, isTrue);
      expect(party.isMasked, isFalse);
    });

    test('parses from revealed JSON payload', () {
      final party = RevealedParty.fromJson({
        'name': 'Fatima Al Zahra',
        'mobile': '+971559876543',
        'role': 'CUSTOMER',
        'address': 'Villa 12, Jumeirah 1, Dubai',
        'rating': 5.0,
        'dealCount': 3,
      });

      expect(party.name, 'Fatima Al Zahra');
      expect(party.mobile, '+971559876543');
      expect(party.role, UserRole.customer);
      expect(party.address, 'Villa 12, Jumeirah 1, Dubai');
      expect(party.rating?.average, 5.0);
      expect(party.dealCount, 3);
    });

    test('parses alias fields displayName and mobileNumber', () {
      final party = RevealedParty.fromJson({
        'displayName': 'Al Baraka Gold LLC',
        'mobileNumber': '+971520001122',
        'role': 'VENDOR',
        'legalBusinessName': 'Al Baraka Gold Trading FZE',
      });

      expect(party.name, 'Al Baraka Gold LLC');
      expect(party.mobile, '+971520001122');
      expect(party.business, 'Al Baraka Gold Trading FZE');
    });

    test('serializes to JSON with isRevealed flag and identity fields', () {
      const party = RevealedParty(
        name: 'Tariq',
        mobile: '+971501234567',
        role: UserRole.vendor,
        address: 'Deira',
      );
      final json = party.toJson();
      expect(json['name'], 'Tariq');
      expect(json['mobile'], '+971501234567');
      expect(json['role'], 'VENDOR');
      expect(json['address'], 'Deira');
      expect(json['isRevealed'], isTrue);
    });

    test('copyWith updates fields correctly', () {
      const original = RevealedParty(
        name: 'Original Name',
        mobile: '+971501111111',
        role: UserRole.vendor,
      );
      final modified = original.copyWith(name: 'Updated Name');
      expect(original.name, 'Original Name');
      expect(modified.name, 'Updated Name');
      expect(modified.mobile, '+971501111111');
    });

    test('value equality and hashCode', () {
      const p1 = RevealedParty(
        name: 'Same',
        mobile: '+971500000000',
        role: UserRole.customer,
      );
      const p2 = RevealedParty(
        name: 'Same',
        mobile: '+971500000000',
        role: UserRole.customer,
      );
      const p3 = RevealedParty(
        name: 'Different',
        mobile: '+971500000000',
        role: UserRole.customer,
      );
      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1, isNot(equals(p3)));
    });
  });

  group('AD-FE-07 Sealed Type Invariants and Masking Enforcement', () {
    test('Party.fromJson constructs MaskedParty when identity fields are absent', () {
      final maskedPayload = {
        'role': 'VENDOR',
        'region': 'Deira',
        'pseudonym': 'Vendor in Deira',
        'rating': {'average': 4.8, 'count': 12},
        'dealCount': 25,
      };

      final party = Party.fromJson(maskedPayload);

      // Must be MaskedParty, structurally guaranteed
      expect(party, isA<MaskedParty>());
      expect(party is RevealedParty, isFalse);
      expect(party.isMasked, isTrue);
      expect(party.isRevealed, isFalse);

      final masked = party as MaskedParty;
      expect(masked.role, UserRole.vendor);
      expect(masked.region, 'Deira');
      expect(masked.dealCount, 25);
    });

    test('Party.fromJson constructs MaskedParty when identity fields are explicitly null', () {
      final maskedPayloadWithNulls = {
        'name': null,
        'displayName': null,
        'mobile': null,
        'mobileNumber': null,
        'role': 'CUSTOMER',
        'region': 'Downtown Dubai',
      };

      final party = Party.fromJson(maskedPayloadWithNulls);

      expect(party, isA<MaskedParty>());
      expect(party is RevealedParty, isFalse);
    });

    test('Party.fromJson constructs MaskedParty when identity fields are blank / whitespace', () {
      final maskedPayloadWithBlanks = {
        'name': '   ',
        'mobile': '  ',
        'role': 'VENDOR',
        'region': 'Sharjah',
      };

      final party = Party.fromJson(maskedPayloadWithBlanks);

      expect(party, isA<MaskedParty>());
      expect(party is RevealedParty, isFalse);
    });

    test('Party.fromJson constructs MaskedParty when payload is explicitly marked masked', () {
      final payload = {
        'name': 'Should Be Hidden',
        'mobile': '+971501234567',
        'role': 'VENDOR',
        'region': 'Deira',
        'isMasked': true,
      };

      final party = Party.fromJson(payload);

      expect(party, isA<MaskedParty>());
      expect(party is RevealedParty, isFalse);
    });

    test('CRITICAL: RevealedParty.fromJson throws on masked payload (cannot construct RevealedParty)', () {
      final maskedPayload = {
        'role': 'VENDOR',
        'region': 'Deira',
        'rating': 4.5,
        'dealCount': 10,
      };

      // Direct construction of RevealedParty from masked payload MUST fail
      expect(
        () => RevealedParty.fromJson(maskedPayload),
        throwsA(isA<FormatException>()),
      );

      final payloadMissingMobile = {
        'name': 'John Doe',
        'role': 'CUSTOMER',
      };
      expect(
        () => RevealedParty.fromJson(payloadMissingMobile),
        throwsA(isA<FormatException>()),
      );

      final payloadMissingName = {
        'mobile': '+971501234567',
        'role': 'VENDOR',
      };
      expect(
        () => RevealedParty.fromJson(payloadMissingName),
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
      expect(revealed.mobile, '+971501234567');
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
  });
}
