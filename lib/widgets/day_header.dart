import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/theme.dart';

class DayHeader extends StatelessWidget {
  const DayHeader({
    super.key,
    required this.title,
    required this.count,
  });

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ),
            Text(
              '$count item${count == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 1,
          color: AppColors.gold.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
