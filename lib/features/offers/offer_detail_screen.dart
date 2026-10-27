import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/offer.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/offer_labels.dart';
import 'package:gest_managment_app/core/widgets/icon_circle.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';
import 'package:gest_managment_app/features/offers/offer_code_sheet.dart';

class OfferDetailScreen extends StatefulWidget {
  const OfferDetailScreen({super.key, required this.offer});

  final Offer offer;

  @override
  State<OfferDetailScreen> createState() => _OfferDetailScreenState();
}

class _OfferDetailScreenState extends State<OfferDetailScreen> {
  bool using = false;
  String? error;

  @override
  void initState() {
    super.initState();
    markOpened();
  }

  Future<void> markOpened() async {
    try {
      await ApiService().markOfferOpened(widget.offer.id);
    } catch (_) {
     
    }
  }

  Future<void> useOffer() async {
    if (using) return;

    setState(() {
      using = true;
      error = null;
    });

    try {
      final code = await ApiService().useOffer(widget.offer.id);
      if (!mounted) return;
      setState(() {
        using = false;
      });
      await showOfferCodeSheet(context, offer: widget.offer, code: code);
    } on OfferNotAvailableException {
      if (!mounted) return;
      setState(() {
        using = false;
        error = 'This offer is no longer available.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        using = false;
        error = 'Could not get your code. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final offer = widget.offer;
    final available = offer.isAvailable;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(title: const Text('Offer')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            RoyalCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconCircle(
                        icon: offer.type.icon,
                        size: 52,
                        iconSize: 26,
                        background:
                            available ? AppColors.goldLight : AppColors.softGrey,
                        color: available
                            ? AppColors.goldDeep
                            : AppColors.muted,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          offer.type.label.toUpperCase(),
                          style: textTheme.labelLarge?.copyWith(
                            color: available
                                ? AppColors.goldDeep
                                : AppColors.muted,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    offer.title,
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.event_outlined,
                        size: 16,
                        color: AppColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          offerStatusText(offer),
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    offer.description,
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.text,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (available) ...[
              const SizedBox(height: 24),
              const SectionLabel('How to use'),
              const SizedBox(height: 8),
              Text(
                'Tap Use offer and show the code to our staff. Each offer can be used once.',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              LoadingButton(
                label: 'Use offer',
                loading: using,
                onPressed: useOffer,
                trailingIcon: Icons.qr_code_2_outlined,
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
