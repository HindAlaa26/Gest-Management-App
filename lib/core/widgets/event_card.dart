import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gest_managment_app/core/models/event_item.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/helpers.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';
import 'package:gest_managment_app/core/widgets/type_chip.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.showDescription = false,
    this.showDate = false,
  });

  final EventItem event;
  final VoidCallback? onTap;
  final bool showDescription;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final timeText = showDate
        ? '${formatDay(event.date)} · ${event.startTime} – ${event.endTime}'
        : '${event.startTime} – ${event.endTime}';

    return RoyalCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TypeChip(type: event.type),
            ],
          ),
          if (showDescription) ...[
            const SizedBox(height: 10),
            Text(
              event.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(color: AppColors.gold),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(

                child: Row(
                  children: [
                    const SizedBox(width: 8),
             
             
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.gold, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.place,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                                 const Icon(Icons.access_time, color: AppColors.gold, size: 18),

             const SizedBox(width: 12),
                   Expanded(
                    
                      child: Text(
                        timeText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
