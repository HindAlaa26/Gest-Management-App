import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/data/demo_data.dart';
import 'package:gest_managment_app/core/models/chat_message.dart';
import 'package:gest_managment_app/core/network/api_service.dart';

void main() {
  group('messages', () {
    test('thread comes back oldest first', () async {
      Session.currentStay = demoStays.first;

      final list = await ApiService().getMessages();

      expect(list, isNotEmpty);
      for (var i = 1; i < list.length; i++) {
        expect(list[i].sentAt.isBefore(list[i - 1].sentAt), isFalse);
      }
    });

    test('a room without messages gets an empty thread', () async {
      Session.currentStay = demoStays[1];

      final list = await ApiService().getMessages();

      expect(list, isEmpty);
    });

    test('sendMessage stores a guest message as Sent', () async {
      ApiService.myMessagesByRoom.clear();
      Session.currentStay = demoStays.first;

      final sent = await ApiService().sendMessage('Hello');

      expect(sent.fromGuest, isTrue);
      expect(sent.status, MessageDeliveryStatus.sent);
      expect(await ApiService().getMessages(), hasLength(1));
    });

    test('a failed send throws once and does not store the message', () async {
      ApiService.myMessagesByRoom.clear();
      Session.currentStay = demoStays.first;
      ApiService.failNextMessage = true;

      await expectLater(ApiService().sendMessage('Hi'), throwsException);
      expect(await ApiService().getMessages(), isEmpty);

      final retry = await ApiService().sendMessage('Hi');
      expect(retry.status, MessageDeliveryStatus.sent);
    });
  });
}
