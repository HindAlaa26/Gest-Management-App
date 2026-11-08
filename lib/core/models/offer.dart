enum OfferType { discount, roomUpgrade, bonusPoints, freeItem, other }

enum OfferStatus { available, used, expired }

class Offer {
  const Offer({
    required this.id,
    required this.title,
    required this.type,
    required this.validUntil,
    required this.code,
    this.description = '',
    this.opened = false,
    this.redeemedAt,
    this.expiredByServer = false,
  });

  final String id;
  final String title;
  final OfferType type;
  final DateTime validUntil;

  final String code;

  final String description;

  final bool opened;

  final DateTime? redeemedAt;

  final bool expiredByServer;

  OfferStatus get status {
    if (redeemedAt != null) return OfferStatus.used;
    if (expiredByServer || DateTime.now().isAfter(validUntil)) {
      return OfferStatus.expired;
    }
    return OfferStatus.available;
  }

  bool get isAvailable => status == OfferStatus.available;

  bool get isNew => isAvailable && !opened;
}
