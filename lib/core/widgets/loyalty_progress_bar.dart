import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

class LoyaltyProgressBar extends StatelessWidget {
  const LoyaltyProgressBar({
    super.key,
    required this.progress,
    required this.color,
    this.trackColor = AppColors.goldLight,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 8,
        color: color,
        backgroundColor: trackColor,
      ),
    );
  }
}
