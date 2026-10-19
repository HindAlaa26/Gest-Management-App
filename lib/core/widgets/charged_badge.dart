import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

class ChargedBadge extends StatelessWidget {
  const ChargedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'CHARGED TO ROOM',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.goldDeep,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
