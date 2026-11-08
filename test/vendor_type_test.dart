import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/utils/client_operation_id.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/utils/request_lookups.dart';

void main() {
  group('vendor types', () {
    test('built-in types are shown before the lookup loads', () {
      expect(RequestLookups.vendorTypes, VendorType.defaults);
    });

    test('codes compare without case', () {
      expect(const VendorType('water'), VendorType.water);
    });

    test('a new type from the backend gets a neutral look and its own name', () {
      const spa = VendorType('Spa');

      expect(spa.label, 'Spa');
    });
  });

  group('clientOperationId', () {
    test('is a GUID and different each time', () {
      final pattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      final first = newClientOperationId();

      expect(pattern.hasMatch(first), isTrue);
      expect(newClientOperationId(), isNot(first));
    });
  });
}
