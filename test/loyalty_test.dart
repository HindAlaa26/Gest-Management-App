import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/loyalty.dart';
import 'package:gest_managment_app/core/utils/loyalty_labels.dart';

void main() {
  group('loyalty', () {
    test('the tier comes from the server tier name', () {
      const account = LoyaltyAccount(serverTierName: 'Gold', tierPoints: 0);

      expect(account.tier, LoyaltyTier.gold);
      expect(account.nextTier, LoyaltyTier.platinum);
    });

    test('without a server tier name the tier falls back to the points', () {
      const account = LoyaltyAccount(tierPoints: 5000);

      expect(account.tier, LoyaltyTier.platinum);
      expect(account.nextTier, isNull);
      expect(account.pointsToNext, 0);
      expect(account.progress, 1.0);
    });

    test('a guest with no tier points is Silver and 1,000 points from Gold', () {
      const account = LoyaltyAccount(balance: 150, tierPoints: 0);

      expect(account.tier, LoyaltyTier.silver);
      expect(account.nextTier, LoyaltyTier.gold);
      expect(account.pointsToNext, 1000);
      expect(account.progress, 0.0);
    });

    test('points are formatted with thousand separators and signs', () {
      expect(formatPoints(950), '950');
      expect(formatPoints(2450), '2,450');
      expect(formatPoints(1234567), '1,234,567');
      expect(formatSignedPoints(450), '+450');
      expect(formatSignedPoints(-200), '-200');
      expect(formatSignedPoints(0), '0');
    });
  });
}
