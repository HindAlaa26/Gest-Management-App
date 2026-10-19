import 'dart:math';

import 'package:gest_managment_app/core/data/demo_data.dart';
import 'package:gest_managment_app/core/models/case_status.dart';
import 'package:gest_managment_app/core/models/event_item.dart';
import 'package:gest_managment_app/core/models/feedback_item.dart';
import 'package:gest_managment_app/core/models/feedback_record.dart';
import 'package:gest_managment_app/core/models/guest_stay.dart';
import 'package:gest_managment_app/core/models/restaurant.dart';

class Session {
  static GuestStay? currentStay;

  static void signOut() {
    currentStay = null;
  }
}

class ApiService {
  static const String baseUrl = '';
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

    // DEMO: replace with the real API calls. Backend: #50 creates the case; a "my cases" GET endpoint is still to be agreed with Ahmed Alshobaki.
    return reference;
  }
}

class InvalidCredentialsException implements Exception {}
