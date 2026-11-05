import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/guest_stay.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/network/session_store.dart';

String _jwt(int expSeconds) {
  String part(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${part({'alg': 'none'})}.${part({'exp': expSeconds})}.sig';
}

void main() {
  test('saved session survives encode/decode', () {
    final saved = SavedSession(
      token: 'abc',
      stay: GuestStay(guestName: 'Sara', roomNumber: '204', checkout: DateTime.utc(2026, 12, 1)),
      propertyName: 'Hotel',
    );
    final back = SavedSession.decode(saved.encode())!;
    expect(back.token, 'abc');
    expect(back.stay.roomNumber, '204');
    expect(back.stay.checkout, DateTime.utc(2026, 12, 1));
    expect(back.propertyName, 'Hotel');
  });

  test('corrupt or empty data gives no session', () {
    expect(SavedSession.decode(null), isNull);
    expect(SavedSession.decode(''), isNull);
    expect(SavedSession.decode('{not json'), isNull);
  });

  test('token expiry is read from the exp claim', () {
    final now = DateTime.utc(2026, 11, 4);
    final future = now.add(const Duration(days: 1)).millisecondsSinceEpoch ~/ 1000;
    final past = now.subtract(const Duration(minutes: 1)).millisecondsSinceEpoch ~/ 1000;
    expect(Session.isExpiredJwt(_jwt(future), now: now), isFalse);
    expect(Session.isExpiredJwt(_jwt(past), now: now), isTrue);
    expect(Session.isExpiredJwt('garbage', now: now), isTrue);
  });
}
