import 'package:gest_managment_app/core/models/case_status.dart';
import 'package:gest_managment_app/core/models/event_item.dart';
import 'package:gest_managment_app/core/models/feedback_item.dart';
import 'package:gest_managment_app/core/models/feedback_record.dart';
import 'package:gest_managment_app/core/models/guest_stay.dart';
import 'package:gest_managment_app/core/models/restaurant.dart';

final DateTime _now = DateTime.now();

final List<GuestStay> demoStays = [
  GuestStay(
    guestName: 'Mr. Smith',
    roomNumber: '305',
    checkout: _now.add(const Duration(days: 4)),
  ),
  GuestStay(
    guestName: 'Mrs. Johnson',
    roomNumber: '412',
    checkout: _now.add(const Duration(days: 2)),
  ),
  GuestStay(
    guestName: 'Mr. Ahmed',
    roomNumber: '218',
    checkout: _now.add(const Duration(days: 6)),
  ),
];

final Map<String, GuestStay> demoStayByLastName = {
  'smith': demoStays[0],
  'johnson': demoStays[1],
  'ahmed': demoStays[2],
};

final List<EventItem> demoEvents = [
  EventItem(
    id: 'evt-1',
    title: 'Welcome Cocktail',
    date: _now,
    startTime: '18:00',
    endTime: '19:00',
    place: 'Lobby',
    type: EventType.party,
    description: 'A relaxed welcome gathering with signature drinks and light bites.',
  ),
  EventItem(
    id: 'evt-2',
    title: 'Yoga by the Pool',
    date: _now.add(const Duration(days: 1)),
    startTime: '08:00',
    endTime: '09:00',
    place: 'Pool deck',
    type: EventType.event,
    description: 'Start the morning with a calm guided yoga session under the sun.',
  ),
  EventItem(
    id: 'evt-3',
    title: 'Cooking Workshop',
    date: _now.add(const Duration(days: 1)),
    startTime: '11:00',
    endTime: '12:30',
    place: 'Main kitchen',
    type: EventType.event,
    description: 'Learn simple local recipes with our chef and enjoy tastings.',
  ),
  EventItem(
    id: 'evt-4',
    title: 'Live Music Night',
    date: _now.add(const Duration(days: 1)),
    startTime: '20:00',
    endTime: '23:00',
    place: 'Terrace',
    type: EventType.party,
    description: 'Enjoy an evening of live jazz and a warm terrace atmosphere.',
  ),
  EventItem(
    id: 'evt-5',
    title: 'Sunset Tea',
    date: _now.add(const Duration(days: 2)),
    startTime: '17:00',
    endTime: '18:00',
    place: 'Garden',
    type: EventType.event,
    description: 'Take a quiet break with fresh tea and light pastries at sunset.',
  ),
  EventItem(
    id: 'evt-6',
    title: 'Gala Dinner',
    date: _now.add(const Duration(days: 2)),
    startTime: '20:00',
    endTime: '23:30',
    place: 'Grand Ballroom',
    type: EventType.party,
    description: 'A refined evening dinner with music, elegant service, and a grand setting.',
  ),
];

final List<Restaurant> demoRestaurants = [
  Restaurant(
    name: 'Lotus',
    openDays: 'Open every day',
    openWeekdays: const [1, 2, 3, 4, 5, 6, 7],
    breakfast: const MealHours(open: '07:00', close: '10:30'),
    lunch: const MealHours(open: '12:30', close: '15:00'),
    dinner: const MealHours(open: '19:00', close: '22:30'),
  ),
  Restaurant(
    name: 'Sea Breeze',
    openDays: 'Open every day',
    openWeekdays: const [1, 2, 3, 4, 5, 6, 7],
    breakfast: const MealHours(),
    lunch: const MealHours(open: '13:00', close: '16:00'),
    dinner: const MealHours(open: '18:30', close: '23:00'),
  ),
  Restaurant(
    name: 'Garden Grill',
    openDays: 'Thursday to Sunday',
    openWeekdays: const [4, 5, 6, 7],
    breakfast: const MealHours(),
    lunch: const MealHours(),
    dinner: const MealHours(open: '19:00', close: '23:00'),
  ),
];

final Map<String, List<FeedbackRecord>> demoFeedbackByRoom = {
  '305': [
    FeedbackRecord(
      reference: 'GMS-1038',
      type: FeedbackType.complaint,
      category: FeedbackCategory.room,
      message: 'The air conditioner in my room is not cooling properly.',
      createdAt: _now.subtract(const Duration(days: 2)),
      status: CaseStatus.inProgress,
    ),
    FeedbackRecord(
      reference: 'GMS-1031',
      type: FeedbackType.complaint,
      category: FeedbackCategory.food,
      message: 'My breakfast order arrived cold.',
      createdAt: _now.subtract(const Duration(days: 4)),
      status: CaseStatus.resolved,
    ),
    FeedbackRecord(
      reference: 'GMS-1027',
      type: FeedbackType.feedback,
      category: FeedbackCategory.staff,
      message: 'The front desk team was very helpful during check-in.',
      createdAt: _now.subtract(const Duration(days: 5)),
      status: CaseStatus.closed,
    ),
  ],
  '412': const <FeedbackRecord>[],
  '218': const <FeedbackRecord>[],
};

const String demoHotelName = 'Grand Palm Hotel';
