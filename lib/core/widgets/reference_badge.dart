import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

class ReferenceBadge extends StatelessWidget {
  const ReferenceBadge({super.key, required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.tealSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'REFERENCE',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reference,
            style: GoogleFonts.robotoMono(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.navy,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
