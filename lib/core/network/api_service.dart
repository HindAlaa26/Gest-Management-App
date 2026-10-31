import 'dart:convert';
import 'dart:math';

import 'package:gest_managment_app/core/data/demo_data.dart';
import 'package:gest_managment_app/core/network/api_client.dart';
import 'package:gest_managment_app/core/network/api_config.dart';
import 'package:gest_managment_app/core/models/app_notification.dart';
import 'package:gest_managment_app/core/models/survey.dart';
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

class Session {
  static GuestStay? currentStay;
  static String? token;
  static String? propertyId;
  static String? guestProfileId;
  static String? propertyName;

  static void applyToken(String jwt) {
    token = jwt;
    final claims = _decodeClaims(jwt);
    propertyId = claims['property_id'] as String?;
    guestProfileId = claims['guest_profile_id'] as String?;
  }

  static Map<String, dynamic> _decodeClaims(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return const {};
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } catch (_) {
      return const {};
    }
  }

  static void signOut() {
    currentStay = null;
    token = null;
    propertyId = null;
    guestProfileId = null;
    propertyName = null;
  }
}

class ApiService {
  static const String baseUrl = ApiConfig.baseUrl;

  static final Map<String, List<AppNotification>> myNotificationsByRoom = {
    for (final entry in demoNotificationsByRoom.entries)
      entry.key: List<AppNotification>.from(entry.value),
  };

  static String? lastPushToken;

  static final Map<String, List<Survey>> mySurveysByRoom = {
    for (final entry in demoSurveysByRoom.entries)
      entry.key: List<Survey>.from(entry.value),
  };

  static bool failNextSurveySubmit = false;

  static final Map<String, List<DataRequest>> myDataRequestsByRoom = {
    for (final entry in demoDataRequestsByRoom.entries)
      entry.key: List<DataRequest>.from(entry.value),
  };

  static final Map<String, List<Offer>> myOffersByRoom = {
    for (final entry in demoOffersByRoom.entries)
      entry.key: List<Offer>.from(entry.value),
  };

