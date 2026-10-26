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
  const LoyaltyAccount({this.entries = const []});

  final List<LoyaltyEntry> entries;

  int get balance => entries.fold<int>(0, (sum, entry) => sum + entry.points);

  int get tierPoints {
    final since = DateTime.now().subtract(const Duration(days: 365));
    return entries
        .where((entry) => entry.points > 0 && entry.date.isAfter(since))
        .fold<int>(0, (sum, entry) => sum + entry.points);
  }

  LoyaltyTier get tier {
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
