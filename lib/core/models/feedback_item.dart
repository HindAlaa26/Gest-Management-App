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
}
