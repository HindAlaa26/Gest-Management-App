import 'package:flutter_test/flutter_test.dart';

import 'package:gest_managment_app/models/event_item.dart';
import 'package:gest_managment_app/models/guest_stay.dart';
import 'package:gest_managment_app/utils/helpers.dart';

void main() {
  group('event helper logic', () {
    test('formats a complete date string and identifies the same calendar day', () {
      final date = DateTime.now();
      final weekDays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final months = [
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

      expect(formatFullDate(date), '${weekDays[date.weekday - 1]}, ${date.day} ${months[date.month]}');
      expect(dayTitle(date), 'Today, ${formatDay(date)}');
      expect(isSameDay(date, DateTime(date.year, date.month, date.day, 18, 30)), isTrue);
      expect(isSameDay(date, DateTime(date.year, date.month, date.day + 1)), isFalse);
    });

    test('filters events to the guest stay window and keeps them sorted', () {
      final today = DateTime.now();
      final stay = GuestStay(
        guestName: 'Test Guest',
        roomNumber: '412',
        checkout: today.add(const Duration(days: 2)),
      );

      final allEvents = [
        EventItem(
          id: 'past',
          title: 'Past',
          date: today.add(const Duration(days: -1)),
          startTime: '09:00',
          endTime: '10:00',
          place: 'Lobby',
          type: EventType.event,
          description: 'Old event',
        ),
        EventItem(
          id: 'today',
          title: 'Today',
          date: today,
          startTime: '18:00',
          endTime: '19:00',
          place: 'Terrace',
          type: EventType.party,
          description: 'Current event',
        ),
        EventItem(
          id: 'tomorrow',
          title: 'Tomorrow',
          date: today.add(const Duration(days: 1)),
          startTime: '08:00',
          endTime: '09:00',
          place: 'Pool',
          type: EventType.event,
          description: 'Later event',
        ),
        EventItem(
          id: 'after-checkout',
          title: 'After checkout',
          date: today.add(const Duration(days: 3)),
          startTime: '12:00',
          endTime: '13:00',
          place: 'Garden',
          type: EventType.event,
          description: 'Not included',
        ),
      ];

      final filtered = eventsDuringStay(allEvents, stay);

      expect(filtered.map((event) => event.id).toList(), ['today', 'tomorrow']);
      expect(filtered[0].date.isBefore(filtered[1].date) || isSameDay(filtered[0].date, filtered[1].date), isTrue);
    });
  });
}
