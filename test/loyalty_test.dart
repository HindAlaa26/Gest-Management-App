import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/data/demo_data.dart';
import 'package:gest_managment_app/core/models/loyalty.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/utils/loyalty_labels.dart';

LoyaltyEntry earnEntry(int points, int daysAgo) {
  return LoyaltyEntry(
    id: 'e-$daysAgo-$points',
    type: LoyaltyEntryType.earn,
    points: points,
    reason: 'Stay',
    source: 'Stay',
    date: DateTime.now().subtract(Duration(days: daysAgo)),
  );
}

void main() {
  group('loyalty', () {
    test('room 305 is Gold with the newest entry first', () async {
      Session.currentStay = demoStays.first;

      final account = await ApiService().getLoyalty();

      expect(account.balance, 2450);
      expect(account.tier, LoyaltyTier.gold);
      expect(account.nextTier, LoyaltyTier.platinum);
      expect(account.pointsToNext, 2100);
      for (var i = 1; i < account.entries.length; i++) {
        expect(
          account.entries[i].date.isAfter(account.entries[i - 1].date),
          isFalse,
        );
      }
    });

    test('a room without points is Silver with an empty history', () async {
      Session.currentStay = demoStays[1];

      final account = await ApiService().getLoyalty();

      expect(account.entries, isEmpty);
      expect(account.balance, 0);
      expect(account.tier, LoyaltyTier.silver);
      expect(account.pointsToNext, 1000);
    });

    test('5,000 earned points reach Platinum, the top tier', () {
      final account = LoyaltyAccount(entries: [earnEntry(5000, 10)]);

      expect(account.tier, LoyaltyTier.platinum);
      expect(account.nextTier, isNull);
      expect(account.pointsToNext, 0);
      expect(account.progress, 1.0);
    });

    test('points earned over 12 months ago do not count for the tier', () {
      final account = LoyaltyAccount(entries: [earnEntry(1500, 400)]);

      expect(account.balance, 1500);
      expect(account.tier, LoyaltyTier.silver);
      expect(account.pointsToNext, 1000);
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
