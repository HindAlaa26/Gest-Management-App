import 'package:gest_managment_app/core/models/case_status.dart';
import 'package:gest_managment_app/core/models/feedback_item.dart';

class FeedbackRecord {
  const FeedbackRecord({
    required this.reference,
    required this.typeCode,
    required this.categoryCode,
    required this.message,
    required this.createdAt,
    required this.status,
    this.statusName = '',
  });

  final String reference;

  /// Backend code of the type (e.g. "Complaint").
  final String typeCode;

  /// Backend code of the category (e.g. "Housekeeping").
  final String categoryCode;
  final String message;
  final DateTime createdAt;
  final CaseStatus status;

  /// The status name (e.g. "InProgress"). 
  final String statusName;

  bool get isComplaint =>
      typeCode.toLowerCase() == FeedbackCodes.complaint.toLowerCase();
}
