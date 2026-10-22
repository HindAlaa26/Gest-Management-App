import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/network/push_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/notification_center.dart';
import 'package:gest_managment_app/features/notifications/notifications_screen.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  @override
  void initState() {
    super.initState();
    NotificationCenter.refresh();
    PushService.onSignedIn();
  }

  Future<void> openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
    NotificationCenter.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: NotificationCenter.unreadCount,
      builder: (context, count, _) {
        return IconButton(
          onPressed: openNotifications,
          tooltip: 'Notifications',
          icon: Badge(
            label: Text('$count'),
            isLabelVisible: count > 0,
            backgroundColor: AppColors.error,
            child: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.gold,
            ),
          ),
        );
      },
    );
  }
}
