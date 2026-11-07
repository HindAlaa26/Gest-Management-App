import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/loyalty.dart';

void main() {
  group('loyalty from the backend', () {
    test('the next tier name and threshold come from the backend', () {
      const account = LoyaltyAccount(
        fromServer: true,
        serverTierName: 'Gold',
        tierPoints: 1200,
        nextTierName: 'Diamond',
        nextTierThreshold: 3000,
        expiryMonths: 18,
      );

      expect(account.hasNextTier, isTrue);
      expect(account.nextTierLabel, 'Diamond');
      expect(account.pointsToNext, 1800);
      expect(account.progress, closeTo(0.4, 0.0001));
      expect(account.expiryMonths, 18);
    });

    test('no next tier from the backend means the top tier', () {
      const account = LoyaltyAccount(
        fromServer: true,
        serverTierName: 'Platinum',
        tierPoints: 9000,
      );

      expect(account.hasNextTier, isFalse);
      expect(account.pointsToNext, 0);
      expect(account.progress, 1.0);
    });

    test('points to the next tier never go below zero', () {
      const account = LoyaltyAccount(
        fromServer: true,
        tierPoints: 1500,
        nextTierName: 'Gold',
        nextTierThreshold: 1000,
      );

      expect(account.pointsToNext, 0);
      expect(account.progress, 1.0);
    });
  });
}
