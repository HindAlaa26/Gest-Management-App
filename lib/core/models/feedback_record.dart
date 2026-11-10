import 'package:gest_managment_app/core/models/case_status.dart';
import 'package:gest_managment_app/core/models/feedback_item.dart';

class FeedbackRecord {
  const FeedbackRecord({
    required this.reference,
    required this.type,
    required this.category,
    required this.message,
    required this.createdAt,
    required this.status,
    this.statusName = '',
  });

  final String reference;
  final FeedbackType type;
  final FeedbackCategory category;
  final String message;
  final DateTime createdAt;
  final CaseStatus status;

  /// The status as the backend names it (e.g. "InProgress"). Empty for items made in the app.
  final String statusName;
}
