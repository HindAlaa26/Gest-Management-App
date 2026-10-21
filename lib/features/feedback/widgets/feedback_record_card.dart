import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/feedback_item.dart';
import 'package:gest_managment_app/core/models/feedback_record.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/feedback_labels.dart';
import 'package:gest_managment_app/core/utils/helpers.dart';
import 'package:gest_managment_app/core/widgets/app_card.dart';
import 'package:gest_managment_app/features/feedback/widgets/status_badge.dart';

class FeedbackRecordCard extends StatelessWidget {
  const FeedbackRecordCard({
    super.key,
    required this.record,
    required this.onTap,
  });

  final FeedbackRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.tealSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  record.category.icon,
                  color: AppColors.teal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record.type.label} · ${record.category.label}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (record.type == FeedbackType.complaint)
                StatusBadge(status: record.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            record.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.text,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.reference,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.muted,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                formatDateTime(record.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
