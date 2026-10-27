import 'package:flutter/foundation.dart';

import 'package:gest_managment_app/core/network/api_service.dart';

class OfferCenter {
  static final ValueNotifier<({int available, int fresh})> counts =
      ValueNotifier<({int available, int fresh})>((available: 0, fresh: 0));

  static Future<void> refresh() async {
    try {
      final list = await ApiService().getOffers();
      counts.value = (
        available: list.where((o) => o.isAvailable).length,
        fresh: list.where((o) => o.isNew).length,
      );
    } catch (error, stackTrace) {
      debugPrint('Could not refresh offer counts: $error\n$stackTrace');
    }
  }
}
