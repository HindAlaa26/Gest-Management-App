import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/case_status.dart';
import 'package:gest_managment_app/core/models/feedback_item.dart';

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
    }
  }
}
