import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';

class RequestStatusBadge extends StatelessWidget {
  const RequestStatusBadge({super.key, required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;

    switch (status) {
      case RequestStatus.newRequest:
        background = AppColors.tealSoft;
        foreground = AppColors.teal;
        break;
      case RequestStatus.assigned:
        background = AppColors.goldLight;
        foreground = AppColors.goldDeep;
        break;
      case RequestStatus.inProgress:
        background = AppColors.navy.withValues(alpha: 0.08);
        foreground = AppColors.navy;
        break;
      case RequestStatus.done:
        background = AppColors.success.withValues(alpha: 0.12);
        foreground = AppColors.success;
        break;
      case RequestStatus.cancelled:
        background = const Color(0xFFF3F5F7);
        foreground = AppColors.muted;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
