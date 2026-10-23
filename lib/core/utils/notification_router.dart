import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/app_notification.dart';
import 'package:gest_managment_app/features/messages/messages_screen.dart';
import 'package:gest_managment_app/features/notifications/notifications_screen.dart';
import 'package:gest_managment_app/features/requests/my_requests_screen.dart';
import 'package:gest_managment_app/features/requests/request_details_screen.dart';
import 'package:gest_managment_app/features/surveys/surveys_screen.dart';

class NotificationRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static Future<void> open(
    NotificationType type,
    String? targetId, {
    NavigatorState? navigator,
  }) async {
    final nav = navigator ?? navigatorKey.currentState;
    if (nav == null) return;

    switch (type) {
      case NotificationType.requestUpdate:
        await nav.push(
          MaterialPageRoute(
            builder: (_) => targetId == null
                ? const MyRequestsScreen()
                : RequestDetailsScreen(reference: targetId),
          ),
        );
        break;
      case NotificationType.message:
        await nav.push(
          MaterialPageRoute(builder: (_) => const MessagesScreen()),
        );
        break;
      case NotificationType.survey:
        await nav.push(
          MaterialPageRoute(
            builder: (_) => SurveysScreen(openSurveyId: targetId),
          ),
        );
        break;
      case NotificationType.general:
        await nav.push(
          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
        );
        break;
    }
  }
}
