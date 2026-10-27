import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/offer.dart';
import 'package:gest_managment_app/core/utils/helpers.dart';

extension OfferTypeLabels on OfferType {
  String get label {
    switch (this) {
      case OfferType.discount:
        return 'Discount';
      case OfferType.roomUpgrade:
        return 'Room upgrade';
      case OfferType.bonusPoints:
        return 'Bonus points';
      case OfferType.freeItem:
        return 'Free item';
    }
  }

  IconData get icon {
    switch (this) {
      case OfferType.discount:
        return Icons.percent;
      case OfferType.roomUpgrade:
        return Icons.king_bed_outlined;
      case OfferType.bonusPoints:
        return Icons.workspace_premium_outlined;
      case OfferType.freeItem:
        return Icons.card_giftcard_outlined;
    }
  }
}

String validUntilText(Offer offer) {
  return 'Valid until ${formatDay(offer.validUntil)}';
}

String offerStatusText(Offer offer) {
  switch (offer.status) {
    case OfferStatus.available:
      return validUntilText(offer);
    case OfferStatus.used:
      return 'Used on ${formatDay(offer.redeemedAt ?? offer.validUntil)}';
    case OfferStatus.expired:
      return 'Expired on ${formatDay(offer.validUntil)}';
  }
}
