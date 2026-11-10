import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/case_status.dart';
import 'package:gest_managment_app/core/models/feedback_item.dart';
import 'package:gest_managment_app/core/models/feedback_record.dart';
import 'package:gest_managment_app/core/utils/case_status_lookups.dart';

extension FeedbackCategoryLabels on FeedbackCategory {
  String get label {
    switch (this) {
      case FeedbackCategory.room:
        return 'Room';
      case FeedbackCategory.food:
        return 'Food';
      case FeedbackCategory.staff:
        return 'Staff';
      case FeedbackCategory.other:
        return 'Other';
      case FeedbackCategory.maintenance:
        return 'Maintenance';
      case FeedbackCategory.housekeeping:
        return 'Housekeeping';
      case FeedbackCategory.billing:
        return 'Billing';
    }
  }

  IconData get icon {
    switch (this) {
      case FeedbackCategory.room:
        return Icons.bed_outlined;
      case FeedbackCategory.food:
        return Icons.restaurant_outlined;
      case FeedbackCategory.staff:
        return Icons.person_outline;
      case FeedbackCategory.other:
        return Icons.more_horiz;
      case FeedbackCategory.maintenance:
        return Icons.build_outlined;
      case FeedbackCategory.housekeeping:
        return Icons.cleaning_services_outlined;
      case FeedbackCategory.billing:
        return Icons.receipt_long_outlined;
    }
  }
}

extension FeedbackTypeLabels on FeedbackType {
  String get label {
    switch (this) {
      case FeedbackType.feedback:
        return 'Feedback';
      case FeedbackType.complaint:
        return 'Complaint';
    }
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
  /// The status name from the backend list; the built-in label for items made in the app.
  String get statusLabel =>
      statusName.isEmpty ? status.label : CaseStatusLookups.label(statusName);
}
