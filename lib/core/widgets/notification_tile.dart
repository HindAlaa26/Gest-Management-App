import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/app_notification.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  IconData get icon {
    switch (notification.type) {
      case NotificationType.requestUpdate:
        return Icons.room_service_outlined;
      case NotificationType.message:
        return Icons.chat_bubble_outline;
      case NotificationType.survey:
        return Icons.poll_outlined;
      case NotificationType.general:
        return Icons.notifications_none_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final unread = !notification.read;

    return RoyalCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.tealSoft,
            ),
            child: Icon(icon, color: AppColors.teal, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.navy,
                    fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (notification.body.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.text),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  formatRequestTime(notification.createdAt),
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (unread) ...[
            const SizedBox(width: 8),
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
