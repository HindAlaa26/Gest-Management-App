import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/chat_message.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/chat_time.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.showSenderLabel = false,
    this.onRetry,
  });

  final ChatMessage message;
  final bool showSenderLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fromGuest = message.fromGuest;
    final failed = message.status == MessageDeliveryStatus.failed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: fromGuest ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              fromGuest ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (showSenderLabel && !fromGuest)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  'HOTEL TEAM',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.goldDeep,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: fromGuest ? AppColors.teal : AppColors.card,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(fromGuest ? 18 : 4),
                    bottomRight: Radius.circular(fromGuest ? 4 : 18),
                  ),
                  border: fromGuest
                      ? null
                      : Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: Text(
                  message.text,
                  style: textTheme.bodyMedium?.copyWith(
                    color: fromGuest ? Colors.white : AppColors.navy,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (failed)
              GestureDetector(
                onTap: onRetry,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 14, color: AppColors.error),
                    const SizedBox(width: 4),
                    Text(
                      'Not sent · Tap to retry',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatClock(message.sentAt),
                    style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  if (fromGuest) ...[
                    const SizedBox(width: 4),
                    _DeliveryIcon(status: message.status),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryIcon extends StatelessWidget {
  const _DeliveryIcon({required this.status});

  final MessageDeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageDeliveryStatus.sending:
        return const Icon(Icons.schedule, size: 14, color: AppColors.muted);
      case MessageDeliveryStatus.sent:
        return const Icon(Icons.done, size: 16, color: AppColors.muted);
      case MessageDeliveryStatus.read:
        return const Icon(Icons.done_all, size: 16, color: AppColors.teal);
      case MessageDeliveryStatus.failed:
        return const SizedBox.shrink();
    }
  }
}
