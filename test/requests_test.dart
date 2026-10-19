import 'package:flutter_test/flutter_test.dart';

import 'package:gest_managment_app/core/data/demo_data.dart';
import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/network/api_service.dart';

void main() {
  group('guest requests', () {
    test('catalogue returns only items of the chosen vendor type', () async {
      final items = await ApiService().getCatalogue(VendorType.water);

      expect(items, isNotEmpty);
      expect(
        items.every((item) => item.vendorType == VendorType.water),
        isTrue,
      );
    }); 

    test('sendRequest returns a REQ- request and stores it as New', () async {
      ApiService.myRequestsByRoom.clear();
      Session.currentStay = demoStays.first;

      final items = await ApiService().getCatalogue(VendorType.water);
      final request = await ApiService().sendRequest(
        vendorType: VendorType.water,
        urgency: RequestUrgency.urgent,
        lines: [RequestLine(item: items.first, qty: 2)],
        note: 'Please hurry',
      );

      expect(request.reference.startsWith('REQ-'), isTrue);
      expect(request.status, RequestStatus.newRequest);
      final stored = ApiService.myRequestsByRoom[demoStays.first.roomNumber]!;
      expect(stored, hasLength(1));
      expect(stored.first.urgency, RequestUrgency.urgent);
    });

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
  });
}
