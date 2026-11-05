import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:gest_managment_app/core/models/guest_stay.dart';

class SavedSession {
  const SavedSession({
    required this.token,
    required this.stay,
    required this.propertyName,
  });

  final String token;
  final GuestStay stay;
  final String? propertyName;

  String encode() => jsonEncode({
        'token': token,
        'guestName': stay.guestName,
        'roomNumber': stay.roomNumber,
        'checkout': stay.checkout.toIso8601String(),
        'propertyName': propertyName,
      });

  static SavedSession? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return SavedSession(
        token: m['token'] as String,
        stay: GuestStay(
          guestName: m['guestName'] as String,
          roomNumber: m['roomNumber'] as String,
          checkout: DateTime.parse(m['checkout'] as String),
        ),
        propertyName: m['propertyName'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}


class SessionStore {
  static const _key = 'guest_session';
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  static Future<void> save({
    required String token,
    required GuestStay stay,
    String? propertyName,
  }) async {
    try {
      final value = SavedSession(token: token, stay: stay, propertyName: propertyName).encode();
      await _storage.write(key: _key, value: value);
    } catch (_) {}
  }

  static Future<SavedSession?> load() async {
    try {
      return SavedSession.decode(await _storage.read(key: _key));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {}
  }
}
