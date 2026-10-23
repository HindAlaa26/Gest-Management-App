import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/survey.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/survey_center.dart';
import 'package:gest_managment_app/core/utils/survey_labels.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';
import 'package:gest_managment_app/core/widgets/nps_scale.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';
import 'package:gest_managment_app/core/widgets/star_rating.dart';
import 'package:gest_managment_app/features/surveys/survey_thanks_screen.dart';

class SurveyAnswerScreen extends StatefulWidget {
  const SurveyAnswerScreen({super.key, required this.survey});

  final Survey survey;

  @override
  State<SurveyAnswerScreen> createState() => _SurveyAnswerScreenState();
}

class _SurveyAnswerScreenState extends State<SurveyAnswerScreen> {
  int index = 0;
  bool submitting = false;
  String? error;
  final Map<String, int> ratings = {};
  final Map<String, TextEditingController> comments = {};

  List<SurveyQuestion> get questions => widget.survey.questions;
  SurveyQuestion get current => questions[index];
  bool get isLast => index == questions.length - 1;
  bool get canProceed =>
      !current.needsRating || ratings.containsKey(current.id);
  bool get hasProgress =>
      ratings.isNotEmpty ||
      comments.values.any((c) => c.text.trim().isNotEmpty);

  TextEditingController controllerFor(String id) {
    return comments.putIfAbsent(id, () => TextEditingController());
  }

  @override
  void dispose() {
    for (final controller in comments.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> leave() async {
    if (!hasProgress) {
      Navigator.of(context).pop();
      return;
    }

    final leaveIt = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave this survey?'),
        content: const Text('Your answers will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Stay'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (leaveIt == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void back() {
    FocusScope.of(context).unfocus();
    setState(() {
      if (index > 0) index--;
      error = null;
    });
  }

  void next() {
    FocusScope.of(context).unfocus();
    if (isLast) {
      submit();
      return;
    }
    setState(() {
      index++;
      error = null;
    });
  }

  Future<void> submit() async {
    if (submitting) return;

    final answers = <SurveyAnswer>[
      for (final question in questions)
        SurveyAnswer(
          questionId: question.id,
          rating: ratings[question.id],
          comment: question.type == SurveyQuestionType.comment &&
                  (comments[question.id]?.text.trim().isNotEmpty ?? false)
              ? comments[question.id]!.text.trim()
              : null,
        ),
    ];

    setState(() {
      submitting = true;
      error = null;
    });

    try {
      await ApiService().submitSurvey(widget.survey.id, answers);
      if (!mounted) return;
      SurveyCenter.refresh();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SurveyThanksScreen()),
      );
    } on SurveyAlreadyAnsweredException {
      if (!mounted) return;
      SurveyCenter.refresh();
      Navigator.of(context).pop();
    } catch (submitError) {
      if (!mounted) return;
      setState(() {
        submitting = false;
        error = 'Could not send your answers. Please try again.';
      });
    }
  }

  Widget buildInput(SurveyQuestion question) {
    final textTheme = Theme.of(context).textTheme;

    switch (question.type) {
      case SurveyQuestionType.csat:
        final value = ratings[question.id] ?? 0;
        return Column(
          children: [
            Center(
              child: StarRating(
                value: value,
                size: 40,
                onChanged: (v) => setState(() => ratings[question.id] = v),
              ),
            ),
            if (value > 0) ...[
              const SizedBox(height: 6),
              Text(
                csatLabel(value),
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.goldDeep,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  csatLabel(1),
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
                Text(
                  csatLabel(5),
                  style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ],
        );
      case SurveyQuestionType.nps:
        return NpsScale(
          value: ratings[question.id],
          onChanged: (v) => setState(() => ratings[question.id] = v),
        );
      case SurveyQuestionType.comment:
        return TextField(
          controller: controllerFor(question.id),
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(hintText: 'Your comment (optional)'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final question = current;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: leave,
          icon: const Icon(Icons.close),
          tooltip: 'Close',
        ),
        title: Text(widget.survey.title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              'Question ${index + 1} of ${questions.length}',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.goldDeep,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (index + 1) / questions.length,
                minHeight: 4,
                color: AppColors.teal,
                backgroundColor: AppColors.tealSoft,
              ),
            ),
            const SizedBox(height: 18),
            RoyalCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: textTheme.titleLarge?.copyWith(
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildInput(question),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (index > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: submitting ? null : back,
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: LoadingButton(
                    label: isLast ? 'Submit' : 'Next',
                    loading: submitting,
                    onPressed: canProceed ? next : null,
                  ),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
