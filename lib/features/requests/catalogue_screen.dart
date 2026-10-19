import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/widgets/charged_badge.dart';
import 'package:gest_managment_app/core/widgets/empty_state_card.dart';
import 'package:gest_managment_app/core/widgets/error_retry_card.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';
import 'package:gest_managment_app/core/widgets/loading_view.dart';
import 'package:gest_managment_app/core/widgets/quantity_stepper.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';
import 'package:gest_managment_app/features/requests/review_request_screen.dart';

class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key, required this.vendorType});

  final VendorType vendorType;

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  List<CatalogueItem> items = const [];
  final Map<String, int> quantities = {};
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await ApiService().getCatalogue(widget.vendorType);
      if (!mounted) return;
      setState(() {
        items = result;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Could not load items. Please try again.';
        loading = false;
      });
    }
  }

  List<RequestLine> get selectedLines => [
    for (final item in items)
      if ((quantities[item.id] ?? 0) > 0)
        RequestLine(item: item, qty: quantities[item.id]!),
  ];

  void setQty(CatalogueItem item, int value) {
    setState(() {
      if (value <= 0) {
        quantities.remove(item.id);
      } else {
        quantities[item.id] = value;
      }
    });
  }

  void openReview(List<RequestLine> lines) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReviewRequestScreen(vendorType: widget.vendorType, lines: lines),
      ),
    );
  }

  Widget buildBody() {
    if (loading) {
      return const LoadingView();
    }
    if (error != null) {
      return ErrorRetryCard(message: error!, onRetry: loadItems);
    }
    if (items.isEmpty) {
      return const EmptyStateCard('No items available right now');
    }

    final room = Session.currentStay?.roomNumber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Available amenities'),
        const SizedBox(height: 6),
        Text(
          room == null
              ? 'Selected items will be brought to your room.'
              : 'Selected items will be brought to Room $room.',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 14),
        for (final item in items) ...[
          _ItemCard(
            item: item,
            qty: quantities[item.id] ?? 0,
            onChanged: (value) => setQty(item, value),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget buildBottomBar(List<RequestLine> lines) {
    final count = lines.fold<int>(0, (sum, line) => sum + line.qty);
    final chargedLines = lines.where((line) => line.lineTotal > 0).length;
    final freeLines = lines.length - chargedLines;
    final canContinue = count > 0;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      canContinue
                          ? '$count ${count == 1 ? 'item' : 'items'} · ${formatPrice(requestTotal(lines))}'
                          : 'No items selected',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (canContinue)
                      Text(
                        '$freeLines free · $chargedLines charged',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 160,
                child: LoadingButton(
                  label: 'Continue',
                  trailingIcon: Icons.arrow_forward,
                  onPressed: canContinue ? () => openReview(lines) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lines = selectedLines;
    final showBar = !loading && error == null && items.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(widget.vendorType.label)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [buildBody()],
        ),
      ),
      bottomNavigationBar: showBar ? buildBottomBar(lines) : null,
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
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
