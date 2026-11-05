import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/guest_request.dart';

GuestRequest _request({String? version, bool change = false, bool cancel = false}) {
  return GuestRequest(
    reference: 'r1',
    vendorType: VendorType.water,
    lines: const [],
    urgency: RequestUrgency.normal,
    note: '',
    createdAt: DateTime.utc(2026, 11, 4),
    status: RequestStatus.newRequest,
    version: version,
    allowChange: change,
    allowCancel: cancel,
  );
}

void main() {
  test('actions follow what the server allows', () {
    final r = _request(version: 'AAAAAAAAAAA=', change: true, cancel: true);
    expect(r.canChange, isTrue);
    expect(r.canCancel, isTrue);
  });

  test('no version or no permission means no actions', () {
    expect(_request(change: true, cancel: true).canChange, isFalse);
    expect(_request(version: 'v').canCancel, isFalse);
  });

  test('copyWith keeps the version and permissions', () {
    final r = _request(version: 'v', change: true).copyWith(urgency: RequestUrgency.urgent);
    expect(r.version, 'v');
    expect(r.canChange, isTrue);
  });
}
