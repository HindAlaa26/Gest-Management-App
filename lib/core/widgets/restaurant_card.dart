import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gest_managment_app/core/models/restaurant.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/helpers.dart';
import 'package:gest_managment_app/core/widgets/gold_divider.dart';
import 'package:gest_managment_app/core/widgets/meal_row.dart';
import 'package:gest_managment_app/core/widgets/open_today_badge.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.compact = false,
  });

  final Restaurant restaurant;
  final bool compact;

  bool get isOpenToday {
    final today = DateTime.now().weekday;
    final hasOpenMeal = !restaurant.breakfast.isClosed ||
        !restaurant.lunch.isClosed ||
        !restaurant.dinner.isClosed;
    return restaurant.openWeekdays.contains(today) && hasOpenMeal;
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: AppColors.ivory,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant,
                color: AppColors.gold,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    restaurant.openDays,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            OpenTodayBadge(hours: todayHours(restaurant)),
          ],
        ),
      );
    }

    return RoyalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ),
              if (isOpenToday) const OpenTodayBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            restaurant.openDays,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 14),
          const GoldDivider(width: 180),
          const SizedBox(height: 16),
          MealRow(
            mealName: 'Breakfast',
            hours: restaurant.breakfast,
            icon: Icons.wb_twilight_outlined,
          ),
          const SizedBox(height: 10),
          MealRow(
            mealName: 'Lunch',
            hours: restaurant.lunch,
            icon: Icons.wb_sunny_outlined,
          ),
          const SizedBox(height: 10),
          MealRow(
            mealName: 'Dinner',
            hours: restaurant.dinner,
            icon: Icons.nights_stay_outlined,
          ),
        ],
      ),
    );
  }
}
