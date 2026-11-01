import 'package:flutter_test/flutter_test.dart';
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

    test('nothing is listed before the guest sends something', () async {
      expect(await ApiService().getMyFeedback(), isEmpty);
    });
  });
}
