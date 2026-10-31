import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/utils/app_nav.dart';
import 'package:gest_managment_app/core/utils/notification_router.dart';
import 'package:gest_managment_app/features/auth/sign_in_screen.dart';

class SessionGuard {
 
  static void expired() {
    if (Session.token == null) return;
    Session.signOut();
    AppNav.tab.value = 0;

    final navigator = NotificationRouter.navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
    NotificationRouter.messengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('Your session has ended. Please sign in again.'),
      ),
    );
  }
}
