import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/widgets/request_status_badge.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';
import 'package:gest_managment_app/core/widgets/urgent_tag.dart';

class RequestSummaryCard extends StatelessWidget {
  const RequestSummaryCard({
    super.key,
    required this.request,
    required this.onTap,
  });

  final GuestRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cancelled = request.status == RequestStatus.cancelled;
    final summary = request.lines
        .map((line) => '${line.item.nameEn} ×${line.qty}')
        .join(', ');

    return RoyalCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.shortReference,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                    decoration: cancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (request.urgency == RequestUrgency.urgent) ...[
                const UrgentTag(),
                const SizedBox(width: 8),
              ],
              RequestStatusBadge(status: request.status),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.tealSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(request.vendorType.icon, color: AppColors.teal, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.navy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: AppColors.muted),
              const SizedBox(width: 6),
              Text(
                formatRequestTime(request.createdAt),
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ],
      ),
    );
  }
}
