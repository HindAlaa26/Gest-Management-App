import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/case_status.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/utils/feedback_labels.dart';
import 'package:gest_managment_app/core/utils/named_lookup.dart';

void main() {
  group('feedback from the server', () {
    test('a feedback item is read with the backend codes and status', () {
      final record = ApiService.feedbackRecordFromJson({
        'referenceNumber': 'FB-100',
        'feedbackType': 'Complaint',
        'category': 'Housekeeping',
        'message': 'The room was not cleaned',
        'status': 'InProgress',
        'createdAtUtc': '2026-11-09T10:00:00Z',
      });

      expect(record.reference, 'FB-100');
      expect(record.typeCode, 'Complaint');
      expect(record.isComplaint, isTrue);
      expect(record.categoryCode, 'Housekeeping');
      expect(record.categoryLabel, 'Housekeeping');
      expect(record.typeLabel, 'Complaint');
      expect(record.status, CaseStatus.inProgress);
      expect(record.statusName, 'InProgress');
    });

    test('an unknown category shows the backend name with a neutral icon', () {
      final record = ApiService.feedbackRecordFromJson({
        'referenceNumber': 'FB-101',
        'feedbackType': 'Feedback',
        'category': 'ParkingLot',
        'message': 'Nice',
        'status': 'Escalated',
        'createdAtUtc': '2026-11-09T10:00:00Z',
      });

      expect(record.isComplaint, isFalse);
      expect(record.categoryLabel, 'Parking lot');
      expect(record.categoryIcon, Icons.label_outline);
      expect(record.status, CaseStatus.other);
      expect(record.statusName, 'Escalated');
    });
  });

  group('lookup lists', () {
    test('the built-in list is used until the backend list is loaded', () {
      final codes = Lookups.feedbackCategories.options.map((o) => o.code);

      expect(codes, contains('Room'));
      expect(codes, contains('Other'));
      expect(
        Lookups.feedbackTypes.options.map((o) => o.code),
        ['Feedback', 'Complaint'],
      );
    });

    test('nothing is known about offer types until they are loaded', () {
      expect(Lookups.offerTypes.options, isEmpty);
      expect(Lookups.offerTypes.nameOf('Discount'), isNull);
    });

    test('a code that is not listed is made readable', () {
      expect(Lookups.feedbackCategories.label('FreeItem'), 'Free item');
    });
  });
}
