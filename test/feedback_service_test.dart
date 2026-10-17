import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/feedback_item.dart';
import 'package:gest_managment_app/core/network/api_service.dart';

void main() {
  group('feedback service', () {
    test('stores sent items and returns a valid GMS reference', () async {
      ApiService.sentItems.clear();

      final item = FeedbackItem(
        type: FeedbackType.complaint,
        category: FeedbackCategory.food,
        message: 'The soup was cold.',
      );

      final reference = await ApiService().sendFeedback(item);

      expect(reference.startsWith('GMS-'), isTrue);
      expect(ApiService.sentItems, hasLength(1));
      expect(ApiService.sentItems.first.message, 'The soup was cold.');
      expect(ApiService.sentItems.first.category, FeedbackCategory.food);
    });
  });
}
