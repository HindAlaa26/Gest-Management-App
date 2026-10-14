import 'package:flutter/material.dart';

import '../utils/theme.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.label,
  });

  final IconData icon;
  final String text;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: AppColors.ivory,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.gold, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null)
                Text(
                  label!.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.muted,
                    letterSpacing: 1.1,
                  ),
                ),
              if (label != null) const SizedBox(height: 4),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
