import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/offer.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/offer_labels.dart';
import 'package:gest_managment_app/core/widgets/icon_circle.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';

class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer, required this.onTap});

  final Offer offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final past = !offer.isAvailable;

    return RoyalCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconCircle(
            icon: offer.type.icon,
            size: 44,
            iconSize: 22,
            background: past ? AppColors.softGrey : AppColors.goldLight,
            color: past ? AppColors.muted : AppColors.goldDeep,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      offer.type.label.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: past ? AppColors.muted : AppColors.goldDeep,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                    if (offer.isNew)
                      const _OfferChip(
                        text: 'New',
                        background: AppColors.tealSoft,
                        foreground: AppColors.teal,
                      ),
                    if (offer.status == OfferStatus.used)
                      const _OfferChip(
                        text: 'Used',
                        background: AppColors.tealSoft,
                        foreground: AppColors.success,
                      ),
                    if (offer.status == OfferStatus.expired)
                      const _OfferChip(
                        text: 'Expired',
                        background: AppColors.softGrey,
                        foreground: AppColors.muted,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  offer.title,
                  style: textTheme.titleMedium?.copyWith(
                    color: past ? AppColors.muted : AppColors.navy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.event_outlined,
                      size: 14,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        offerStatusText(offer),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _OfferChip extends StatelessWidget {
  const _OfferChip({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
