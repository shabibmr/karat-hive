import 'package:kh_domain/kh_domain.dart';
import 'package:test/test.dart';

void main() {
  group('formatRequestDisplayTitle', () {
    test('ornament: Ring 22gm 22K', () {
      expect(
        formatRequestDisplayTitle(
          requestType: RequestType.findOrnament,
          ornamentType: OrnamentType.ring,
          weightGrams: '22',
          purityKarat: Karat.k22,
        ),
        'Ring 22gm 22K',
      );
    });

    test('strips trailing zeros from weight', () {
      expect(
        formatRequestDisplayTitle(
          requestType: RequestType.sellOldGold,
          ornamentType: OrnamentType.necklace,
          weightGrams: 22.00,
          purityKaratLabel: '22K',
        ),
        'Necklace 22gm 22K',
      );
    });

    test('gold coin with quantity and denomination', () {
      expect(
        formatRequestDisplayTitle(
          requestType: RequestType.goldCoin,
          quantity: 2,
          denominationGrams: '8',
          purityKarat: Karat.k22,
        ),
        '2× 8g Coin 22K',
      );
    });

    test('gold bullion', () {
      expect(
        formatRequestDisplayTitle(
          requestType: RequestType.goldBullion,
          weightGrams: 100,
          purityKarat: Karat.k24,
        ),
        '100gm Bullion 24K',
      );
    });

    test('falls back to request type', () {
      expect(
        formatRequestDisplayTitle(requestType: RequestType.findOrnament),
        'Find An Ornament',
      );
      expect(
        formatRequestDisplayTitle(requestType: RequestType.sellOldGold),
        'Sell Old Gold',
      );
      expect(
        formatRequestDisplayTitle(fallback: 'Request'),
        'Request',
      );
    });

    test('never returns KH-RQ reference', () {
      final title = formatRequestDisplayTitle(
        requestType: RequestType.findOrnament,
        ornamentType: OrnamentType.bangle,
        weightGrams: '10.5',
        purityKarat: Karat.k21,
      );
      expect(title, 'Bangle 10.5gm 21K');
      expect(title.contains('KH-RQ'), isFalse);
    });
  });
}
