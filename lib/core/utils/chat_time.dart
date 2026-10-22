String clock12(int hour24, int minute) {
  final period = hour24 >= 12 ? 'PM' : 'AM';
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minuteText = minute.toString().padLeft(2, '0');
  return '$hour12:$minuteText $period';
}

String formatClock(DateTime time) {
  return clock12(time.hour, time.minute);
}

String chatDayLabel(DateTime time) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(time.year, time.month, time.day);
  final daysAgo = today.difference(day).inDays;

  if (daysAgo == 0) return 'Today';
  if (daysAgo == 1) return 'Yesterday';
  return '${time.day} ${months[time.month - 1]}';
}
