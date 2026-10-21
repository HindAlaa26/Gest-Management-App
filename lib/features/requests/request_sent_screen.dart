import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/app_nav.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/widgets/gold_divider.dart';
import 'package:gest_managment_app/core/widgets/info_row.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';
import 'package:gest_managment_app/core/widgets/reference_badge.dart';
import 'package:gest_managment_app/core/widgets/request_line_row.dart';
import 'package:gest_managment_app/core/widgets/request_status_badge.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';
import 'package:gest_managment_app/core/widgets/success_mark.dart';
import 'package:gest_managment_app/features/requests/request_details_screen.dart';

class RequestSentScreen extends StatefulWidget {
  const RequestSentScreen({super.key, required this.request});

  final GuestRequest request;

  @override
  State<RequestSentScreen> createState() => _RequestSentScreenState();
}

class _RequestSentScreenState extends State<RequestSentScreen> {
  bool leaving = false;

  void trackRequest(BuildContext context) {
    if (leaving) return;
    leaving = true;

    final navigator = Navigator.of(context);
    final reference = widget.request.reference;
    navigator.popUntil((route) => route.isFirst);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNav.tab.value = 3;
      navigator.push(
        MaterialPageRoute(
          builder: (_) => RequestDetailsScreen(reference: reference),
        ),
      );
    });
  }

  void goToTab(BuildContext context, int tab) {
    if (leaving) return;
    leaving = true;

    Navigator.of(context).popUntil((route) => route.isFirst);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNav.tab.value = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final count = request.lines.fold<int>(0, (sum, line) => sum + line.qty);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: SuccessMark(size: 88)),
              const SizedBox(height: 20),
              Text(
                'Request sent',
                textAlign: TextAlign.center,
                style: textTheme.headlineLarge?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your request has been received.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              const GoldDivider(width: 220),
              const SizedBox(height: 20),
              Center(child: ReferenceBadge(reference: request.reference)),
              const SizedBox(height: 14),
              Center(child: RequestStatusBadge(status: request.status)),
              const SizedBox(height: 24),
              RoyalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SectionLabel('Items requested'),
                        Text(
                          '$count ${count == 1 ? 'item' : 'items'}',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (final line in request.lines) ...[
                      RequestLineRow(line: line),
                      const SizedBox(height: 12),
                    ],
                    const Divider(height: 20),
                    InfoRow(
                      icon: Icons.bolt_outlined,
                      label: 'Urgency',
                      text: request.urgency.label,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              LoadingButton(
                label: 'Track my request',
                onPressed: () => trackRequest(context),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => goToTab(context, 0),
                child: const Text('Back to home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
