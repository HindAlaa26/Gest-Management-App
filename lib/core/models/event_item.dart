enum EventType { event, party, other }

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
    this.typeName = '',
  });

  final String id;
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String place;
  final EventType type;
  final String description;

  final String typeName;

  String get typeLabel {
    switch (type) {
      case EventType.party:
        return 'Party';
      case EventType.event:
        return 'Event';
      case EventType.other:
        return typeName.isEmpty ? 'Event' : typeName;
    }
  }
}
