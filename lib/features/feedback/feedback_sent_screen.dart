import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/app_nav.dart';
import 'package:gest_managment_app/core/widgets/gold_divider.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';
import 'package:gest_managment_app/core/widgets/reference_badge.dart';
import 'package:gest_managment_app/core/widgets/success_mark.dart';

class FeedbackSentScreen extends StatelessWidget {
  const FeedbackSentScreen({super.key, required this.reference});

  final String reference;

  void _goHome(BuildContext context) {
    AppNav.tab.value = 0;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goHome(context);
        }
      },
      child: Scaffold(
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
                  ReferenceBadge(reference: reference),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 220,
                    child: LoadingButton(
                      label: 'Back to home',
                      onPressed: () => _goHome(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
