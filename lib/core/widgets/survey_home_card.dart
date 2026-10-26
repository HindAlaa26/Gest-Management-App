import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/survey_center.dart';
import 'package:gest_managment_app/core/widgets/icon_circle.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';
import 'package:gest_managment_app/features/surveys/surveys_screen.dart';

 class SurveyHomeCard extends StatefulWidget {
  const SurveyHomeCard({super.key});

  @override
  State<SurveyHomeCard> createState() => _SurveyHomeCardState();
}

class _SurveyHomeCardState extends State<SurveyHomeCard> {
  @override
  void initState() {
    super.initState();
    SurveyCenter.refresh();
  }

  Future<void> openSurveys() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SurveysScreen()),
    );
    SurveyCenter.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SurveyCenter.waitingCount,
      builder: (context, count, _) {
        if (count == 0) return const SizedBox.shrink();

        final textTheme = Theme.of(context).textTheme;
        final text = count == 1
            ? '1 survey is waiting for you'
            : '$count surveys are waiting for you';

        return Padding(
          padding: const EdgeInsets.only(top: 18),
          child: RoyalCard(
            onTap: openSurveys,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const IconCircle(icon: Icons.poll_outlined),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "We'd like your opinion",
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        text,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Answer now',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.teal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: AppColors.teal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
