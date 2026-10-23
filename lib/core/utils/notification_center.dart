import 'package:flutter/foundation.dart';

import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/utils/survey_center.dart';

class NotificationCenter {
  static final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  static Future<void> refresh() async {
    try {
      final list = await ApiService().getNotifications();
      unreadCount.value = list.where((n) => !n.read).length;
      SurveyCenter.refresh();
    } catch (_) {
     
    }
  }
}
