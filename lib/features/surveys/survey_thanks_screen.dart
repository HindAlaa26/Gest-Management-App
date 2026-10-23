import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/app_nav.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';
import 'package:gest_managment_app/core/widgets/success_mark.dart';

class SurveyThanksScreen extends StatefulWidget {
  const SurveyThanksScreen({super.key});

  @override
  State<SurveyThanksScreen> createState() => _SurveyThanksScreenState();
}

class _SurveyThanksScreenState extends State<SurveyThanksScreen> {
  bool leaving = false;

  void goToSurveys() {
    if (leaving) return;
    leaving = true;
    Navigator.of(context).pop();
  }

  void goHome() {
    if (leaving) return;
    leaving = true;

    Navigator.of(context).popUntil((route) => route.isFirst);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNav.tab.value = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SuccessMark(),
                const SizedBox(height: 24),
                Text(
                  'Thank you',
                  style: textTheme.headlineMedium?.copyWith(
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your answers were sent to the hotel team.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 28),
                LoadingButton(
                  label: 'Back to surveys',
                  trailingIcon: Icons.arrow_forward,
                  onPressed: goToSurveys,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: goHome,
                  child: const Text('Back to home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
