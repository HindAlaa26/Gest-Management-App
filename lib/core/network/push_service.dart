import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:gest_managment_app/core/models/app_notification.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/utils/notification_center.dart';
import 'package:gest_managment_app/core/utils/notification_router.dart';
import 'package:gest_managment_app/firebase_options.dart';

class PushService {
  static bool enabled = false;
  static RemoteMessage? _pendingOpen;
  static bool _listeningToTokenRefresh = false;

  /// Call once before runApp. Never throws.
  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final messaging = FirebaseMessaging.instance;
      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);
      _pendingOpen = await messaging.getInitialMessage();
      debugPrint(
        'PUSH [initial] id=${_pendingOpen?.messageId} data=${_pendingOpen?.data}',
      );
      enabled = true;
      debugPrint('PUSH [ready]');
    } catch (error) {
      debugPrint('Push is off (Firebase is not set up yet): $error');
    }
  }

   
  static Future<void> onSignedIn() async {
    if (!enabled) return;

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      // ignore: deprecated_member_use
      final token = await messaging.getToken();
      if (token != null) {
        if (kDebugMode) {
          debugPrint('FCM token: $token');
        }
        await ApiService().registerPushToken(token);
      }

      if (!_listeningToTokenRefresh) {
        _listeningToTokenRefresh = true;
        // ignore: deprecated_member_use
        messaging.onTokenRefresh.listen((token) {
          if (kDebugMode) {
            debugPrint('FCM token: $token');
          }
          ApiService().registerPushToken(token);
        });
      }
    } catch (error) {
      debugPrint('Could not register for push: $error');
    }

    final pending = _pendingOpen;
    _pendingOpen = null;
    if (pending != null) {
      _onOpened(pending);
    }
  }

  static AppNotification _toNotification(RemoteMessage message) {
    final data = message.data;
    final NotificationType type;
    switch (data['type']) {
      case 'request':
        type = NotificationType.requestUpdate;
        break;
      case 'message':
        type = NotificationType.message;
        break;
      case 'survey':
        type = NotificationType.survey;
        break;
      default:
        type = NotificationType.general;
    }

    return AppNotification(
      id: message.messageId ?? 'push-${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      createdAt: DateTime.now(),
      targetId: data['targetId']?.toString(),
    );
  }

  static void _onForeground(RemoteMessage message) {
    debugPrint(
      'PUSH [foreground] id=${message.messageId} data=${message.data}',
    );
    final notification = _toNotification(message);

    // BACKEND LATER: the list will come from the API; remove this local insert then.
    ApiService().addNotification(notification);
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.mediumImpact();
    NotificationCenter.refresh();

    NotificationRouter.messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          notification.body.isEmpty
              ? notification.title
              : '${notification.title}: ${notification.body}',
        ),
        duration: const Duration(seconds: 4),
        persist: false,
        action: SnackBarAction(
          label: 'Open',
          onPressed: () => NotificationRouter.open(
            notification.type,
            notification.targetId,
          ),
        ),
      ),
    );
  }

  static void _onOpened(RemoteMessage message) {
    debugPrint('PUSH [opened] id=${message.messageId} data=${message.data}');
    final notification = _toNotification(message);

    // BACKEND LATER: the list will come from the API; remove this local insert then.
    ApiService().addNotification(notification.copyWith(read: true));
    NotificationCenter.refresh();

    NotificationRouter.open(notification.type, notification.targetId);
  }
}
