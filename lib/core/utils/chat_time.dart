String formatClock(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
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
