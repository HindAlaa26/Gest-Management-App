import 'package:flutter/material.dart';

import '../utils/theme.dart';
import 'royal_card.dart';

class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return RoyalCard(
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.navy,
          ),
        ),
      ),
    );
  }
}
