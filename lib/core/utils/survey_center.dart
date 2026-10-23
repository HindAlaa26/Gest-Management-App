import 'package:flutter/foundation.dart';

import 'package:gest_managment_app/core/models/survey.dart';
import 'package:gest_managment_app/core/network/api_service.dart';

class SurveyCenter {
  static final ValueNotifier<int> waitingCount = ValueNotifier<int>(0);

  static Future<void> refresh() async {
    try {
      final list = await ApiService().getSurveys();
      waitingCount.value =
          list.where((s) => s.status == SurveyStatus.waiting).length;
    } catch (error, stackTrace) {
      debugPrint('Could not refresh survey count: $error\n$stackTrace');
    }
  }
}
