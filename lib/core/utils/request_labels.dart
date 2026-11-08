import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/utils/chat_time.dart';
import 'package:gest_managment_app/core/utils/request_lookups.dart';

extension VendorTypeLabels on VendorType {
  /// Name from GET /api/lookups/request-vendor-types.
  String get label => RequestLookups.vendorLabel(this);

  IconData get icon {
    if (this == VendorType.water) return Icons.water_drop_outlined;
    if (this == VendorType.drinks) return Icons.local_cafe_outlined;
    if (this == VendorType.cleaning) return Icons.cleaning_services_outlined;
    if (this == VendorType.maintenance) return Icons.build_outlined;
    if (this == VendorType.other) return Icons.more_horiz;
    return Icons.category_outlined;
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
      case RequestStatus.other:
        return 'other';
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
      case RequestStatus.other:
        return 'Update';
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
      this == RequestStatus.inProgress ||
      this == RequestStatus.other;
}

extension GuestRequestLabels on GuestRequest {
  /// The status name shown to the guest. A status the app does not know uses
  /// the name sent by the backend.
  String get statusLabel {
    if (status != RequestStatus.other || statusName.isEmpty) {
      return status.label;
    }
    return RequestLookups.status(statusName.toLowerCase()) ??
        RequestLookups.humanize(statusName);
  }
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
