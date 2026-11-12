import 'package:flutter/foundation.dart';

import 'package:gest_managment_app/core/network/api_client.dart';
import 'package:gest_managment_app/core/utils/request_lookups.dart';

class LookupOption {
  const LookupOption(this.code, this.name);

  final String code;
  final String name;
}

class NamedLookup {
  NamedLookup(this.path, {this.defaults = const []});

  final String path;
  final List<LookupOption> defaults;

  List<LookupOption> _loaded = const [];
  Future<void>? _loading;

  List<LookupOption> get options => _loaded.isEmpty ? defaults : _loaded;

  String? nameOf(String code) {
    final wanted = code.trim().toLowerCase();
    for (final option in _loaded) {
      if (option.code.toLowerCase() == wanted) return option.name;
    }
    return null;
  }

  String label(String code) {
    final wanted = code.trim().toLowerCase();
    for (final option in options) {
      if (option.code.toLowerCase() == wanted) return option.name;
    }
    return RequestLookups.humanize(code.trim());
  }
 
  Future<void> ensureLoaded() async {
    if (_loaded.isNotEmpty) return;
    final running = _loading ??= _load();
    await running;
    _loading = null;
  }

  Future<void> _load() async {
    try {
      final json = await ApiClient.get(path);
      final list = (json['data'] as List?) ?? const [];
      final result = <LookupOption>[];
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        final code = item['code'];
        if (code is! String || code.isEmpty) continue;
        final nameEn = item['nameEn'];
        final name = nameEn is String && nameEn.trim().isNotEmpty
            ? nameEn.trim()
            : code;
        result.add(
          LookupOption(
            code,
            name.contains(' ') ? name : RequestLookups.humanize(name),
          ),
        );
      }
      _loaded = result;
    } catch (error) {
      debugPrint('Could not load $path: $error');
    }
  }
}

class Lookups {
  static final NamedLookup feedbackTypes = NamedLookup(
    '/api/lookups/feedback-types',
    defaults: const [
      LookupOption('Feedback', 'Feedback'),
      LookupOption('Complaint', 'Complaint'),
    ],
  );

  static final NamedLookup feedbackCategories = NamedLookup(
    '/api/lookups/feedback-categories',
    defaults: const [
      LookupOption('Room', 'Room'),
      LookupOption('Food', 'Food'),
      LookupOption('Staff', 'Staff'),
      LookupOption('Maintenance', 'Maintenance'),
      LookupOption('Housekeeping', 'Housekeeping'),
      LookupOption('Billing', 'Billing'),
      LookupOption('Other', 'Other'),
    ],
  );

  static final NamedLookup offerTypes = NamedLookup('/api/lookups/offer-types');
}
