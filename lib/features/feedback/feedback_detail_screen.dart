import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/feedback_item.dart';
import 'package:gest_managment_app/core/models/feedback_record.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/feedback_labels.dart';
import 'package:gest_managment_app/core/utils/helpers.dart';
import 'package:gest_managment_app/core/widgets/app_card.dart';
import 'package:gest_managment_app/core/widgets/info_row.dart';
import 'package:gest_managment_app/features/feedback/widgets/status_badge.dart';

class FeedbackDetailScreen extends StatelessWidget {
  const FeedbackDetailScreen({super.key, required this.record});

  final FeedbackRecord record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(record.type.label),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (record.type == FeedbackType.complaint) ...[
                      StatusBadge(status: record.status),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      record.type.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  record.message,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.text,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 16),
                InfoRow(
                  icon: record.category.icon,
                  label: 'Category',
                  text: record.category.label,
                ),
                const SizedBox(height: 14),
                InfoRow(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Reference',
                  text: record.reference,
                ),
                const SizedBox(height: 14),
                InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Submitted',
                  text: formatDateTime(record.createdAt),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
