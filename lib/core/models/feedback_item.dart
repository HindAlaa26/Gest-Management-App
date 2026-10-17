enum FeedbackType { feedback, complaint }

enum FeedbackCategory { room, food, staff, other }

class FeedbackItem {
  const FeedbackItem({
    required this.type,
    required this.category,
    required this.message,
  });

  final FeedbackType type;
  final FeedbackCategory category;
  final String message;

  FeedbackItem copyWith({
    FeedbackType? type,
    FeedbackCategory? category,
    String? message,
  }) {
    return FeedbackItem(
      type: type ?? this.type,
      category: category ?? this.category,
      message: message ?? this.message,
    );
  }
}
