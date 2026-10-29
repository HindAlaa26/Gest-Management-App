import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/data_request.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/data_request_labels.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/widgets/icon_circle.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';

class DataRequestCard extends StatelessWidget {
  const DataRequestCard({super.key, required this.request, this.onCopyLink});

  final DataRequest request;

  final VoidCallback? onCopyLink;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDelete = request.type == DataRequestType.delete;

    return RoyalCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconCircle(
                icon: request.type.icon,
                size: 44,
                iconSize: 22,
                background: isDelete
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.goldLight,
                color: isDelete ? AppColors.error : AppColors.goldDeep,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.type.title,
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Requested ${formatRequestTime(request.requestedAt)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(request.status, expired: request.linkExpired),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dataRequestNote(request),
            style: textTheme.bodyMedium?.copyWith(color: AppColors.text),
          ),
          if (onCopyLink != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCopyLink,
                child: const Text('Copy download link'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status, {this.expired = false});

  final DataRequestStatus status;
  final bool expired;

  Color get background {
    switch (status) {
      case DataRequestStatus.pending:
        return AppColors.goldLight;
      case DataRequestStatus.inProgress:
        return AppColors.tealSoft;
      case DataRequestStatus.done:
        return AppColors.tealSoft;
      case DataRequestStatus.failed:
        return AppColors.error.withValues(alpha: 0.1);
    }
  }

  Color get foreground {
    switch (status) {
      case DataRequestStatus.pending:
        return AppColors.goldDeep;
      case DataRequestStatus.inProgress:
        return AppColors.teal;
      case DataRequestStatus.done:
        return AppColors.success;
      case DataRequestStatus.failed:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: expired ? AppColors.softGrey : background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        expired ? 'Expired' : status.label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: expired ? AppColors.muted : foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
