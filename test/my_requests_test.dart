import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/guest_request.dart';

GuestRequest _request(
  RequestStatus status, {
  List<RequestStatusEntry> history = const [],
  RequestRating? rating,
}) {
  return GuestRequest(
    reference: 'REQ-TEST',
    vendorType: VendorType.water,
    lines: const [],
    urgency: RequestUrgency.normal,
    note: '',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    status: status,
    history: history,
    rating: rating,
  );
}

List<RequestStatusEntry> _doneAgo(Duration age) {
  return [
    RequestStatusEntry(
      status: RequestStatus.done,
      at: DateTime.now().subtract(age),
    ),
  ];
}

void main() {
  group('my requests', () {
    test('a Done request can be rated within 24 hours', () {
      final request = _request(
        RequestStatus.done,
        history: _doneAgo(const Duration(hours: 2)),
      );

      expect(request.canRate, isTrue);
    });

    test('rating closes after 24 hours', () {
      final request = _request(
        RequestStatus.done,
        history: _doneAgo(const Duration(hours: 25)),
      );

      expect(request.canRate, isFalse);
    });

    test('a request can be rated only once', () {
      final request = _request(
        RequestStatus.done,
        history: _doneAgo(const Duration(hours: 2)),
        rating: RequestRating(stars: 5, ratedAt: DateTime.now()),
      );

      expect(request.canRate, isFalse);
    });

    test('only Done requests can be rated', () {
      expect(_request(RequestStatus.inProgress).canRate, isFalse);
    });
  });
}
