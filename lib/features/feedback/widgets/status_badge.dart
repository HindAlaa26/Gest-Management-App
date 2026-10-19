import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/case_status.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/feedback_labels.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final CaseStatus status;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (status) {
      case CaseStatus.open:
        backgroundColor = AppColors.card;
        textColor = AppColors.navy;
        borderColor = AppColors.navy;
        break;
      case CaseStatus.inProgress:
        backgroundColor = AppColors.tealSoft;
        textColor = AppColors.teal;
        borderColor = AppColors.tealSoft;
        break;
      case CaseStatus.waitingOnGuest:
        backgroundColor = AppColors.goldLight;
        textColor = AppColors.goldDeep;
        borderColor = AppColors.goldLight;
        break;
      case CaseStatus.resolved:
        backgroundColor = AppColors.success.withValues(alpha: 0.12);
        textColor = AppColors.success;
        borderColor = AppColors.success.withValues(alpha: 0.12);
        break;
      case CaseStatus.closed:
        backgroundColor = const Color(0xFFF3F5F7);
        textColor = AppColors.muted;
        borderColor = const Color(0xFFF3F5F7);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
