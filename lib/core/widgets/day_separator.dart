import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

class DaySeparator extends StatelessWidget {
  const DaySeparator({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.goldDeep,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
