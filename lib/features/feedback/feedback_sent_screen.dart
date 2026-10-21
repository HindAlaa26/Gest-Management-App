import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/app_nav.dart';
import 'package:gest_managment_app/core/widgets/gold_divider.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';
import 'package:gest_managment_app/core/widgets/reference_badge.dart';
import 'package:gest_managment_app/core/widgets/success_mark.dart';
import 'package:gest_managment_app/features/feedback/feedback_screen.dart';

class FeedbackSentScreen extends StatefulWidget {
  const FeedbackSentScreen({super.key, required this.reference});

  final String reference;

  @override
  State<FeedbackSentScreen> createState() => _FeedbackSentScreenState();
}

class _FeedbackSentScreenState extends State<FeedbackSentScreen> {
  bool leaving = false;

  
  void goHome(BuildContext context) {
    if (leaving) return;
    leaving = true;

   
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNav.tab.value = 0; 
    });
  }

 
  void goToFeedback(BuildContext context) {
    if (leaving) return;
    leaving = true;

    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNav.tab.value = 3;
      navigator.push(
        MaterialPageRoute(builder: (_) => const FeedbackScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SuccessMark(size: 96),
                const SizedBox(height: 24),
                Text(
                  'Sent',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Thank you, we received your message',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 26),
                const GoldDivider(width: 220),
                const SizedBox(height: 26),
                ReferenceBadge(reference: widget.reference),
                const SizedBox(height: 28),
                SizedBox(
                  width: 220,
                  child: LoadingButton(
                    label: 'Back to home',
                    onPressed: () => goHome(context),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 220,
                  child: OutlinedButton(
                    onPressed: () => goToFeedback(context),
                    child: const Text('View my feedback'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
