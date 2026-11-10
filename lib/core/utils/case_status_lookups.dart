import 'package:flutter/foundation.dart';

import 'package:gest_managment_app/core/network/api_client.dart';
import 'package:gest_managment_app/core/utils/request_lookups.dart';

class CaseStatusLookups {
  static final Map<String, String> _names = {};
  static Future<void>? _loading;

  static String label(String code) =>
      _names[code.toLowerCase()] ?? RequestLookups.humanize(code);

  static Future<void> ensureLoaded() async {
    if (_names.isNotEmpty) return;
    final running = _loading ??= _load();
    await running;
    _loading = null;
  }

  static Future<void> _load() async {
    try {
      final json = await ApiClient.get('/api/lookups/case-statuses');
      final list = (json['data'] as List?) ?? const [];
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        final code = item['code'];
        if (code is! String || code.isEmpty) continue;
        final name = item['nameEn'];
        _names[code.toLowerCase()] = RequestLookups.humanize(
          name is String && name.isNotEmpty ? name : code,
        );
      }
    } catch (error) {
      debugPrint('Could not load /api/lookups/case-statuses: $error');
    }
  }
}
