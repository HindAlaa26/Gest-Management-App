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

enum LoyaltyEntryType { earn, redeem, expire, adjust }

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
  });

  final List<LoyaltyEntry> entries;

  final int balance;

  final int tierPoints;

  final String? serverTierName;


  LoyaltyTier get tier {
    final name = serverTierName?.trim().toLowerCase();
    for (final candidate in LoyaltyTier.values) {
      if (candidate.label.toLowerCase() == name) return candidate;
    }
    var result = LoyaltyTier.silver;
    for (final candidate in LoyaltyTier.values) {
      if (tierPoints >= candidate.minPoints) result = candidate;
    }
    return result;
  }

  LoyaltyTier? get nextTier => tier.next;

  int get pointsToNext {
    final next = nextTier;
    if (next == null) return 0;
    return next.minPoints - tierPoints;
  }

  double get progress {
    final next = nextTier;
    if (next == null) return 1;
    final span = next.minPoints - tier.minPoints;
    return ((tierPoints - tier.minPoints) / span).clamp(0.0, 1.0).toDouble();
  }
}
