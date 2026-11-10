import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/case_status.dart';
import 'package:gest_managment_app/core/models/feedback_item.dart';
import 'package:gest_managment_app/core/network/api_service.dart';

void main() {
  group('feedback to the server', () {
    test('the type is sent with the name the server expects', () {
      expect(ApiService.feedbackTypeName(FeedbackType.feedback), 'Feedback');
      expect(ApiService.feedbackTypeName(FeedbackType.complaint), 'Complaint');
    });

    test('every category is one the server accepts', () {
      const accepted = {
        'room',
        'food',
        'staff',
        'maintenance',
        'housekeeping',
        'billing',
        'other',
      };

      for (final category in FeedbackCategory.values) {
        expect(accepted, contains(ApiService.feedbackCategoryName(category)));
      }
    });

    test('a feedback item from the server is read with its status', () {
      final record = ApiService.feedbackRecordFromJson({
        'referenceNumber': 'FB-100',
        'feedbackType': 'Complaint',
        'category': 'Housekeeping',
        'message': 'The room was not cleaned',
        'status': 'InProgress',
        'createdAtUtc': '2026-11-09T10:00:00Z',
      });

      expect(record.reference, 'FB-100');
      expect(record.type, FeedbackType.complaint);
      expect(record.category, FeedbackCategory.housekeeping);
      expect(record.status, CaseStatus.inProgress);
      expect(record.statusName, 'InProgress');
    });

    test('an unknown category or status gets a neutral look', () {
      final record = ApiService.feedbackRecordFromJson({
        'referenceNumber': 'FB-101',
        'feedbackType': 'Feedback',
        'category': 'Parking',
        'message': 'Nice',
        'status': 'Escalated',
        'createdAtUtc': '2026-11-09T10:00:00Z',
      });

      expect(record.type, FeedbackType.feedback);
      expect(record.category, FeedbackCategory.other);
      expect(record.status, CaseStatus.other);
      expect(record.statusName, 'Escalated');
    });
  });
}
