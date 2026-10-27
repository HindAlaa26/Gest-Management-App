enum OfferType { discount, roomUpgrade, bonusPoints, freeItem }

enum OfferStatus { available, used, expired }

class Offer {
  const Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.validUntil,
    this.opened = false,
    this.redeemedAt,
  });

  final String id;
  final String title;
  final String description;
  final OfferType type;
  final DateTime validUntil;

  final bool opened;

  final DateTime? redeemedAt;

  OfferStatus get status {
    if (redeemedAt != null) return OfferStatus.used;
    if (DateTime.now().isAfter(validUntil)) return OfferStatus.expired;
    return OfferStatus.available;
  }

  bool get isAvailable => status == OfferStatus.available;

  bool get isNew => isAvailable && !opened;

  Offer copyOpened() {
    return Offer(
      id: id,
      title: title,
      description: description,
      type: type,
      validUntil: validUntil,
      opened: true,
      redeemedAt: redeemedAt,
    );
  }
}

class OfferNotFoundException implements Exception {}

class OfferNotAvailableException implements Exception {}
