import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/loyalty.dart';
import 'package:gest_managment_app/core/utils/loyalty_labels.dart';

void main() {
  group('loyalty neutral look', () {
    test('an unknown tier name from the backend gets the Silver look', () {
      const account = LoyaltyAccount(
        fromServer: true,
        serverTierName: 'Diamond',
        tierPoints: 9000,
      );

      expect(account.tier, LoyaltyTier.silver);
      expect(account.tierLabel, 'Diamond');
    });

    test('known tier names keep their own look', () {
      const gold = LoyaltyAccount(serverTierName: 'Gold');
      const platinum = LoyaltyAccount(serverTierName: 'platinum');

      expect(gold.tier, LoyaltyTier.gold);
      expect(platinum.tier, LoyaltyTier.platinum);
    });

    test('an unknown activity type has a neutral icon', () {
      expect(LoyaltyEntryType.other.icon, Icons.more_horiz);
    });
  });
}
