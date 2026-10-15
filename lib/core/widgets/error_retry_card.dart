import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';

class ErrorRetryCard extends StatelessWidget {
  const ErrorRetryCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RoyalCard(
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }
}
