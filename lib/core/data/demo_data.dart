import 'package:gest_managment_app/core/models/case_status.dart';
import 'package:gest_managment_app/core/models/event_item.dart';
import 'package:gest_managment_app/core/models/feedback_item.dart';
import 'package:gest_managment_app/core/models/feedback_record.dart';
import 'package:gest_managment_app/core/models/guest_request.dart';
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

const List<CatalogueItem> demoCatalogue = [
  CatalogueItem(
    id: 'wat-1',
    vendorType: VendorType.water,
    nameEn: 'Bottled water 0.5L',
    nameAr: 'مياه معبأة ٠٫٥ لتر',
    price: 0,
    chargeable: false,
  ),
  CatalogueItem(
    id: 'wat-2',
    vendorType: VendorType.water,
    nameEn: 'Sparkling water',
    nameAr: 'مياه غازية',
    price: 20,
    chargeable: true,
  ),
  CatalogueItem(
    id: 'drk-1',
    vendorType: VendorType.drinks,
    nameEn: 'Soft drink',
    nameAr: 'مشروب غازي',
    price: 30,
    chargeable: true,
  ),
  CatalogueItem(
    id: 'drk-2',
    vendorType: VendorType.drinks,
    nameEn: 'Tea',
    nameAr: 'شاي',
    price: 0,
    chargeable: false,
  ),
  CatalogueItem(
    id: 'cln-1',
    vendorType: VendorType.cleaning,
    nameEn: 'Extra towels',
    nameAr: 'مناشف إضافية',
    price: 0,
    chargeable: false,
  ),
  CatalogueItem(
    id: 'cln-2',
    vendorType: VendorType.cleaning,
    nameEn: 'Room cleaning now',
    nameAr: 'تنظيف الغرفة الآن',
    price: 0,
    chargeable: false,
  ),
  CatalogueItem(
    id: 'mnt-1',
    vendorType: VendorType.maintenance,
    nameEn: 'AC not cooling',
    nameAr: 'التكييف لا يبرّد',
    price: 0,
    chargeable: false,
  ),
  CatalogueItem(
    id: 'oth-1',
    vendorType: VendorType.other,
    nameEn: 'Iron',
    nameAr: 'مكواة',
    price: 0,
    chargeable: false,
  ),
];

CatalogueItem _demoItem(String id) =>
    demoCatalogue.firstWhere((item) => item.id == id);

final Map<String, List<GuestRequest>> demoRequestsByRoom = {
  '305': [
    GuestRequest(
      reference: 'REQ-1045',
      vendorType: VendorType.water,
      lines: [
        RequestLine(item: _demoItem('wat-1'), qty: 2),
        RequestLine(item: _demoItem('wat-2'), qty: 1),
      ],
      urgency: RequestUrgency.urgent,
      note: '',
      createdAt: _now.subtract(const Duration(minutes: 20)),
      status: RequestStatus.newRequest,
    ),
    GuestRequest(
      reference: 'REQ-1044',
      vendorType: VendorType.cleaning,
      lines: [RequestLine(item: _demoItem('cln-1'), qty: 2)],
      urgency: RequestUrgency.normal,
      note: 'Please knock softly.',
      createdAt: _now.subtract(const Duration(minutes: 50)),
      status: RequestStatus.assigned,
      history: [
        RequestStatusEntry(
          status: RequestStatus.newRequest,
          at: _now.subtract(const Duration(minutes: 50)),
        ),
        RequestStatusEntry(
          status: RequestStatus.assigned,
          at: _now.subtract(const Duration(minutes: 40)),
        ),
      ],
    ),
    GuestRequest(
      reference: 'REQ-1043',
      vendorType: VendorType.maintenance,
      lines: [RequestLine(item: _demoItem('mnt-1'), qty: 1)],
      urgency: RequestUrgency.normal,
      note: '',
      createdAt: _now.subtract(const Duration(hours: 2)),
      status: RequestStatus.inProgress,
      history: [
        RequestStatusEntry(
          status: RequestStatus.newRequest,
          at: _now.subtract(const Duration(hours: 2)),
        ),
        RequestStatusEntry(
          status: RequestStatus.assigned,
          at: _now.subtract(const Duration(hours: 1, minutes: 50)),
        ),
        RequestStatusEntry(
          status: RequestStatus.inProgress,
          at: _now.subtract(const Duration(hours: 1, minutes: 30)),
        ),
      ],
    ),
    GuestRequest(
      reference: 'REQ-1042',
      vendorType: VendorType.drinks,
      lines: [
        RequestLine(item: _demoItem('drk-2'), qty: 1),
        RequestLine(item: _demoItem('drk-1'), qty: 1),
      ],
      urgency: RequestUrgency.normal,
      note: '',
      createdAt: _now.subtract(const Duration(hours: 5)),
      status: RequestStatus.done,
      history: [
        RequestStatusEntry(
          status: RequestStatus.newRequest,
          at: _now.subtract(const Duration(hours: 5)),
        ),
        RequestStatusEntry(
          status: RequestStatus.assigned,
          at: _now.subtract(const Duration(hours: 4, minutes: 50)),
        ),
        RequestStatusEntry(
          status: RequestStatus.inProgress,
          at: _now.subtract(const Duration(hours: 4, minutes: 40)),
        ),
        RequestStatusEntry(
          status: RequestStatus.done,
          at: _now.subtract(const Duration(hours: 4, minutes: 15)),
        ),
      ],
    ),
    GuestRequest(
      reference: 'REQ-1040',
      vendorType: VendorType.drinks,
      lines: [RequestLine(item: _demoItem('drk-2'), qty: 1)],
      urgency: RequestUrgency.normal,
      note: '',
      createdAt: _now.subtract(const Duration(hours: 26)),
      status: RequestStatus.cancelled,
      cancelReason: 'Changed my mind',
      history: [
        RequestStatusEntry(
          status: RequestStatus.newRequest,
          at: _now.subtract(const Duration(hours: 26)),
        ),
        RequestStatusEntry(
          status: RequestStatus.cancelled,
          at: _now.subtract(const Duration(hours: 25, minutes: 50)),
        ),
      ],
    ),
  ],
};

const String demoHotelName = 'Grand Palm Hotel';
