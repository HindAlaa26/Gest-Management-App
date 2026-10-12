// Simple event information for the guest calendar.
enum EventType { event, party }

class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.place,
    required this.type,
    required this.description,
  });

  final String id;
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String place;
  final EventType type;
  final String description;
}
