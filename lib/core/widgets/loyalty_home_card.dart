import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gest_managment_app/core/models/loyalty.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/utils/loyalty_labels.dart';
import 'package:gest_managment_app/core/widgets/icon_circle.dart';
import 'package:gest_managment_app/core/widgets/loyalty_card_surface.dart';
import 'package:gest_managment_app/core/widgets/loyalty_progress_bar.dart';
import 'package:gest_managment_app/core/widgets/loyalty_tier_chip.dart';
import 'package:gest_managment_app/features/loyalty/loyalty_history_screen.dart';

class LoyaltyHomeCard extends StatefulWidget {
  const LoyaltyHomeCard({super.key});

  @override
  State<LoyaltyHomeCard> createState() => _LoyaltyHomeCardState();
}

class _LoyaltyHomeCardState extends State<LoyaltyHomeCard> {
  LoyaltyAccount? account;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await ApiService().getLoyalty();
      if (!mounted) return;
      setState(() {
        account = result;
      });
    } catch (_) {
      
    }
  }

  void openHistory(LoyaltyAccount current) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoyaltyHistoryScreen(account: current),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = account;
    if (current == null) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final palette = current.tier.palette;
    final next = current.nextTier;
    final caption = next == null
        ? "You've reached our top tier"
        : '${formatPoints(current.pointsToNext)} points to ${next.label}';

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: LoyaltyCardSurface(
        tier: current.tier,
        onTap: () => openHistory(current),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconCircle(
                  icon: Icons.workspace_premium_outlined,
                  background: palette.iconBackground,
                  color: palette.iconForeground,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        'My Loyalty',
                        style: textTheme.titleMedium?.copyWith(
                          color: palette.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      LoyaltyTierChip(current.tier),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: palette.accent),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  formatPoints(current.balance),
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: palette.text,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'POINTS',
                  style: textTheme.labelSmall?.copyWith(
                    color: palette.subtext,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (next != null) ...[
              const SizedBox(height: 12),
              LoyaltyProgressBar(
                progress: current.progress,
                color: palette.bar,
                trackColor: palette.track,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    caption,
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.subtext,
                    ),
                  ),
                ),
                Text(
                  'View history',
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: palette.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
