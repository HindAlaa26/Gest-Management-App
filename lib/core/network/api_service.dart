import 'dart:math';

import 'package:gest_managment_app/core/data/demo_data.dart';
import 'package:gest_managment_app/core/models/event_item.dart';
import 'package:gest_managment_app/core/models/feedback_item.dart';
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

  Future<String> sendFeedback(FeedbackItem item) async {
    await Future.delayed(const Duration(milliseconds: 600));

    sentItems.add(item);

    final random = Random();
    final referenceNumber = 1000 + random.nextInt(9000);
    return 'GMS-$referenceNumber';
  }
}

class InvalidCredentialsException implements Exception {}
