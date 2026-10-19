import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/data/demo_data.dart';
import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/network/api_service.dart';

GuestRequest _request(
  RequestStatus status, {
  String reference = 'REQ-9001',
  List<RequestStatusEntry> history = const [],
  Duration age = const Duration(hours: 1),
}) {
  return GuestRequest(
    reference: reference,
    vendorType: VendorType.water,
    lines: [RequestLine(item: demoCatalogue.first, qty: 1)],
    urgency: RequestUrgency.normal,
    note: '',
    createdAt: DateTime.now().subtract(age),
    status: status,
    history: history,
  );
}

void _seed(List<GuestRequest> requests) {
  Session.currentStay = demoStays.first;
  ApiService.myRequestsByRoom
    ..clear()
    ..[demoStays.first.roomNumber] = requests;
}

void main() {
  group('my requests', () {
    test('lists newest first', () async {
      _seed([
        _request(
          RequestStatus.newRequest,
          reference: 'REQ-1',
          age: const Duration(hours: 3),
        ),
        _request(
          RequestStatus.newRequest,
          reference: 'REQ-2',
          age: const Duration(hours: 1),
        ),
      ]);

      final list = await ApiService().getMyRequests();

      expect(list.first.reference, 'REQ-2');
    });

    test('a New request can be cancelled with a reason', () async {
      _seed([_request(RequestStatus.newRequest)]);

      final updated = await ApiService().cancelRequest(
        reference: 'REQ-9001',
        reason: 'Changed my mind',
      );

      expect(updated.status, RequestStatus.cancelled);
      expect(updated.cancelReason, 'Changed my mind');
      expect(updated.reachedAt(RequestStatus.cancelled), isNotNull);
    });

    test('an In progress request cannot be cancelled or changed', () async {
      _seed([_request(RequestStatus.inProgress)]);

      await expectLater(
        ApiService().cancelRequest(reference: 'REQ-9001', reason: 'x'),
        throwsA(isA<RequestNotAllowedException>()),
      );
      await expectLater(
        ApiService().changeRequest(
          reference: 'REQ-9001',
          lines: [RequestLine(item: demoCatalogue.first, qty: 2)],
          urgency: RequestUrgency.urgent,
        ),
        throwsA(isA<RequestNotAllowedException>()),
      );
    });

    test('changing a New request updates quantity and urgency', () async {
      _seed([_request(RequestStatus.newRequest)]);

      final updated = await ApiService().changeRequest(
        reference: 'REQ-9001',
        lines: [RequestLine(item: demoCatalogue.first, qty: 3)],
        urgency: RequestUrgency.urgent,
      );

      expect(updated.lines.first.qty, 3);
      expect(updated.urgency, RequestUrgency.urgent);
    });

    test('a Done request can be rated once', () async {
      final doneAt = DateTime.now().subtract(const Duration(hours: 2));
      _seed([
        _request(
          RequestStatus.done,
          history: [RequestStatusEntry(status: RequestStatus.done, at: doneAt)],
        ),
      ]);

      final rated = await ApiService().rateRequest(
        reference: 'REQ-9001',
        stars: 5,
        comment: 'Great',
      );

      expect(rated.rating?.stars, 5);
      await expectLater(
        ApiService().rateRequest(reference: 'REQ-9001', stars: 4),
        throwsA(isA<RequestNotAllowedException>()),
      );
    });

    test('rating closes after 24 hours', () {
      final doneAt = DateTime.now().subtract(const Duration(hours: 25));
      final request = _request(
        RequestStatus.done,
        history: [RequestStatusEntry(status: RequestStatus.done, at: doneAt)],
      );

      expect(request.canRate, isFalse);
    });
  });
}
