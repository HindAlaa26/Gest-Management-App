import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/restaurant.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/helpers.dart';

class MealRow extends StatelessWidget {
  const MealRow({
    super.key,
    required this.mealName,
    required this.hours,
    required this.icon,
  });

  final String mealName;
  final MealHours hours;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isClosed = hours.isClosed;
    final timeText =
        isClosed ? 'Closed' : '${time12(hours.open!)} – ${time12(hours.close!)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.ivory,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isClosed ? AppColors.muted : AppColors.gold,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mealName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isClosed ? AppColors.muted : AppColors.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            timeText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isClosed ? AppColors.muted : AppColors.navy,
              fontWeight: isClosed ? FontWeight.w500 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
