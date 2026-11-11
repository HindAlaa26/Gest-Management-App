import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/models/offer.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/utils/offer_labels.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';

GuestRequest _request(RequestStatus status, {String statusName = ''}) {
  return GuestRequest(
    reference: 'x',
    vendorType: VendorType.water,
    lines: const [],
    urgency: RequestUrgency.normal,
    note: '',
    createdAt: DateTime(2026, 11, 8),
    status: status,
    statusName: statusName,
  );
}

void main() {
  group('unknown request status', () {
    test('shows the name from the backend and counts as active', () {
      final request = _request(RequestStatus.other, statusName: 'OnHold');

      expect(request.statusLabel, 'On hold');
      expect(request.status.isActive, isTrue);
    });

    test('a known status keeps its own label', () {
      final request = _request(RequestStatus.done, statusName: 'Done');

      expect(request.statusLabel, 'Done');
    });
  });

  group('unknown offer type', () {
    test('has a neutral label and icon', () {
      expect(OfferType.other.label, 'Offer');
      expect(OfferType.other.icon, isNotNull);
    });

    test('shows the name from the backend', () {
      final offer = ApiService.offerFromJson({
        'id': 'o1',
        'offerTitleEn': 'Gift',
        'offerType': 'BirthdayBonus',
        'expiredAtUtc': '2030-01-01T00:00:00Z',
      });

      expect(offer.type, OfferType.other);
      expect(offer.typeLabel, 'Birthday bonus');
    });
  });
}
