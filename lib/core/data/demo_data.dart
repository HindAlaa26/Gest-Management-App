import 'package:gest_managment_app/core/models/app_notification.dart';
import 'package:gest_managment_app/core/models/case_status.dart';
import 'package:gest_managment_app/core/models/chat_message.dart';
import 'package:gest_managment_app/core/models/data_request.dart';
import 'package:gest_managment_app/core/models/event_item.dart';
import 'package:gest_managment_app/core/models/feedback_item.dart';
import 'package:gest_managment_app/core/models/feedback_record.dart';
import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/models/guest_stay.dart';
import 'package:gest_managment_app/core/models/loyalty.dart';
import 'package:gest_managment_app/core/models/offer.dart';
import 'package:gest_managment_app/core/models/restaurant.dart';
import 'package:gest_managment_app/core/models/survey.dart';

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

final Map<String, List<ChatMessage>> demoMessagesByRoom = {
  '305': [
    ChatMessage(
      id: 'msg-1',
      text: 'Hi, could I get extra pillows?',
      fromGuest: true,
      sentAt: _now.subtract(const Duration(minutes: 25)),
      status: MessageDeliveryStatus.read,
    ),
    ChatMessage(
      id: 'msg-2',
      text: 'Of course, we will send them shortly.',
      fromGuest: false,
      sentAt: _now.subtract(const Duration(minutes: 23)),
      status: MessageDeliveryStatus.read,
    ),
    ChatMessage(
      id: 'msg-3',
      text: 'Thank you!',
      fromGuest: true,
      sentAt: _now.subtract(const Duration(minutes: 22)),
      status: MessageDeliveryStatus.read,
    ),
    ChatMessage(
      id: 'msg-4',
      text: "You're welcome. Anything else?",
      fromGuest: false,
      sentAt: _now.subtract(const Duration(minutes: 21)),
      status: MessageDeliveryStatus.read,
    ),
    ChatMessage(
      id: 'msg-5',
      text: "No, that's all.",
      fromGuest: true,
      sentAt: _now.subtract(const Duration(minutes: 20)),
      status: MessageDeliveryStatus.sent,
    ),
  ],
  '412': const <ChatMessage>[],
  '218': const <ChatMessage>[],
};

final Map<String, List<AppNotification>> demoNotificationsByRoom = {
  '305': [
    AppNotification(
      id: 'ntf-1',
      type: NotificationType.requestUpdate,
      title: 'Request update',
      body: 'REQ-1044 is now Assigned.',
      createdAt: _now.subtract(const Duration(minutes: 10)),
      targetId: 'REQ-1044',
    ),
    AppNotification(
      id: 'ntf-2',
      type: NotificationType.message,
      title: 'New message',
      body: 'The hotel team replied to you.',
      createdAt: _now.subtract(const Duration(minutes: 35)),
    ),
    AppNotification(
      id: 'ntf-3',
      type: NotificationType.survey,
      title: "We'd like your opinion",
      body: 'Tell us about your stay. It takes one minute.',
      createdAt: _now.subtract(const Duration(hours: 2)),
      targetId: 'survey-1',
    ),
    AppNotification(
      id: 'ntf-4',
      type: NotificationType.requestUpdate,
      title: 'Request update',
      body: 'REQ-1042 is now Done.',
      createdAt: _now.subtract(const Duration(hours: 4, minutes: 15)),
      targetId: 'REQ-1042',
      read: true,
    ),
  ],
  '412': const <AppNotification>[],
  '218': const <AppNotification>[],
};

final Map<String, List<Survey>> demoSurveysByRoom = {
  '305': [
    Survey(
      id: 'survey-1',
      title: 'How was your stay?',
      contextLabel: 'After your check-out',
      receivedAt: _now.subtract(const Duration(hours: 2)),
      questions: const [
        SurveyQuestion(
          id: 'q1',
          type: SurveyQuestionType.csat,
          text: 'How satisfied were you with your stay?',
        ),
        SurveyQuestion(
          id: 'q2',
          type: SurveyQuestionType.nps,
          text:
              'How likely are you to recommend Grand Palm Hotel to a friend or colleague?',
        ),
        SurveyQuestion(
          id: 'q3',
          type: SurveyQuestionType.comment,
          text: 'Anything else you would like to tell us?',
        ),
      ],
    ),
    Survey(
      id: 'survey-2',
      title: 'How was our service?',
      contextLabel: 'About request REQ-1042',
      receivedAt: _now.subtract(const Duration(hours: 4)),
      questions: const [
        SurveyQuestion(
          id: 'q1',
          type: SurveyQuestionType.csat,
          text: 'How satisfied are you with how we handled your request?',
        ),
        SurveyQuestion(
          id: 'q2',
          type: SurveyQuestionType.comment,
          text: 'Anything else you would like to tell us?',
        ),
      ],
    ),
    Survey(
      id: 'survey-0',
      title: 'How was our service?',
      contextLabel: 'About request REQ-1038',
      receivedAt: _now.subtract(const Duration(days: 3)),
      status: SurveyStatus.answered,
      answeredAt: _now.subtract(const Duration(days: 2, hours: 20)),
      answers: const [SurveyAnswer(questionId: 'q1', rating: 4)],
      questions: const [
        SurveyQuestion(
          id: 'q1',
          type: SurveyQuestionType.csat,
          text: 'How satisfied are you with how we handled your request?',
        ),
      ],
    ),
  ],
  '412': const <Survey>[],
  '218': const <Survey>[],
};

