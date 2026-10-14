import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/event_item.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import '../widgets/gold_divider.dart';
import '../widgets/info_row.dart';
import '../widgets/royal_card.dart';
import '../widgets/section_label.dart';
import '../widgets/type_chip.dart';

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({
    super.key,
    required this.event,
  });

  final EventItem event;

  @override
  Widget build(BuildContext context) {
    final label = event.type == EventType.party ? 'Party' : 'Event';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoyalCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TypeChip(type: event.type),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SectionLabel(label),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event.title,
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const GoldDivider(width: 180),
                    const SizedBox(height: 18),
                    Text(
                      event.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.navy,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              RoyalCard(
                child: Column(
                  children: [
                    InfoRow(
                      icon: Icons.calendar_today_outlined,
                      text: formatFullDate(event.date),
                      label: 'Date',
                    ),
                    const SizedBox(height: 18),
                    InfoRow(
                      icon: Icons.access_time,
                      text: '${event.startTime} – ${event.endTime}',
                      label: 'Time',
                    ),
                    const SizedBox(height: 18),
                    InfoRow(
                      icon: Icons.location_on_outlined,
                      text: event.place,
                      label: 'Place',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
