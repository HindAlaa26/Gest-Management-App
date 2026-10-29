import 'dart:math';

import 'package:gest_managment_app/core/data/demo_data.dart';
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

  static void signOut() {
    currentStay = null;
  }
}

class ApiService {
  static const String baseUrl = '';

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
    await Future.delayed(const Duration(milliseconds: 400));

    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final entries = List<LoyaltyEntry>.from(
      demoLoyaltyByRoom[room] ?? const <LoyaltyEntry>[],
    );
    entries.sort((a, b) => b.date.compareTo(a.date));
    return LoyaltyAccount(entries: entries);
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
    await Future.delayed(const Duration(milliseconds: 600));

    final room = roomNumber.trim();
    final familyName = lastName.trim();
    final match = demoStayByLastName[familyName.toLowerCase()];

    if (match == null || match.roomNumber.trim().toLowerCase() != room.toLowerCase()) {
      throw InvalidCredentialsException();
    }

    Session.currentStay = match;
    return match;
  }

  Future<List<EventItem>> getEvents() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return demoEvents;
  }

  Future<List<Restaurant>> getRestaurants() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return demoRestaurants;
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

  Future<List<CatalogueItem>> getCatalogue(VendorType type) async {
    await Future.delayed(const Duration(milliseconds: 600));

    return demoCatalogue.where((item) => item.vendorType == type).toList();
  }


  Future<GuestRequest> sendRequest({
    required VendorType vendorType,
    required RequestUrgency urgency,
    required List<RequestLine> lines,
    String note = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final request = GuestRequest(
      reference: 'REQ-${1000 + Random().nextInt(9000)}',
      vendorType: vendorType,
      lines: lines,
      urgency: urgency,
      note: note,
      createdAt: DateTime.now(),
      status: RequestStatus.newRequest,
    );

    final room = Session.currentStay?.roomNumber ?? 'unknown';
    myRequestsByRoom.putIfAbsent(room, () => <GuestRequest>[]).insert(0, request);

    return request;
  }

  Future<List<GuestRequest>> getMyRequests() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final room = Session.currentStay?.roomNumber ?? 'unknown';
    final list = List<GuestRequest>.from(
      myRequestsByRoom[room] ?? const <GuestRequest>[],
    );
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<GuestRequest> getRequest(String reference) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return _findRequest(reference);
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
    await Future.delayed(const Duration(milliseconds: 500));

    return _updateRequest(reference, (current) {
      if (!current.canRate) throw RequestNotAllowedException();
      return current.copyWith(
        rating: RequestRating(
          stars: stars,
          comment: comment,
          ratedAt: DateTime.now(),
        ),
      );
    });
  }

  GuestRequest _findRequest(String reference) {
    final room = Session.currentStay?.roomNumber ?? 'unknown';
    for (final request in myRequestsByRoom[room] ?? const <GuestRequest>[]) {
      if (request.reference == reference) return request;
    }
    throw RequestNotFoundException();
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
