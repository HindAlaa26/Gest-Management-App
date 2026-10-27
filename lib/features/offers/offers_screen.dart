import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/offer.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/offer_center.dart';
import 'package:gest_managment_app/core/widgets/empty_state_card.dart';
import 'package:gest_managment_app/core/widgets/error_retry_card.dart';
import 'package:gest_managment_app/core/widgets/loading_view.dart';
import 'package:gest_managment_app/core/widgets/offer_card.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';
import 'package:gest_managment_app/features/offers/offer_detail_screen.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key, this.openOfferId});

  final String? openOfferId;

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  bool loading = true;
  String? error;
  List<Offer> offers = const [];
  bool deepLinkHandled = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (!mounted) return;

    setState(() {
      if (offers.isEmpty) loading = true;
      error = null;
    });

    try {
      final result = await ApiService().getOffers();
      if (!mounted) return;
      setState(() {
        offers = result;
        loading = false;
      });
      OfferCenter.refresh();
      openLinkedOffer(result);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Could not load your offers. Please try again.';
        loading = false;
      });
    }
  }

  void openLinkedOffer(List<Offer> list) {
    final id = widget.openOfferId;
    if (id == null || deepLinkHandled) return;
    deepLinkHandled = true;

    for (final offer in list) {
      if (offer.id == id) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) openOffer(offer);
        });
        return;
      }
    }
  }

  Future<void> openOffer(Offer offer) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OfferDetailScreen(offer: offer)),
    );
    if (mounted) await load();
  }

  Widget buildBody() {
    if (loading) {
      return const LoadingView();
    }
    if (error != null) {
      return ErrorRetryCard(message: error!, onRetry: load);
    }
    if (offers.isEmpty) {
      return const EmptyStateCard(
        "No offers right now. We'll let you know when a new offer arrives for you.",
      );
    }

    final available = offers.where((o) => o.isAvailable).toList()
      ..sort((a, b) => a.validUntil.compareTo(b.validUntil));
    final past = offers.where((o) => !o.isAvailable).toList()
      ..sort((a, b) => b.validUntil.compareTo(a.validUntil));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('Available (${available.length})'),
        const SizedBox(height: 12),
        if (available.isEmpty)
          const EmptyStateCard('No offers available right now')
        else
          for (final offer in available) ...[
            OfferCard(offer: offer, onTap: () => openOffer(offer)),
            const SizedBox(height: 12),
          ],
        if (past.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SectionLabel('Past'),
          const SizedBox(height: 12),
          for (final offer in past) ...[
            OfferCard(offer: offer, onTap: () => openOffer(offer)),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(title: const Text('Offers')),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.teal,
          onRefresh: load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [buildBody()],
          ),
        ),
      ),
    );
  }
}
