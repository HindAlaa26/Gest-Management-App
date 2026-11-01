import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/offer.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/utils/offer_labels.dart';

Map<String, dynamic> dto({
  String status = 'Sent',
  String type = 'Discount',
  String? openedAt,
  String? redeemedAt,
  DateTime? expires,
}) {
  return {
    'id': 'dispatch-1',
    'offerId': 'offer-1',
    'guestProfileId': 'guest-1',
    'offerTitleAr': 'عرض',
    'offerTitleEn': 'Test - Spa 20%',
    'offerType': type,
    'status': status,
    'redemptionCode': 'ABC123',
    'deliveryChannel': 'InApp',
    'sentAtUtc': '2026-11-01T10:00:00',
    'openedAtUtc': openedAt,
    'redeemedAtUtc': redeemedAt,
    'expiredAtUtc': (expires ?? DateTime.now().add(const Duration(days: 5)))
        .toUtc()
        .toIso8601String(),
  };
}

void main() {
  group('offers from the server', () {
    test('a new offer is available and marked new', () {
      final offer = ApiService.offerFromJson(dto());

      expect(offer.id, 'dispatch-1');
      expect(offer.title, 'Test - Spa 20%');
      expect(offer.code, 'ABC123');
      expect(offer.type, OfferType.discount);
      expect(offer.status, OfferStatus.available);
      expect(offer.isNew, isTrue);
    });

    test('an opened offer is no longer new', () {
      final offer = ApiService.offerFromJson(
        dto(status: 'Opened', openedAt: '2026-11-01T11:00:00'),
      );

      expect(offer.isAvailable, isTrue);
      expect(offer.isNew, isFalse);
    });

    test('a redeemed offer is used', () {
      final offer = ApiService.offerFromJson(
        dto(status: 'Redeemed', redeemedAt: '2026-11-01T12:00:00'),
      );

      expect(offer.status, OfferStatus.used);
      expect(offerStatusText(offer), startsWith('Used on'));
    });

    test('an expired offer is expired, by server status or by date', () {
      final byStatus = ApiService.offerFromJson(dto(status: 'Expired'));
      final byDate = ApiService.offerFromJson(
        dto(expires: DateTime.now().subtract(const Duration(days: 1))),
      );

      expect(byStatus.status, OfferStatus.expired);
      expect(byDate.status, OfferStatus.expired);
      expect(offerStatusText(byDate), startsWith('Expired on'));
    });

    test('types are read from the server name or number', () {
      expect(
        ApiService.offerFromJson(dto(type: 'RoomUpgrade')).type,
        OfferType.roomUpgrade,
      );
      expect(
        ApiService.offerFromJson(dto(type: 'BonusPoints')).type,
        OfferType.bonusPoints,
      );
      expect(
        ApiService.offerFromJson(dto(type: '4')).type,
        OfferType.freeItem,
      );
    });

    test('falls back to the Arabic title when there is no English one', () {
      final json = dto()..['offerTitleEn'] = '';

      expect(ApiService.offerFromJson(json).title, 'عرض');
    });
  });
}
