import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/widgets/delivery_room_card.dart';
import 'package:gest_managment_app/core/widgets/gold_divider.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';
import 'package:gest_managment_app/features/requests/catalogue_screen.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  void openCatalogue(BuildContext context, VendorType type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CatalogueScreen(vendorType: type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridTypes = VendorType.values
        .where((t) => t != VendorType.other)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const SectionLabel('What do you need?'),
            const SizedBox(height: 8),
            Text(
              'In-Room Services',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 6),
            Text(
              'Amenities and comforts delivered to your room.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            const GoldDivider(width: 220),
            const SizedBox(height: 14),
            const DeliveryRoomCard(),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                for (final type in gridTypes)
                  _ServiceTile(
                    type: type,
                    onTap: () => openCatalogue(context, type),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _ServiceTile(
              type: VendorType.other,
              wide: true,
              onTap: () => openCatalogue(context, VendorType.other),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                // TASK 22: open the "My requests" list here.
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('My requests is coming soon')),
                  );
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('My requests'),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.type,
    required this.onTap,
    this.wide = false,
  });

  final VendorType type;
  final VoidCallback onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final iconCircle = Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.tealSoft,
      ),
      child: Icon(type.icon, color: AppColors.teal, size: 24),
    );

    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          type.label,
          style: textTheme.bodyLarge?.copyWith(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          type.subtitle,
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ],
    );

    const chevron = Icon(Icons.chevron_right, color: AppColors.muted);

    return RoyalCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: wide
          ? Row(
              children: [
                iconCircle,
                const SizedBox(width: 12),
                Expanded(child: texts),
                chevron,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [iconCircle, chevron],
                ),
                texts,
              ],
            ),
    );
  }
}
