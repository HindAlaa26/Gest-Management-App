import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/guest_request.dart';

void main() {
  group('guest requests', () {
    test('total counts chargeable items only', () {
      const sparkling = CatalogueItem(
        id: 't1',
        vendorType: VendorType.water,
        nameEn: 'Sparkling water',
        nameAr: '',
        price: 20,
        chargeable: true,
      );
      const free = CatalogueItem(
        id: 't2',
        vendorType: VendorType.water,
        nameEn: 'Bottled water',
        nameAr: '',
        price: 0,
        chargeable: false,
      );
      const notCharged = CatalogueItem(
        id: 't3',
        vendorType: VendorType.other,
        nameEn: 'Gift',
        nameAr: '',
        price: 15,
        chargeable: false,
      );

      final total = requestTotal(const [
        RequestLine(item: sparkling, qty: 2),
        RequestLine(item: free, qty: 1),
        RequestLine(item: notCharged, qty: 3),
      ]);

      expect(total, 40);
    });

    test('a long server id is shown as a short REQ- reference', () {
      final request = GuestRequest(
        reference: '0f8fad5b-d9cb-469f-a165-70867728950e',
        vendorType: VendorType.water,
        lines: const [],
        urgency: RequestUrgency.normal,
        note: '',
        createdAt: DateTime.now(),
        status: RequestStatus.newRequest,
      );

      expect(request.shortReference, 'REQ-0F8FAD5B');
    });
  });
}
