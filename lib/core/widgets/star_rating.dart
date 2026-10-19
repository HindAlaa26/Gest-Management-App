import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 36,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < value;
        return IconButton(
          onPressed: onChanged == null ? null : () => onChanged!(index + 1),
          icon: Icon(filled ? Icons.star_rounded : Icons.star_outline_rounded),
          iconSize: size,
          color: AppColors.gold,
          disabledColor: filled
              ? AppColors.gold
              : AppColors.gold.withValues(alpha: 0.4),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: size + 8, minHeight: size + 8),
        );
      }),
    );
  }
}
