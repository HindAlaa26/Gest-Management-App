import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/data/demo_data.dart';
import 'package:gest_managment_app/core/models/offer.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/utils/offer_labels.dart';

void main() {
  setUp(() {
    ApiService.myOffersByRoom
      ..clear()
      ..addAll({
        for (final entry in demoOffersByRoom.entries)
          entry.key: List<Offer>.from(entry.value),
      });
  });

  group('offers', () {
    test('room 305 has three available offers, one used and one expired', () async {
      Session.currentStay = demoStays.first;

      final list = await ApiService().getOffers();

      expect(list.where((o) => o.status == OfferStatus.available), hasLength(3));
      expect(list.where((o) => o.status == OfferStatus.used), hasLength(1));
      expect(list.where((o) => o.status == OfferStatus.expired), hasLength(1));
      expect(list.where((o) => o.isNew), hasLength(2));
    });

    test('a room without offers gets an empty list', () async {
      Session.currentStay = demoStays[1];

      expect(await ApiService().getOffers(), isEmpty);
    });

    test('opening an offer removes its new mark', () async {
      Session.currentStay = demoStays.first;

      await ApiService().markOfferOpened('offer-1');

      final list = await ApiService().getOffers();
      expect(list.firstWhere((o) => o.id == 'offer-1').isNew, isFalse);
      expect(list.where((o) => o.isNew), hasLength(1));
    });

    test('using an available offer returns the same code every time', () async {
      Session.currentStay = demoStays.first;

      final code = await ApiService().useOffer('offer-1');

      expect(code, startsWith('GMS-'));
      expect(code, hasLength(9));
      expect(await ApiService().useOffer('offer-1'), code);
    });

    test('used, expired and unknown offers cannot be used', () async {
      Session.currentStay = demoStays.first;

      expect(
        () => ApiService().useOffer('offer-4'),
        throwsA(isA<OfferNotAvailableException>()),
      );
      expect(
        () => ApiService().useOffer('offer-5'),
        throwsA(isA<OfferNotAvailableException>()),
      );
      expect(
        () => ApiService().useOffer('nope'),
        throwsA(isA<OfferNotFoundException>()),
      );
    });

    test('status text says valid, used or expired', () async {
      Session.currentStay = demoStays.first;

      final list = await ApiService().getOffers();
      String textOf(String id) =>
          offerStatusText(list.firstWhere((o) => o.id == id));

      expect(textOf('offer-1'), startsWith('Valid until'));
      expect(textOf('offer-4'), startsWith('Used on'));
      expect(textOf('offer-5'), startsWith('Expired on'));
    });
  });
}
