import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/survey.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/survey_center.dart';
import 'package:gest_managment_app/core/widgets/empty_state_card.dart';
import 'package:gest_managment_app/core/widgets/error_retry_card.dart';
import 'package:gest_managment_app/core/widgets/loading_view.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';
import 'package:gest_managment_app/core/widgets/survey_card.dart';
import 'package:gest_managment_app/features/surveys/survey_answer_screen.dart';
import 'package:gest_managment_app/features/surveys/survey_answers_screen.dart';

class SurveysScreen extends StatefulWidget {
  const SurveysScreen({super.key, this.openSurveyId});

  final String? openSurveyId;

  @override
  State<SurveysScreen> createState() => _SurveysScreenState();
}

class _SurveysScreenState extends State<SurveysScreen> {
  bool loading = true;
  String? error;
  List<Survey> surveys = const [];
  bool deepLinkHandled = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (!mounted) return;

    setState(() {
      if (surveys.isEmpty) loading = true;
      error = null;
    });

    try {
      final result = await ApiService().getSurveys();
      if (!mounted) return;
      setState(() {
        surveys = result;
        loading = false;
      });
      SurveyCenter.refresh();
      openLinkedSurvey(result);
    } catch (loadError) {
      if (!mounted) return;
      setState(() {
        error = 'Could not load your surveys. Please try again.';
        loading = false;
      });
    }
  }

  void openLinkedSurvey(List<Survey> list) {
    final id = widget.openSurveyId;
    if (id == null || deepLinkHandled) return;
    deepLinkHandled = true;

    for (final survey in list) {
      if (survey.id == id && survey.status == SurveyStatus.waiting) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) openAnswer(survey);
        });
        return;
      }
    }
  }

  Future<void> openAnswer(Survey survey) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SurveyAnswerScreen(survey: survey)),
    );
    if (mounted) await load();
  }

  void openAnswers(Survey survey) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SurveyAnswersScreen(survey: survey)),
    );
  }

  Widget buildBody() {
    if (loading) {
      return const LoadingView();
    }
    if (error != null) {
      return ErrorRetryCard(message: error!, onRetry: load);
    }
    if (surveys.isEmpty) {
      return const EmptyStateCard('No surveys yet');
    }

    final waiting =
        surveys.where((s) => s.status == SurveyStatus.waiting).toList();
    final answered =
        surveys.where((s) => s.status == SurveyStatus.answered).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('WAITING FOR YOUR ANSWER'),
        const SizedBox(height: 12),
        if (waiting.isEmpty)
          const EmptyStateCard('No surveys waiting for you')
        else
          for (final survey in waiting) ...[
            SurveyCard(survey: survey, onAnswer: () => openAnswer(survey)),
            const SizedBox(height: 12),
          ],
        if (answered.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SectionLabel('ANSWERED'),
          const SizedBox(height: 12),
          for (final survey in answered) ...[
            SurveyCard(survey: survey, onView: () => openAnswers(survey)),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(title: const Text('Surveys')),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.teal,
          onRefresh: load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [buildBody()],
          ),
        ),
      ),
    );
  }
}
