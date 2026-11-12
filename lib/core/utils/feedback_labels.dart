import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/case_status.dart';
import 'package:gest_managment_app/core/models/feedback_record.dart';
import 'package:gest_managment_app/core/utils/case_status_lookups.dart';
import 'package:gest_managment_app/core/utils/named_lookup.dart';


IconData feedbackCategoryIcon(String code) {
  switch (code.trim().toLowerCase()) {
    case 'room':
      return Icons.bed_outlined;
    case 'food':
      return Icons.restaurant_outlined;
    case 'staff':
      return Icons.person_outline;
    case 'other':
      return Icons.more_horiz;
    case 'maintenance':
      return Icons.build_outlined;
    case 'housekeeping':
      return Icons.cleaning_services_outlined;
    case 'billing':
      return Icons.receipt_long_outlined;
    default:
      return Icons.label_outline;
  }
}

extension CaseStatusLabels on CaseStatus {
  String get label {
    switch (this) {
      case CaseStatus.open:
        return 'Open';
      case CaseStatus.inProgress:
        return 'In progress';
      case CaseStatus.waitingOnGuest:
        return 'Waiting on guest';
      case CaseStatus.resolved:
        return 'Resolved';
      case CaseStatus.closed:
        return 'Closed';
      case CaseStatus.other:
        return 'Status';
    }
  }
}

extension FeedbackRecordLabels on FeedbackRecord {
  String get statusLabel =>
      statusName.isEmpty ? status.label : CaseStatusLookups.label(statusName);

  String get typeLabel => Lookups.feedbackTypes.label(typeCode);

  String get categoryLabel => Lookups.feedbackCategories.label(categoryCode);

  IconData get categoryIcon => feedbackCategoryIcon(categoryCode);
}
