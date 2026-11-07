enum LoyaltyTier {
  silver(0, 'Silver'),
  gold(1000, 'Gold'),
  platinum(5000, 'Platinum');

  const LoyaltyTier(this.minPoints, this.label);

  final int minPoints;
  final String label;

  LoyaltyTier? get next {
    final index = LoyaltyTier.values.indexOf(this);
    if (index + 1 >= LoyaltyTier.values.length) return null;
    return LoyaltyTier.values[index + 1];
  }
}

enum LoyaltyEntryType { earn, redeem, expire, adjust, other }

class LoyaltyEntry {
  const LoyaltyEntry({
    required this.id,
    required this.type,
    required this.points,
    required this.reason,
    required this.source,
    required this.date,
  });

  final String id;
  final LoyaltyEntryType type;

  final int points;
  final String reason;

  final String source;
  final DateTime date;
}

class LoyaltyAccount {
  const LoyaltyAccount({
    this.entries = const [],
    this.balance = 0,
    this.tierPoints = 0,
    this.serverTierName,
    this.nextTierName,
    this.nextTierThreshold,
    this.expiryMonths,
    this.fromServer = false,
  });

  final List<LoyaltyEntry> entries;

  final int balance;

  final int tierPoints;

  final String? serverTierName;

   final String? nextTierName;
  final int? nextTierThreshold;

   final int? expiryMonths;

   final bool fromServer;

  LoyaltyTier get tier {
    final name = serverTierName?.trim().toLowerCase();
    for (final candidate in LoyaltyTier.values) {
      if (candidate.label.toLowerCase() == name) return candidate;
    }
    if (name != null && name.isNotEmpty) return LoyaltyTier.silver;
    var result = LoyaltyTier.silver;
    for (final candidate in LoyaltyTier.values) {
      if (tierPoints >= candidate.minPoints) result = candidate;
    }
    return result;
  }

  String get tierLabel {
    final name = serverTierName?.trim() ?? '';
    return name.isEmpty ? tier.label : name;
  }

  LoyaltyTier? get nextTier => tier.next;

  String? get nextTierLabel => fromServer ? nextTierName : nextTier?.label;

  int? get nextTierPoints => fromServer ? nextTierThreshold : nextTier?.minPoints;

  bool get hasNextTier => nextTierLabel != null && nextTierPoints != null;

  int get pointsToNext {
    final target = nextTierPoints;
    if (!hasNextTier || target == null) return 0;
    final missing = target - tierPoints;
    return missing < 0 ? 0 : missing;
  }

  double get progress {
    final target = nextTierPoints;
    if (!hasNextTier || target == null || target <= 0) return 1;
    return (tierPoints / target).clamp(0.0, 1.0).toDouble();
  }
}
