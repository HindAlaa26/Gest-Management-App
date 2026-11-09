import 'dart:convert';

/// The token inside the text of a keycard QR code.
/// Accepts the token itself, a link with ?token=..., or JSON like {"token":"..."}.
String? qrTokenFrom(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return null;

  if (text.startsWith('{')) {
    try {
      final json = jsonDecode(text);
      final token = json is Map ? json['token'] : null;
      if (token is String && token.trim().isNotEmpty) return token.trim();
    } catch (_) {
      return null;
    }
    return null;
  }

  final fromLink = Uri.tryParse(text)?.queryParameters['token'];
  if (fromLink != null && fromLink.isNotEmpty) return fromLink;

  return text;
}
