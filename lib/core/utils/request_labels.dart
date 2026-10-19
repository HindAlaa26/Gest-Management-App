import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';

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
  String get label {
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
    }
  }
}

extension RequestUrgencyLabels on RequestUrgency {
  String get label {
    switch (this) {
      case RequestUrgency.normal:
        return 'Normal';
      case RequestUrgency.urgent:
        return 'Urgent';
    }
  }
}

String formatPrice(double price) {
  if (price <= 0) return 'Free';
  final text = price == price.roundToDouble()
      ? price.toStringAsFixed(0)
      : price.toStringAsFixed(2);
  return '$text EGP';
}
