import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/data_request.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/utils/data_request_labels.dart';

Map<String, dynamic> _export(String status, {String? ready, String? expires}) {
  return {
    'exportId': 'e1',
    'status': status,
    'requestedAtUtc': '2026-11-01T09:00:00',
    'readyAtUtc': ready,
    'expiresAtUtc': expires,
  };
}

void main() {
  group('my data: copy of my data', () {
    test('a ready copy can be downloaded until it expires', () {
      final expires = DateTime.now().toUtc().add(const Duration(days: 2));
      final request = ApiService.dataRequestFromExportJson(
        _export(
          'Ready',
          ready: '2026-11-01T09:05:00',
          expires: expires.toIso8601String(),
        ),
      );

      expect(request.type, DataRequestType.export);
      expect(request.status, DataRequestStatus.done);
      expect(request.canDownload, isTrue);
      expect(dataRequestNote(request), startsWith('Your copy is ready'));
    });

    test('an expired copy cannot be downloaded', () {
      final request = ApiService.dataRequestFromExportJson(
        _export('Expired'),
      );

      expect(request.linkExpired, isTrue);
      expect(request.canDownload, isFalse);
      expect(dataRequestNote(request), contains('expired'));
    });

    test('requested and processing copies are active', () {
      for (final status in ['Requested', 'Processing', 'RetryPending']) {
        final request = ApiService.dataRequestFromExportJson(_export(status));
        expect(request.isActive, isTrue, reason: status);
        expect(request.canDownload, isFalse, reason: status);
      }
    });

    test('failed and revoked copies show as failed', () {
      for (final status in ['Failed', 'Revoked']) {
        final request = ApiService.dataRequestFromExportJson(_export(status));
        expect(request.status, DataRequestStatus.failed, reason: status);
      }
    });
  });

  group('my data: delete my data', () {
    Map<String, dynamic> removal(String status, {String? done}) => {
          'requestId': 'r1',
          'status': status,
          'requestedAtUtc': '2026-11-01T09:00:00',
          'completedAtUtc': done,
        };

    test('requested, queued and processing are active', () {
      for (final status in ['Requested', 'Queued', 'Processing', 'RetryPending']) {
        final request = ApiService.dataRequestFromRemovalJson(removal(status));
        expect(request.type, DataRequestType.delete, reason: status);
        expect(request.isActive, isTrue, reason: status);
      }
    });

    test('completed is done and failed or cancelled is failed', () {
      final done = ApiService.dataRequestFromRemovalJson(
        removal('Completed', done: '2026-11-01T10:00:00'),
      );
      expect(done.status, DataRequestStatus.done);
      expect(done.completedAt, isNotNull);

      for (final status in ['Failed', 'Cancelled']) {
        expect(
          ApiService.dataRequestFromRemovalJson(removal(status)).status,
          DataRequestStatus.failed,
          reason: status,
        );
      }
    });
  });
}
