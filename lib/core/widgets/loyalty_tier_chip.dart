import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/loyalty.dart';
import 'package:gest_managment_app/core/utils/loyalty_labels.dart';

class LoyaltyTierChip extends StatelessWidget {
  const LoyaltyTierChip(this.tier, {super.key});

  final LoyaltyTier tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: tier.chipBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tier.chipForeground.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        tier.label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: tier.chipForeground,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
