class MealHours {
  const MealHours({this.open, this.close});

  final String? open;
  final String? close;

  bool get isClosed => open == null || close == null;

  String get label => isClosed ? 'Closed' : '$open – $close';
}

class Restaurant {
  const Restaurant({
    required this.name,
    required this.openDays,
    required this.openWeekdays,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  final String name;
  final String openDays;
  final List<int> openWeekdays;
  final MealHours breakfast;
  final MealHours lunch;
  final MealHours dinner;
}
