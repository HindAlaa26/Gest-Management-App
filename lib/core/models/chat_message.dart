enum MessageDeliveryStatus { sending, sent, read, failed }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.fromGuest,
    required this.sentAt,
    required this.status,
  });

  final String id;
  final String text;

  final bool fromGuest;
  final DateTime sentAt;
  final MessageDeliveryStatus status;

  ChatMessage copyWith({MessageDeliveryStatus? status}) {
    return ChatMessage(
      id: id,
      text: text,
      fromGuest: fromGuest,
      sentAt: sentAt,
      status: status ?? this.status,
    );
  }
}
