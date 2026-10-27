import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/utils/offer_center.dart';
import 'package:gest_managment_app/core/utils/survey_center.dart';
import 'package:gest_managment_app/core/widgets/gold_divider.dart';
import 'package:gest_managment_app/core/widgets/more_tile.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';
import 'package:gest_managment_app/features/feedback/feedback_screen.dart';
import 'package:gest_managment_app/features/messages/messages_screen.dart';
import 'package:gest_managment_app/features/offers/offers_screen.dart';
import 'package:gest_managment_app/features/requests/requests_screen.dart';
import 'package:gest_managment_app/features/surveys/surveys_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  void open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const SectionLabel('Services & support'),
            const SizedBox(height: 10),
            const GoldDivider(width: 220),
            const SizedBox(height: 18),
            MoreTile(
              icon: Icons.room_service_outlined,
              title: 'Requests',
              subtitle: 'Water, drinks, cleaning and maintenance',
              onTap: () => open(context, const RequestsScreen()),
            ),
            const SizedBox(height: 14),
            MoreTile(
              icon: Icons.chat_bubble_outline,
              title: 'Messages',
              subtitle: 'Chat with the hotel team',
              onTap: () => open(context, const MessagesScreen()),
            ),
            const SizedBox(height: 14),
            MoreTile(
              icon: Icons.rate_review_outlined,
              title: 'Feedback',
              subtitle: 'Share feedback or make a complaint',
              onTap: () => open(context, const FeedbackScreen()),
            ),
            const SizedBox(height: 14),
            ValueListenableBuilder<int>(
              valueListenable: SurveyCenter.waitingCount,
              builder: (context, count, _) => MoreTile(
                icon: Icons.poll_outlined,
                title: 'Surveys',
                subtitle: 'Tell us how we did',
                badgeCount: count,
                onTap: () => open(context, const SurveysScreen()),
              ),
            ),
            const SizedBox(height: 14),
            ValueListenableBuilder<({int available, int fresh})>(
              valueListenable: OfferCenter.counts,
              builder: (context, counts, _) => MoreTile(
                icon: Icons.local_offer_outlined,
                title: 'Offers',
                subtitle: counts.available > 0
                    ? '${counts.available} available for you'
                    : 'Exclusive offers for you',
                badgeCount: counts.fresh,
                onTap: () => open(context, const OffersScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
