import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/case_status.dart';
import 'package:gest_managment_app/core/models/feedback_item.dart';
import 'package:gest_managment_app/core/models/feedback_record.dart';
import 'package:gest_managment_app/core/theme/theme.dart';

class FeedbackSummaryStrip extends StatelessWidget {
  const FeedbackSummaryStrip({super.key, required this.records});

  final List<FeedbackRecord> records;

  @override
  Widget build(BuildContext context) {
    final total = records.length;
    final inProgress = records.where((record) {
      return record.type == FeedbackType.complaint &&
          (record.status == CaseStatus.open ||
              record.status == CaseStatus.inProgress ||
              record.status == CaseStatus.waitingOnGuest);
    }).length;
    final done = records.where((record) {
      return record.type == FeedbackType.complaint &&
          (record.status == CaseStatus.resolved ||
              record.status == CaseStatus.closed);
    }).length;

    final items = [
      _SummaryBox(label: 'Total', value: total.toString()),
      _SummaryBox(label: 'In progress', value: inProgress.toString()),
      _SummaryBox(label: 'Done', value: done.toString()),
    ];

    return Row(
      children: List.generate(items.length, (index) {
        final item = items[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index < items.length - 1 ? 10 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                      letterSpacing: 0.7,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SummaryBox {
  const _SummaryBox({required this.label, required this.value});

  final String label;
  final String value;
}
