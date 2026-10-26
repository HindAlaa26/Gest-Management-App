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

extension LoyaltyTierStyle on LoyaltyTier {
  Color get chipBackground {
    switch (this) {
      case LoyaltyTier.silver:
        return AppColors.silverSoft;
      case LoyaltyTier.gold:
        return AppColors.goldLight;
      case LoyaltyTier.platinum:
        return AppColors.navy;
    }
  }

  Color get chipForeground {
    switch (this) {
      case LoyaltyTier.silver:
        return AppColors.silverDeep;
      case LoyaltyTier.gold:
        return AppColors.goldDeep;
      case LoyaltyTier.platinum:
        return AppColors.gold;
    }
  }

  Color get barColor {
    switch (this) {
      case LoyaltyTier.silver:
        return AppColors.silver;
      case LoyaltyTier.gold:
      case LoyaltyTier.platinum:
        return AppColors.gold;
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
