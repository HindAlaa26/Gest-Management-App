import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/utils/chat_time.dart';
import 'package:gest_managment_app/core/utils/request_lookups.dart';

extension VendorTypeLabels on VendorType {
  String get label {
    switch (this) {
      case VendorType.water:
        return 'Water';
      case VendorType.drinks:
        return 'Drinks';
      case VendorType.cleaning:
        return 'Cleaning';
      case VendorType.maintenance:
        return 'Maintenance';
      case VendorType.other:
        return 'Other';
    }
  }

  String get subtitle {
    switch (this) {
      case VendorType.water:
        return 'Bottled & sparkling';
      case VendorType.drinks:
        return 'Tea, sodas & more';
      case VendorType.cleaning:
        return 'Towels & linens';
      case VendorType.maintenance:
        return 'Repairs & adjustments';
      case VendorType.other:
        return 'Anything else you need';
    }
  }

  IconData get icon {
    switch (this) {
      case VendorType.water:
        return Icons.water_drop_outlined;
      case VendorType.drinks:
        return Icons.local_cafe_outlined;
      case VendorType.cleaning:
        return Icons.cleaning_services_outlined;
      case VendorType.maintenance:
        return Icons.build_outlined;
      case VendorType.other:
        return Icons.more_horiz;
    }
  }
}

extension RequestStatusLabels on RequestStatus {
  /// Name from GET /api/lookups/request-statuses, or the built-in text.
  String get label => RequestLookups.status(lookupKey) ?? fallbackLabel;

  String get lookupKey {
    switch (this) {
      case RequestStatus.newRequest:
        return 'new';
      case RequestStatus.assigned:
        return 'assigned';
      case RequestStatus.inProgress:
        return 'inprogress';
      case RequestStatus.done:
        return 'done';
      case RequestStatus.cancelled:
        return 'cancelled';
      case RequestStatus.failed:
        return 'failed';
    }
  }

  String get fallbackLabel {
    switch (this) {
      case RequestStatus.newRequest:
        return 'New';
      case RequestStatus.assigned:
        return 'Assigned';
      case RequestStatus.inProgress:
        return 'In progress';
      case RequestStatus.done:
        return 'Done';
      case RequestStatus.cancelled:
        return 'Cancelled';
      case RequestStatus.failed:
        return 'Not completed';
    }
  }
}

extension RequestUrgencyLabels on RequestUrgency {
  /// Name from GET /api/lookups/request-urgencies, readable ("In progress" style).
  String get label => RequestLookups.urgencyLabel(this);
}

extension RequestStatusGroups on RequestStatus {
  bool get isActive =>
      this == RequestStatus.newRequest ||
      this == RequestStatus.assigned ||
      this == RequestStatus.inProgress;
}

String formatRequestTime(DateTime time) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(time.year, time.month, time.day);
  final clock = clock12(time.hour, time.minute);
  final daysAgo = today.difference(day).inDays;

  if (daysAgo == 0) return 'Today, $clock';
  if (daysAgo == 1) return 'Yesterday, $clock';
  return '${time.day} ${months[time.month - 1]}, $clock';
}

String formatPrice(double price) {
  if (price <= 0) return 'Free';
  final text = price == price.roundToDouble()
      ? price.toStringAsFixed(0)
      : price.toStringAsFixed(2);
  return '$text EGP';
}
