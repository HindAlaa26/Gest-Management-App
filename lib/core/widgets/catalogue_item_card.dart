import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/widgets/charged_badge.dart';
import 'package:gest_managment_app/core/widgets/quantity_stepper.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';

class CatalogueItemCard extends StatelessWidget {
  const CatalogueItemCard({
    super.key,
    required this.item,
    required this.qty,
    required this.onChanged,
  });

  final CatalogueItem item;
  final int qty;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isFree = item.price <= 0;

    return RoyalCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.tealSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.vendorType.icon, color: AppColors.teal, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nameEn,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatPrice(item.price),
                  style: textTheme.bodySmall?.copyWith(
                    color: isFree ? AppColors.teal : AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.chargeable) ...[
                  const SizedBox(height: 6),
                  const ChargedBadge(),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          QuantityStepper(value: qty, onChanged: onChanged),
        ],
      ),
    );
  }
}