  Future<List<Survey>> getSurveys() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = List<Survey>.from(mySurveysByRoom[room] ?? const <Survey>[]);
    list.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return list;
  }

   Future<void> submitSurvey(String id, List<SurveyAnswer> answers) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (failNextSurveySubmit) {
      failNextSurveySubmit = false;
      throw Exception('Could not send answers');
    }

    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = mySurveysByRoom[room];
    final index = list?.indexWhere((s) => s.id == id) ?? -1;
    if (list == null || index == -1) throw SurveyNotFoundException();
    if (list[index].status == SurveyStatus.answered) {
      throw SurveyAlreadyAnsweredException();
    }

    list[index] = list[index].copyAnswered(DateTime.now(), answers);
  }

  Future<List<Offer>> getOffers() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = List<Offer>.from(myOffersByRoom[room] ?? const <Offer>[]);
    list.sort((a, b) => a.validUntil.compareTo(b.validUntil));
    return list;
  }

  Future<void> markOfferOpened(String id) async {
    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = myOffersByRoom[room];
    final index = list?.indexWhere((o) => o.id == id) ?? -1;
    if (list == null || index == -1) throw OfferNotFoundException();

    list[index] = list[index].copyOpened();
  }

  Future<String> useOffer(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = myOffersByRoom[room];
    final index = list?.indexWhere((o) => o.id == id) ?? -1;
    if (list == null || index == -1) throw OfferNotFoundException();
    if (!list[index].isAvailable) throw OfferNotAvailableException();

    list[index] = list[index].copyOpened();
    return _offerCode(id);
  }

  static String _offerCode(String id) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final seed = id.codeUnits.fold<int>(
      7,
      (sum, unit) => (sum * 31 + unit) % 1000003,
    );
    final random = Random(seed);
    final letters = List.generate(5, (_) => chars[random.nextInt(chars.length)]);
    return 'GMS-${letters.join()}';
  }

  Future<List<DataRequest>> getDataRequests() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = List<DataRequest>.from(
      myDataRequestsByRoom[room] ?? const <DataRequest>[],
    );
    list.sort((a, b) => b.requestedAt.compareTo(a.requestedAt));
    return list;
  }

  Future<DataRequest> requestDataExport() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _addDataRequest(DataRequestType.export);
  }

  Future<DataRequest> requestDataDeletion() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _addDataRequest(DataRequestType.delete);
  }

  DataRequest _addDataRequest(DataRequestType type) {
    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = myDataRequestsByRoom.putIfAbsent(
      room,
      () => <DataRequest>[],
    );
    if (list.any((r) => r.type == type && r.isActive)) {
      throw DataRequestInProgressException();
    }

    final request = DataRequest(
      id: 'data-${DateTime.now().microsecondsSinceEpoch}',
      type: type,
      status: DataRequestStatus.pending,
      requestedAt: DateTime.now(),
    );
    list.add(request);
    return request;
  }

  Future<LoyaltyAccount> getLoyalty() async {
    final json = await ApiClient.get('/api/guest-app/loyalty');
    final data = json['data'] as Map<String, dynamic>;

    final recent = (data['recent'] as List?) ?? const [];
    final entries = <LoyaltyEntry>[];
    for (var i = 0; i < recent.length; i++) {
      entries.add(_loyaltyEntryFromJson(recent[i] as Map<String, dynamic>, i));
    }
    entries.sort((a, b) => b.date.compareTo(a.date));

    return LoyaltyAccount(
      entries: entries,
      balance: (data['availablePoints'] as num?)?.toInt() ?? 0,
      tierPoints: (data['rollingEarnedPoints'] as num?)?.toInt() ?? 0,
      serverTierName: data['tier'] as String?,
    );
  }

  static LoyaltyEntry _loyaltyEntryFromJson(Map<String, dynamic> j, int index) {
    final kind = '${j['type']}'.toLowerCase();
    LoyaltyEntryType type = LoyaltyEntryType.earn;
    String label = 'Earned';
    if (kind == 'redeem') {
      type = LoyaltyEntryType.redeem;
      label = 'Redeemed';
    } else if (kind == 'expire') {
      type = LoyaltyEntryType.expire;
      label = 'Expired';
    } else if (kind == 'adjust') {
      type = LoyaltyEntryType.adjust;
      label = 'Adjustment';
    }

    final when = _parseUtc(j['occurredAtUtc'] as String);
    return LoyaltyEntry(
      id: '${j['occurredAtUtc']}-$index',
      type: type,
      points: (j['points'] as num?)?.toInt() ?? 0,
      reason: (j['reason'] as String?) ?? '',
      source: label,
      date: when,
    );
  }

  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = List<AppNotification>.from(
      myNotificationsByRoom[room] ?? const <AppNotification>[],
    );
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  
  Future<void> markNotificationRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = myNotificationsByRoom[room];
    if (list == null) return;
    final index = list.indexWhere((n) => n.id == id);
    if (index != -1) list[index] = list[index].copyWith(read: true);
  }

  Future<void> markAllNotificationsRead() async {
    await Future.delayed(const Duration(milliseconds: 150));

    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = myNotificationsByRoom[room];
    if (list == null) return;
    for (var i = 0; i < list.length; i++) {
      list[i] = list[i].copyWith(read: true);
    }
  }

  Future<void> deleteNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final room = Session.currentStay?.roomNumber ?? 'unknown';
    myNotificationsByRoom[room]?.removeWhere((n) => n.id == id);
  }

  void addNotification(AppNotification notification) {
    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = myNotificationsByRoom.putIfAbsent(room, () => <AppNotification>[]);
    if (list.any((n) => n.id == notification.id)) return;
    list.insert(0, notification);
  }

  Future<void> registerPushToken(String token) async {
    await Future.delayed(const Duration(milliseconds: 300));

    lastPushToken = token;
  }

  static final Map<String, List<ChatMessage>> myMessagesByRoom = {
    for (final entry in demoMessagesByRoom.entries)
      entry.key: List<ChatMessage>.from(entry.value),
  };

  static bool failNextMessage = false;

  Future<List<ChatMessage>> getMessages() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = List<ChatMessage>.from(myMessagesByRoom[room] ?? const <ChatMessage>[]);
    list.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    return list;
  }

  Future<ChatMessage> sendMessage(String text) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (failNextMessage) {
      failNextMessage = false;
      throw Exception('Message could not be sent');
    }

    final message = ChatMessage(
      id: 'msg-${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      fromGuest: true,
      sentAt: DateTime.now(),
      status: MessageDeliveryStatus.sent,
    );

    final room = Session.currentStay?.roomNumber ?? 'unknown';
    myMessagesByRoom.putIfAbsent(room, () => <ChatMessage>[]).add(message);
    return message;
  }
  static final List<FeedbackItem> sentItems = <FeedbackItem>[];
  static final Map<String, List<FeedbackRecord>> myFeedbackByRoom = {
    for (final entry in demoFeedbackByRoom.entries)
      entry.key: List<FeedbackRecord>.from(entry.value),
  };

  Future<GuestStay> signIn(String roomNumber, String lastName) async {
    try {
      final json = await ApiClient.post('/api/guest-auth/login', {
        'roomNumber': roomNumber.trim(),
        'lastName': lastName.trim(),
      }, auth: false);
      final data = json['data'] as Map<String, dynamic>;
      Session.applyToken(data['accessToken'] as String);
      final hotel = (data['propertyName'] as String?)?.trim();
      Session.propertyName = (hotel == null || hotel.isEmpty) ? null : hotel;
      final stay = GuestStay(
        guestName: data['guestName'] as String,
        roomNumber: data['roomNumber'] as String,
        checkout: DateTime.parse(data['checkoutDate'] as String),
      );
      Session.currentStay = stay;
      return stay;
    } on UnauthorizedException {
      throw InvalidCredentialsException();
    }
  }
 
  Future<List<EventItem>> getEvents() async {
    final propertyId = Session.propertyId;
    if (propertyId == null) throw UnauthorizedException('Please sign in again.');

    final query = <String, String>{'from': _ymd(DateTime.now())};
    final checkout = Session.currentStay?.checkout;
    if (checkout != null) query['to'] = _ymd(checkout);

    final json = await ApiClient.get(
      '/api/public/properties/$propertyId/events',
      query: query,
      auth: false,
    );
    final list = (json['data'] as List?) ?? const [];
    return list
        .map((e) => _eventFromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Restaurant>> getRestaurants() async {
    final propertyId = Session.propertyId;
    if (propertyId == null) throw UnauthorizedException('Please sign in again.');

    final json = await ApiClient.get(
      '/api/public/properties/$propertyId/restaurants',
      auth: false,
    );
    final list = (json['data'] as List?) ?? const [];
    return list
        .map((e) => _restaurantFromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _text(Object? en, Object? ar) {
    final e = (en as String?)?.trim() ?? '';
    if (e.isNotEmpty) return e;
    return (ar as String?)?.trim() ?? '';
  }

  static String? _hhmm(Object? value) {
    final s = (value as String?)?.trim() ?? '';
    if (s.length < 5) return null;
    return s.substring(0, 5);
  }

  static EventItem _eventFromJson(Map<String, dynamic> j) {
    return EventItem(
      id: j['id'] as String,
      title: _text(j['titleEn'], j['titleAr']),
      date: DateTime.parse(j['eventDate'] as String),
      startTime: _hhmm(j['startTime']) ?? '00:00',
      endTime: _hhmm(j['endTime']) ?? '00:00',
      place: (j['location'] as String?) ?? '',
      type: '${j['eventType']}'.toLowerCase() == 'party'
          ? EventType.party
          : EventType.event,
      description: _text(j['descriptionEn'], j['descriptionAr']),
    );
  }

  static const Map<String, int> _weekdayByName = {
    'mon': 1,
    'tue': 2,
    'wed': 3,
    'thu': 4,
    'fri': 5,
    'sat': 6,
    'sun': 7,
  };

  static const List<String> _weekdayNames = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static Restaurant _restaurantFromJson(Map<String, dynamic> j) {
    final raw = (j['openDays'] as String?) ?? '';
    final days = <int>{};
    for (final token in raw.split(RegExp(r'[,\s;]+'))) {
      if (token.length < 3) continue;
      final day = _weekdayByName[token.substring(0, 3).toLowerCase()];
      if (day != null) days.add(day);
    }

    final stated = days.isNotEmpty;
    final weekdays = stated ? (days.toList()..sort()) : [1, 2, 3, 4, 5, 6, 7];
    final label = !stated
        ? 'Opening days not listed'
        : weekdays.length == 7
            ? 'Open every day'
            : weekdays.map((d) => _weekdayNames[d - 1]).join(', ');

    return Restaurant(
      name: _text(j['nameEn'], j['nameAr']),
      openDays: label,
      openWeekdays: weekdays,
      breakfast: MealHours(
        open: _hhmm(j['breakfastStart']),
        close: _hhmm(j['breakfastEnd']),
      ),
      lunch: MealHours(
        open: _hhmm(j['lunchStart']),
        close: _hhmm(j['lunchEnd']),
      ),
      dinner: MealHours(
        open: _hhmm(j['dinnerStart']),
        close: _hhmm(j['dinnerEnd']),
      ),
    );
  }

  Future<List<FeedbackRecord>> getMyFeedback() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final room = Session.currentStay?.roomNumber ?? '';
    final records = myFeedbackByRoom[room] ?? const <FeedbackRecord>[];
    final ordered = List<FeedbackRecord>.from(records)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ordered;
  }

  Future<String> sendFeedback(FeedbackItem item) async {
    await Future.delayed(const Duration(milliseconds: 600));

    sentItems.add(item);

    final random = Random();
    final referenceNumber = 1000 + random.nextInt(9000);
    final reference = 'GMS-$referenceNumber';
    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final roomRecords = myFeedbackByRoom.putIfAbsent(room, () => <FeedbackRecord>[]);
    roomRecords.insert(
      0,
      FeedbackRecord(
        reference: reference,
        type: item.type,
        category: item.category,
        message: item.message,
        createdAt: DateTime.now(),
        status: CaseStatus.open,
      ),
    );

    return reference;
  }

  static final Map<String, List<GuestRequest>> myRequestsByRoom = {
    for (final entry in demoRequestsByRoom.entries)
      entry.key: List<GuestRequest>.from(entry.value),
  };


  static final Map<String, CatalogueItem> _catalogueCache = {};

  Future<List<CatalogueItem>> _loadCatalogue() async {
    final json = await ApiClient.get('/api/guest-app/catalogue');
    final list = (json['data'] as List?) ?? const [];
    final items = list
        .map((e) => _catalogueItemFromJson(e as Map<String, dynamic>))
        .toList();
    _catalogueCache
      ..clear()
      ..addEntries(items.map((i) => MapEntry(i.id, i)));
    return items;
  }

  Future<void> _ensureCatalogue() async {
    if (_catalogueCache.isNotEmpty) return;
    try {
      await _loadCatalogue();
    } catch (_) {
    }
  }

  Future<List<CatalogueItem>> getCatalogue(VendorType type) async {
    final items = await _loadCatalogue();
    return items.where((item) => item.vendorType == type).toList();
  }


  static DateTime _parseUtc(String value) {
    final hasZone =
        value.endsWith('Z') || RegExp(r'[+-]\d\d:\d\d$').hasMatch(value);
    return DateTime.parse(hasZone ? value : '${value}Z').toLocal();
  }

  static VendorType _vendorTypeFrom(Object? value) {
    switch ('$value'.toLowerCase()) {
      case 'water':
        return VendorType.water;
      case 'drinks':
        return VendorType.drinks;
      case 'cleaning':
        return VendorType.cleaning;
      case 'maintenance':
        return VendorType.maintenance;
      default:
        return VendorType.other;
    }
  }

  static RequestStatus _requestStatusFrom(Object? value) {
    switch ('$value'.toLowerCase()) {
      case 'assigned':
        return RequestStatus.assigned;
      case 'inprogress':
        return RequestStatus.inProgress;
      case 'done':
        return RequestStatus.done;
      case 'cancelled':
      case 'failed':
        return RequestStatus.cancelled;
      default:
        return RequestStatus.newRequest;
    }
  }

  static CatalogueItem _catalogueItemFromJson(Map<String, dynamic> j) {
    return CatalogueItem(
      id: j['id'] as String,
      vendorType: _vendorTypeFrom(j['vendorType']),
      nameEn: _text(j['nameEn'], j['nameAr']),
      nameAr: (j['nameAr'] as String?) ?? '',
      price: (j['price'] as num?)?.toDouble() ?? 0,
      chargeable: (j['isChargeable'] as bool?) ?? false,
    );
  }

  static GuestRequest _requestFromJson(Map<String, dynamic> j) {
    final lines = <RequestLine>[];
    for (final raw in (j['items'] as List?) ?? const []) {
      final m = raw as Map<String, dynamic>;
      final id = m['catalogueItemId'] as String;
      final known = _catalogueCache[id];
      lines.add(
        RequestLine(
          item: CatalogueItem(
            id: id,
            vendorType: known?.vendorType ?? VendorType.other,
            nameEn: _text(m['nameEn'], m['nameAr']),
            nameAr: (m['nameAr'] as String?) ?? '',
            price: (m['unitPrice'] as num?)?.toDouble() ?? 0,
            chargeable: (m['isChargeable'] as bool?) ?? false,
          ),
          qty: (m['quantity'] as num?)?.toInt() ?? 1,
        ),
      );
    }

    final history = <RequestStatusEntry>[];
    for (final raw in (j['statusHistory'] as List?) ?? const []) {
      final m = raw as Map<String, dynamic>;
      history.add(
        RequestStatusEntry(
          status: _requestStatusFrom(m['status']),
          at: _parseUtc(m['changedAtUtc'] as String),
        ),
      );
    }

    RequestRating? rating;
    final ratingJson = j['rating'];
    if (ratingJson is Map<String, dynamic>) {
      rating = RequestRating(
        stars: (ratingJson['stars'] as num?)?.toInt() ?? 0,
        comment: (ratingJson['comment'] as String?) ?? '',
        ratedAt: _parseUtc(ratingJson['createdAtUtc'] as String),
      );
    }

    return GuestRequest(
      reference: j['id'] as String,
      vendorType:
          lines.isEmpty ? VendorType.other : lines.first.item.vendorType,
      lines: lines,
      urgency: '${j['urgency']}'.toLowerCase() == 'normal'
          ? RequestUrgency.normal
          : RequestUrgency.urgent,
      note: (j['note'] as String?) ?? '',
      createdAt: _parseUtc(j['createdAtUtc'] as String),
      status: _requestStatusFrom(j['status']),
      history: history,
      rating: rating,
    );
  }


  Future<GuestRequest> sendRequest({
    required VendorType vendorType,
    required RequestUrgency urgency,
    required List<RequestLine> lines,
    String note = '',
  }) async {
    final body = <String, dynamic>{
      'items': [
        for (final line in lines)
          {'catalogueItemId': line.item.id, 'quantity': line.qty},
      ],
      'urgency': urgency == RequestUrgency.urgent ? 'Urgent' : 'Normal',
    };
    if (note.trim().isNotEmpty) body['note'] = note.trim();

    final json = await ApiClient.post('/api/guest-app/requests', body);
    return _requestFromJson(json['data'] as Map<String, dynamic>);
  }

  Future<List<GuestRequest>> getMyRequests() async {
    await _ensureCatalogue();
    final json = await ApiClient.get(
      '/api/guest-app/requests',
      query: {'page': '1', 'size': '100'},
    );
    final list = (json['data'] as List?) ?? const [];
    return list
        .map((e) => _requestFromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<GuestRequest> getRequest(String reference) async {
    await _ensureCatalogue();
    final json = await ApiClient.get('/api/guest-app/requests/$reference');
    return _requestFromJson(json['data'] as Map<String, dynamic>);
  }

  Future<GuestRequest> changeRequest({
    required String reference,
    required List<RequestLine> lines,
    required RequestUrgency urgency,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return _updateRequest(reference, (current) {
      if (!current.canChange) throw RequestNotAllowedException();
      return current.copyWith(lines: lines, urgency: urgency);
    });
  }

  Future<GuestRequest> cancelRequest({
    required String reference,
    required String reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return _updateRequest(reference, (current) {
      if (!current.canCancel) throw RequestNotAllowedException();
      return current.copyWith(
        status: RequestStatus.cancelled,
        cancelReason: reason,
        history: [
          ...current.history,
          RequestStatusEntry(status: RequestStatus.cancelled, at: DateTime.now()),
        ],
      );
    });
  }

  Future<GuestRequest> rateRequest({
    required String reference,
    required int stars,
    String comment = '',
  }) async {
    final body = <String, dynamic>{'stars': stars};
    if (comment.trim().isNotEmpty) body['comment'] = comment.trim();

    await ApiClient.post('/api/guest-app/requests/$reference/rating', body);
    return getRequest(reference);
  }

  GuestRequest _updateRequest(
    String reference,
    GuestRequest Function(GuestRequest current) update,
  ) {
    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = myRequestsByRoom[room] ?? <GuestRequest>[];
    final index = list.indexWhere((request) => request.reference == reference);
    if (index == -1) throw RequestNotFoundException();

    final updated = update(list[index]);
    list[index] = updated;
    return updated;
  }
}

class InvalidCredentialsException implements Exception {}

class RequestNotFoundException implements Exception {}

class RequestNotAllowedException implements Exception {}
