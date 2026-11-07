import 'package:flutter/foundation.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/network/api_client.dart';

/// Names of request statuses and urgencies, loaded once from the backend.
class RequestLookups {
  static final Map<String, String> _statuses = {};
  static final Map<String, String> _urgencyLabels = {};
  static final List<RequestUrgency> _urgencies = [];
  static Future<void>? _loading;

  /// Readable name of a status, by its lower-case backend name (e.g. "inprogress").
  static String? status(String key) => _statuses[key];

  /// Every urgency the guest can pick, in backend order.
  /// Normal / Urgent / Emergency until the list is loaded.
  static List<RequestUrgency> get urgencies => _urgencies.isEmpty
      ? RequestUrgency.defaults
      : List<RequestUrgency>.unmodifiable(_urgencies);

  static String urgencyLabel(RequestUrgency urgency) =>
      _urgencyLabels[urgency.key] ?? humanize(urgency.name);

  /// Safe to call often: loads once, and tries again later if it failed.
  static Future<void> ensureLoaded() async {
    if (_statuses.isNotEmpty && _urgencies.isNotEmpty) return;
    final running = _loading ??= _load();
    await running;
    _loading = null;
  }

  static Future<void> _load() async {
    for (final name in await _names('/api/lookups/request-statuses')) {
      _statuses[name.toLowerCase()] = humanize(name);
    }

    final urgencyNames = await _names('/api/lookups/request-urgencies');
    if (urgencyNames.isNotEmpty) {
      _urgencies
        ..clear()
        ..addAll(urgencyNames.map(RequestUrgency.new));
      for (final name in urgencyNames) {
        _urgencyLabels[name.toLowerCase()] = humanize(name);
      }
    }
  }

  /// Backend names in backend order. Empty if the call fails.
  static Future<List<String>> _names(String path) async {
    try {
      final json = await ApiClient.get(path);
      final list = (json['data'] as List?) ?? const [];
      return [
        for (final item in list)
          if (item is Map<String, dynamic> &&
              item['name'] is String &&
              (item['name'] as String).isNotEmpty)
            item['name'] as String,
      ];
    } catch (error) {
      debugPrint('Could not load $path: $error');
      return const [];
    }
  }

  /// "InProgress" -> "In progress".
  static String humanize(String name) {
    final spaced = name.replaceAllMapped(
      RegExp(r'(?<=[a-z])(?=[A-Z])'),
      (_) => ' ',
    );
    if (spaced.isEmpty) return spaced;
    return spaced[0].toUpperCase() + spaced.substring(1).toLowerCase();
  }
}