final Map<String, List<LoyaltyEntry>> demoLoyaltyByRoom = {
  '305': [
    LoyaltyEntry(
      id: 'loy-1',
      type: LoyaltyEntryType.earn,
      points: 450,
      reason: 'Stay · Grand Palm Hotel',
      source: 'Stay',
      date: _now.subtract(const Duration(days: 3)),
    ),
    LoyaltyEntry(
      id: 'loy-2',
      type: LoyaltyEntryType.earn,
      points: 80,
      reason: 'Room service order',
      source: 'Dining',
      date: _now.subtract(const Duration(days: 5)),
    ),
    LoyaltyEntry(
      id: 'loy-3',
      type: LoyaltyEntryType.redeem,
      points: -200,
      reason: 'Redeemed: free breakfast',
      source: 'Dining',
      date: _now.subtract(const Duration(days: 9)),
    ),
    LoyaltyEntry(
      id: 'loy-4',
      type: LoyaltyEntryType.earn,
      points: 320,
      reason: 'Spa & Wellness treatment',
      source: 'Wellness',
      date: _now.subtract(const Duration(days: 14)),
    ),
    LoyaltyEntry(
      id: 'loy-5',
      type: LoyaltyEntryType.adjust,
      points: 50,
      reason: 'Courtesy adjustment',
      source: 'Concierge',
      date: _now.subtract(const Duration(days: 20)),
    ),
    LoyaltyEntry(
      id: 'loy-6',
      type: LoyaltyEntryType.expire,
      points: -100,
      reason: 'Points expired',
      source: 'Expiry',
      date: _now.subtract(const Duration(days: 35)),
    ),
    LoyaltyEntry(
      id: 'loy-7',
      type: LoyaltyEntryType.redeem,
      points: -150,
      reason: 'Redeemed: late check-out',
      source: 'Front desk',
      date: _now.subtract(const Duration(days: 50)),
    ),
    LoyaltyEntry(
      id: 'loy-8',
      type: LoyaltyEntryType.earn,
      points: 2000,
      reason: 'Stay · Grand Palm Hotel',
      source: 'Stay',
      date: _now.subtract(const Duration(days: 150)),
    ),
  ],
  '412': const <LoyaltyEntry>[],
  '218': [
    LoyaltyEntry(
      id: 'loy-9',
      type: LoyaltyEntryType.earn,
      points: 600,
      reason: 'Stay · Grand Palm Hotel',
      source: 'Stay',
      date: _now.subtract(const Duration(days: 10)),
    ),
  ],
};

final Map<String, List<DataRequest>> demoDataRequestsByRoom = {
  '305': [
    DataRequest(
      id: 'data-1',
      type: DataRequestType.export,
      status: DataRequestStatus.done,
      requestedAt: _now.subtract(const Duration(days: 3)),
      completedAt: _now.subtract(const Duration(days: 3, hours: -1)),
      downloadUrl: 'https://example.com/guest-data/data-1',
      downloadExpiresAt: _now.add(const Duration(days: 4)),
    ),
    DataRequest(
      id: 'data-0',
      type: DataRequestType.export,
      status: DataRequestStatus.done,
      requestedAt: _now.subtract(const Duration(days: 14)),
      completedAt: _now.subtract(const Duration(days: 14, hours: -1)),
      downloadUrl: 'https://example.com/guest-data/data-0',
      downloadExpiresAt: _now.subtract(const Duration(days: 7)),
    ),
  ],
  '412': [
    DataRequest(
      id: 'data-2',
      type: DataRequestType.delete,
      status: DataRequestStatus.inProgress,
      requestedAt: _now.subtract(const Duration(hours: 3)),
    ),
  ],
  '218': const <DataRequest>[],
};

final Map<String, List<Offer>> demoOffersByRoom = {
  '305': [
    Offer(
      id: 'offer-1',
      title: '20% off spa treatments',
      description:
          'Enjoy 20% off any treatment at the Lotus Spa during your stay. Show your code at the spa reception when you book.',
      type: OfferType.discount,
      validUntil: _now.add(const Duration(days: 12)),
    ),
    Offer(
      id: 'offer-2',
      title: 'Free room upgrade',
      description:
          'Upgrade to the next room category on your next stay, subject to availability. Show your code at the front desk when you check in.',
      type: OfferType.roomUpgrade,
      validUntil: _now.add(const Duration(days: 30)),
    ),
    Offer(
      id: 'offer-3',
      title: '500 bonus points',
      description:
          'Show your code at the front desk and we will add 500 bonus points to your loyalty account.',
      type: OfferType.bonusPoints,
      validUntil: _now.add(const Duration(days: 20)),
      opened: true,
    ),
    Offer(
      id: 'offer-4',
      title: 'Complimentary dessert',
      description: 'A dessert of your choice with any dinner at our restaurants.',
      type: OfferType.freeItem,
      validUntil: _now.add(const Duration(days: 5)),
      opened: true,
      redeemedAt: _now.subtract(const Duration(days: 9)),
    ),
    Offer(
      id: 'offer-5',
      title: 'Welcome drink',
      description: 'A welcome drink at the lobby bar on arrival.',
      type: OfferType.freeItem,
      validUntil: _now.subtract(const Duration(days: 12)),
      opened: true,
    ),
  ],
  '412': const <Offer>[],
  '218': [
    Offer(
      id: 'offer-6',
      title: 'Free breakfast for two',
      description:
          'Enjoy breakfast for two at The Veranda during your stay. Show your code to the restaurant host.',
      type: OfferType.freeItem,
      validUntil: _now.add(const Duration(days: 7)),
    ),
  ],
};

const String demoHotelName = 'Grand Palm Hotel';
