import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

class UrgentTag extends StatelessWidget {
  const UrgentTag({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'URGENT',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.error,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
