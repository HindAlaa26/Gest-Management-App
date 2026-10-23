import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

class NpsScale extends StatelessWidget {
  const NpsScale({super.key, required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(11, (index) {
            final selected = value == index;
            return Semantics(
              button: true,
              selected: selected,
              label: '$index',
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.teal : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.teal
                          : AppColors.gold.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '$index',
                    style: textTheme.bodyLarge?.copyWith(
                      color: selected ? Colors.white : AppColors.navy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Not at all likely',
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
            Text(
              'Extremely likely',
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
      ],
    );
  }
}
