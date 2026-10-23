import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/survey.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/utils/survey_labels.dart';
import 'package:gest_managment_app/core/widgets/empty_state_card.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';
import 'package:gest_managment_app/core/widgets/star_rating.dart';

class SurveyAnswersScreen extends StatelessWidget {
  const SurveyAnswersScreen({super.key, required this.survey});

  final Survey survey;

  SurveyAnswer? answerFor(String questionId) {
    for (final answer in survey.answers) {
      if (answer.questionId == questionId) return answer;
    }
    return null;
  }

  Widget buildAnswer(BuildContext context, SurveyQuestion question) {
    final textTheme = Theme.of(context).textTheme;
    final answer = answerFor(question.id);

    switch (question.type) {
      case SurveyQuestionType.csat:
        final value = answer?.rating;
        if (value == null) {
          return Text(
            'No answer',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StarRating(value: value, size: 28),
            const SizedBox(height: 4),
            Text(
              csatLabel(value),
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.goldDeep,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      case SurveyQuestionType.nps:
        final value = answer?.rating;
        return Text(
          value == null ? 'No answer' : '$value / 10',
          style: textTheme.titleLarge?.copyWith(color: AppColors.teal),
        );
      case SurveyQuestionType.comment:
        final text = answer?.comment;
        return Text(
          text == null || text.isEmpty ? 'No comment' : text,
          style: textTheme.bodyLarge?.copyWith(
            color: text == null || text.isEmpty
                ? AppColors.muted
                : AppColors.text,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final answeredAt = survey.answeredAt;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(title: Text(survey.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              survey.contextLabel,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            if (answeredAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Answered ${formatRequestTime(answeredAt)}',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
            const SizedBox(height: 16),
            if (survey.answers.isEmpty)
              const EmptyStateCard('Your answers are not available')
            else
              for (final question in survey.questions) ...[
                RoyalCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.text,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      buildAnswer(context, question),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }
}
