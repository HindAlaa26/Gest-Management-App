import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/widgets/charged_badge.dart';


class RequestLineRow extends StatelessWidget {
  const RequestLineRow({super.key, required this.line});

  final RequestLine line;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.tealSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            line.item.vendorType.icon,
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
                line.item.nameEn,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Qty: ${line.qty}',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatPrice(line.lineTotal),
              style: textTheme.bodyMedium?.copyWith(
                color: line.lineTotal > 0 ? AppColors.navy : AppColors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (line.item.chargeable) ...[
              const SizedBox(height: 4),
              const ChargedBadge(),
            ],
          ],
        ),
      ],
    );
  }
}
