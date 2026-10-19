import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

class NoFeedbackView extends StatelessWidget {
  const NoFeedbackView({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tealSoft.withValues(alpha: 0.4),
                  ),
                ),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tealSoft,
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.card,
                    border: Border.all(color: AppColors.gold, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.rate_review_outlined,
                    color: AppColors.gold,
                    size: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'No feedback yet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tell us about your stay or let us know if something needs attention.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add feedback or complaint'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
