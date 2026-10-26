import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/loyalty.dart';
import 'package:gest_managment_app/core/theme/theme.dart';

String formatPoints(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return value < 0 ? '-$buffer' : buffer.toString();
}

String formatSignedPoints(int value) {
  return value > 0 ? '+${formatPoints(value)}' : formatPoints(value);
}

class LoyaltyPalette {
  const LoyaltyPalette({
    required this.gradient,
    required this.border,
    required this.text,
    required this.subtext,
    required this.label,
    required this.accent,
    required this.bar,
    required this.track,
    required this.chipBackground,
    required this.chipForeground,
    required this.iconBackground,
    required this.iconForeground,
    required this.divider,
  });

  final List<Color> gradient;
  final Color border;
  final Color text;
  final Color subtext;
  final Color label;
  final Color accent;
  final Color bar;
  final Color track;
  final Color chipBackground;
  final Color chipForeground;
  final Color iconBackground;
  final Color iconForeground;
  final Color divider;
}

extension LoyaltyTierStyle on LoyaltyTier {
  LoyaltyPalette get palette {
    switch (this) {
      case LoyaltyTier.silver:
        return LoyaltyPalette(
          gradient: const [AppColors.card, AppColors.silverSoft],
          border: AppColors.silver,
          text: AppColors.navy,
          subtext: AppColors.silverDeep,
          label: AppColors.silverDeep,
          accent: AppColors.teal,
          bar: AppColors.silver,
          track: AppColors.silver.withValues(alpha: 0.25),
          chipBackground: AppColors.silverDeep,
          chipForeground: AppColors.card,
          iconBackground: AppColors.card,
          iconForeground: AppColors.silverDeep,
          divider: AppColors.silver.withValues(alpha: 0.5),
        );
      case LoyaltyTier.gold:
        return LoyaltyPalette(
          gradient: const [AppColors.card, AppColors.goldLight],
          border: AppColors.gold,
          text: AppColors.navy,
          subtext: AppColors.muted,
          label: AppColors.goldDeep,
          accent: AppColors.teal,
          bar: AppColors.gold,
          track: AppColors.gold.withValues(alpha: 0.25),
          chipBackground: AppColors.goldLight,
          chipForeground: AppColors.goldDeep,
          iconBackground: AppColors.goldLight,
          iconForeground: AppColors.goldDeep,
          divider: AppColors.gold.withValues(alpha: 0.5),
        );
      case LoyaltyTier.platinum:
        return LoyaltyPalette(
          gradient: const [AppColors.navySurface, AppColors.navyDeep],
          border: AppColors.gold,
          text: AppColors.card,
          subtext: AppColors.card.withValues(alpha: 0.75),
          label: AppColors.gold,
          accent: AppColors.gold,
          bar: AppColors.gold,
          track: AppColors.card.withValues(alpha: 0.2),
          chipBackground: AppColors.gold,
          chipForeground: AppColors.navyDeep,
          iconBackground: AppColors.gold.withValues(alpha: 0.18),
          iconForeground: AppColors.gold,
          divider: AppColors.gold.withValues(alpha: 0.4),
        );
    }
  }
}

extension LoyaltyEntryTypeStyle on LoyaltyEntryType {
  IconData get icon {
    switch (this) {
      case LoyaltyEntryType.earn:
        return Icons.add;
      case LoyaltyEntryType.redeem:
        return Icons.card_giftcard_outlined;
      case LoyaltyEntryType.expire:
        return Icons.hourglass_bottom_outlined;
      case LoyaltyEntryType.adjust:
        return Icons.edit_outlined;
    }
  }

  Color get iconBackground {
    switch (this) {
      case LoyaltyEntryType.earn:
        return AppColors.tealSoft;
      case LoyaltyEntryType.redeem:
      case LoyaltyEntryType.adjust:
        return AppColors.goldLight;
      case LoyaltyEntryType.expire:
        return AppColors.softGrey;
    }
  }

  Color get iconColor {
    switch (this) {
      case LoyaltyEntryType.earn:
        return AppColors.teal;
      case LoyaltyEntryType.redeem:
      case LoyaltyEntryType.adjust:
        return AppColors.goldDeep;
      case LoyaltyEntryType.expire:
        return AppColors.muted;
    }
  }
}
