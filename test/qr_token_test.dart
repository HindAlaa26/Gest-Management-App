import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/utils/qr_token.dart';

void main() {
  group('qrTokenFrom', () {
    test('a plain token is used as it is', () {
      expect(qrTokenFrom('  abc.def-123  '), 'abc.def-123');
    });

    test('a link with a token parameter gives the token', () {
      expect(qrTokenFrom('https://example.com/open?token=abc123'), 'abc123');
    });

    test('JSON with a token gives the token', () {
      expect(qrTokenFrom('{"token":"abc123"}'), 'abc123');
    });

    test('empty or unreadable text gives nothing', () {
      expect(qrTokenFrom('   '), isNull);
      expect(qrTokenFrom('{"x":1}'), isNull);
    });
  });
}
