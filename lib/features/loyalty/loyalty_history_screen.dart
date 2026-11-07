import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gest_managment_app/core/models/loyalty.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/helpers.dart';
import 'package:gest_managment_app/core/utils/loyalty_labels.dart';
import 'package:gest_managment_app/core/widgets/empty_state_card.dart';
import 'package:gest_managment_app/core/widgets/icon_circle.dart';
import 'package:gest_managment_app/core/widgets/loyalty_card_surface.dart';
import 'package:gest_managment_app/core/widgets/loyalty_progress_bar.dart';
import 'package:gest_managment_app/core/widgets/loyalty_tier_chip.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';

class LoyaltyHistoryScreen extends StatefulWidget {
  const LoyaltyHistoryScreen({super.key, required this.account});

  final LoyaltyAccount account;

  @override
  State<LoyaltyHistoryScreen> createState() => _LoyaltyHistoryScreenState();
}

class _LoyaltyHistoryScreenState extends State<LoyaltyHistoryScreen> {
  static const int pageSize = 20;

  late final List<LoyaltyEntry> entries = List<LoyaltyEntry>.of(
    widget.account.entries,
  );
  bool loadingMore = false;
  bool allLoaded = false;
  String? moreError;

  LoyaltyAccount get account => widget.account;

   bool get canLoadMore =>
      !allLoaded && entries.isNotEmpty && entries.length % pageSize == 0;

  Future<void> loadMore() async {
    if (loadingMore) return;

    setState(() {
      loadingMore = true;
      moreError = null;
    });

    try {
      final page = entries.length ~/ pageSize + 1;
      final result = await ApiService().getLoyaltyLedgerPage(
        page: page,
        pageSize: pageSize,
      );
      if (!mounted) return;
      setState(() {
        entries.addAll(result.entries);
        allLoaded =
            result.entries.length < pageSize || entries.length >= result.total;
        loadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        moreError = 'Could not load more activity. Please try again.';
        loadingMore = false;
      });
    }
  }

  Widget noteRow(
    BuildContext context,
    LoyaltyPalette palette,
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: palette.label),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: palette.subtext,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSummary(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final palette = account.tier.palette;
    final caption = !account.hasNextTier
        ? "You've reached our top tier"
        : '${formatPoints(account.pointsToNext)} points to ${account.nextTierLabel}';
    final months = account.expiryMonths;

    return LoyaltyCardSurface(
      tier: account.tier,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'AVAILABLE BALANCE',
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.label,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              LoyaltyTierChip(account.tier, name: account.tierLabel),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatPoints(account.balance),
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: palette.text,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'pts',
                style: textTheme.bodyMedium?.copyWith(color: palette.label),
              ),
            ],
          ),
          if (account.hasNextTier) ...[
            const SizedBox(height: 14),
            LoyaltyProgressBar(
              progress: account.progress,
              color: palette.bar,
              trackColor: palette.track,
            ),
          ],
          const SizedBox(height: 10),
          Text(
            caption,
            style: textTheme.bodySmall?.copyWith(color: palette.subtext),
          ),
          const SizedBox(height: 12),
          Divider(color: palette.divider),
          if (months != null)
            noteRow(
              context,
              palette,
              Icons.schedule,
              'Points expire $months months after they are earned',
            ),
          noteRow(
            context,
            palette,
            Icons.workspace_premium_outlined,
            'Your tier is based on your recent points',
          ),
        ],
      ),
    );
  }

  Widget buildEntry(BuildContext context, LoyaltyEntry entry) {
    final textTheme = Theme.of(context).textTheme;
    final Color pointsColor = entry.points > 0
        ? AppColors.success
        : entry.points < 0
            ? AppColors.error
            : AppColors.muted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RoyalCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            IconCircle(
              icon: entry.type.icon,
              size: 40,
              iconSize: 20,
              background: entry.type.iconBackground,
              color: entry.type.iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.reason,
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatDay(entry.date)} · ${entry.source}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatSignedPoints(entry.points),
              style: textTheme.titleMedium?.copyWith(
                color: pointsColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShowMore(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        if (moreError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              moreError!,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
          ),
        Center(
          child: loadingMore
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.teal,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: loadMore,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Show more',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.expand_more,
                        size: 18,
                        color: AppColors.teal,
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(title: const Text('My Loyalty')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            buildSummary(context),
            const SizedBox(height: 24),
            const SectionLabel('Activity history'),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              const EmptyStateCard(
                'No points yet. You earn points from your stays and chargeable requests.',
              )
            else ...[
              for (final entry in entries) buildEntry(context, entry),
              if (canLoadMore) buildShowMore(context),
            ],
          ],
        ),
      ),
    );
  }
}
