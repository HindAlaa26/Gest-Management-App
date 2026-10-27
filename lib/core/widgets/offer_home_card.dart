import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/offer_center.dart';
import 'package:gest_managment_app/core/widgets/icon_circle.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';
import 'package:gest_managment_app/features/offers/offers_screen.dart';

class OfferHomeCard extends StatefulWidget {
  const OfferHomeCard({super.key});

  @override
  State<OfferHomeCard> createState() => _OfferHomeCardState();
}

class _OfferHomeCardState extends State<OfferHomeCard> {
  @override
  void initState() {
    super.initState();
    OfferCenter.refresh();
  }

  Future<void> openOffers() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OffersScreen()),
    );
    OfferCenter.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<({int available, int fresh})>(
      valueListenable: OfferCenter.counts,
      builder: (context, counts, _) {
        if (counts.fresh == 0) return const SizedBox.shrink();

        final textTheme = Theme.of(context).textTheme;
        final title = counts.fresh == 1
            ? 'You have 1 new offer'
            : 'You have ${counts.fresh} new offers';

        return Padding(
          padding: const EdgeInsets.only(top: 18),
          child: RoyalCard(
            onTap: openOffers,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const IconCircle(icon: Icons.local_offer_outlined),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Exclusive for you',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View offers',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.teal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: AppColors.teal,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
