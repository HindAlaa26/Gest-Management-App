import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/data/demo_data.dart';
import 'package:gest_managment_app/core/models/data_request.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/utils/data_request_labels.dart';

void main() {
  setUp(() {
    ApiService.myDataRequestsByRoom
      ..clear()
      ..addAll({
        for (final entry in demoDataRequestsByRoom.entries)
          entry.key: List<DataRequest>.from(entry.value),
      });
  });

  group('my data', () {
    test('room 305 has a ready copy and an expired one, newest first', () async {
      Session.currentStay = demoStays.first;

      final list = await ApiService().getDataRequests();

      expect(list, hasLength(2));
      expect(list.first.canDownload, isTrue);
      expect(list.last.linkExpired, isTrue);
      expect(list.last.canDownload, isFalse);
      expect(dataRequestNote(list.first), startsWith('Your copy is ready'));
      expect(dataRequestNote(list.last), contains('expired'));
    });

    test('room 412 has a deletion in progress', () async {
      Session.currentStay = demoStays[1];

      final list = await ApiService().getDataRequests();

      expect(list.single.type, DataRequestType.delete);
      expect(list.single.isActive, isTrue);
      expect(dataRequestNote(list.single), startsWith('We will finish by'));
    });

    test('a new copy request starts as received and shows first', () async {
      Session.currentStay = demoStays[2];

      final request = await ApiService().requestDataExport();

      expect(request.status, DataRequestStatus.pending);
      final list = await ApiService().getDataRequests();
      expect(list.first.id, request.id);
    });

    test('a second request of the same type while one is active fails', () async {
      Session.currentStay = demoStays[2];

      await ApiService().requestDataDeletion();

      expect(
        () => ApiService().requestDataDeletion(),
        throwsA(isA<DataRequestInProgressException>()),
      );
      await ApiService().requestDataExport();
      expect(await ApiService().getDataRequests(), hasLength(2));
    });

    test('the deletion deadline is 24 hours after the request', () {
      final requestedAt = DateTime(2026, 10, 28, 9);
      final request = DataRequest(
        id: 'x',
        type: DataRequestType.delete,
        status: DataRequestStatus.pending,
        requestedAt: requestedAt,
      );

      expect(request.deadline, DateTime(2026, 10, 29, 9));
    });
  });
}
