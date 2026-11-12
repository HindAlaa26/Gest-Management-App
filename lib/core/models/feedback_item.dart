
class FeedbackCodes {
  static const String complaint = 'Complaint';
}

class FeedbackItem {
  const FeedbackItem({
    required this.typeCode,
    required this.categoryCode,
    required this.message,
  });

  /// Backend code of the type (e.g. "Feedback", "Complaint").
  final String typeCode;

  /// Backend code of the category (e.g. "Room").
  final String categoryCode;
  final String message;

  FeedbackItem copyWith({
    String? typeCode,
    String? categoryCode,
    String? message,
  }) {
    return FeedbackItem(
      typeCode: typeCode ?? this.typeCode,
      categoryCode: categoryCode ?? this.categoryCode,
      message: message ?? this.message,
    );
  }
}
