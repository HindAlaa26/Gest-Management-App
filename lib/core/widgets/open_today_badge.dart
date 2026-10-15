import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

class OpenTodayBadge extends StatelessWidget {
  const OpenTodayBadge({super.key, this.hours});

  final String? hours;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'OPEN TODAY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        if (hours != null) ...[
          const SizedBox(height: 6),
          Text(
            hours!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
