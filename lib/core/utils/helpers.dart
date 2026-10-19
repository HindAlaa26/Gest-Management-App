import 'package:gest_managment_app/core/models/event_item.dart';
import 'package:gest_managment_app/core/models/guest_stay.dart';
import 'package:gest_managment_app/core/models/restaurant.dart';

const List<String> weekdayNames = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

const List<String> fullWeekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> monthNames = [
  '',
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const List<String> shortMonthNames = [
  '',
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

int minutesOf(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) {
    return 0;
  }

  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = int.tryParse(parts[1]) ?? 0;
  return (hour * 60) + minute;
}

String formatDay(DateTime d) {
  return '${d.day} ${shortMonthNames[d.month]}';
}

String formatFullDate(DateTime d) {
  return '${fullWeekdayNames[d.weekday - 1]}, ${d.day} ${monthNames[d.month]}';
}

String formatDateTime(DateTime d) {
  final hours = d.hour.toString().padLeft(2, '0');
  final minutes = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${shortMonthNames[d.month]}, $hours:$minutes';
}

String dayTitle(DateTime d) {
  final today = DateTime.now();
  final tomorrow = today.add(const Duration(days: 1));

  if (isSameDay(d, today)) {
    return 'Today, ${formatDay(d)}';
  }

  if (isSameDay(d, tomorrow)) {
    return 'Tomorrow, ${formatDay(d)}';
  }

  return '${weekdayNames[d.weekday - 1]}, ${formatDay(d)}';
}

String greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good morning';
  }
  if (hour < 18) {
    return 'Good afternoon';
  }
  return 'Good evening';
}

bool sameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

bool isSameDay(DateTime a, DateTime b) {
  return sameDay(a, b);
}

String timeFromMinutes(int totalMinutes) {
  final hour = totalMinutes ~/ 60;
  final minute = totalMinutes % 60;
  final hourText = hour.toString().padLeft(2, '0');
  final minuteText = minute.toString().padLeft(2, '0');
  return '$hourText:$minuteText';
}

EventItem? nextEvent(List<EventItem> events) {
  if (events.isEmpty) {
    return null;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final nowMinutes = (now.hour * 60) + now.minute;

  final upcoming = <EventItem>[];

  for (final event in events) {
    final eventDay = DateTime(event.date.year, event.date.month, event.date.day);
    final isToday = sameDay(event.date, today);

    if (eventDay.isAfter(today)) {
      upcoming.add(event);
      continue;
    }

    if (isToday && minutesOf(event.endTime) > nowMinutes) {
      upcoming.add(event);
    }
  }

  if (upcoming.isEmpty) {
    return null;
  }

  upcoming.sort((a, b) {
    final aDay = DateTime(a.date.year, a.date.month, a.date.day);
    final bDay = DateTime(b.date.year, b.date.month, b.date.day);
    final dateCompare = aDay.compareTo(bDay);
    if (dateCompare != 0) {
      return dateCompare;
    }
    return minutesOf(a.startTime).compareTo(minutesOf(b.startTime));
  });

  return upcoming.first;
}

List<EventItem> eventsDuringStay(List<EventItem> all, GuestStay stay) {
  final stayStart = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  final stayEnd = DateTime(
    stay.checkout.year,
    stay.checkout.month,
    stay.checkout.day,
  );

  final filtered = all.where((event) {
    final eventDate = DateTime(event.date.year, event.date.month, event.date.day);
    return !eventDate.isBefore(stayStart) && !eventDate.isAfter(stayEnd);
  }).toList();

  filtered.sort((a, b) {
    final aDate = DateTime(a.date.year, a.date.month, a.date.day);
    final bDate = DateTime(b.date.year, b.date.month, b.date.day);
    final dateCompare = aDate.compareTo(bDate);
    if (dateCompare != 0) {
      return dateCompare;
    }
    return minutesOf(a.startTime).compareTo(minutesOf(b.startTime));
  });

  return filtered;
}

List<Restaurant> openToday(List<Restaurant> all) {
  final today = DateTime.now().weekday;
  final result = <Restaurant>[];

  for (final restaurant in all) {
    final open = restaurant.openWeekdays.contains(today);
    final hasOpenMeal = !restaurant.breakfast.isClosed ||
        !restaurant.lunch.isClosed ||
        !restaurant.dinner.isClosed;

    if (open && hasOpenMeal) {
      result.add(restaurant);
    }
  }

  return result;
}

String todayHours(Restaurant r) {
  final meals = [r.breakfast, r.lunch, r.dinner]
      .where((meal) => !meal.isClosed)
      .toList();

  if (meals.isEmpty) {
    return 'Closed';
  }

  final opens = meals
      .map((meal) => minutesOf(meal.open!))
      .toList();
  final closes = meals
      .map((meal) => minutesOf(meal.close!))
      .toList();

  final earliest = opens.reduce((a, b) => a < b ? a : b);
  final latest = closes.reduce((a, b) => a > b ? a : b);

  return '${timeFromMinutes(earliest)} – ${timeFromMinutes(latest)}';
}
