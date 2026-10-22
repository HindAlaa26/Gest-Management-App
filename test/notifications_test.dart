import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/data/demo_data.dart';
import 'package:gest_managment_app/core/models/app_notification.dart';
import 'package:gest_managment_app/core/network/api_service.dart';

void main() {
  group('notifications', () {
    test('list comes back newest first with unread ones', () async {
      Session.currentStay = demoStays.first;

      final list = await ApiService().getNotifications();

      expect(list, isNotEmpty);
      for (var i = 1; i < list.length; i++) {
        expect(list[i].createdAt.isAfter(list[i - 1].createdAt), isFalse);
      }
      expect(list.any((n) => !n.read), isTrue);
    });

    test('a room without notifications gets an empty list', () async {
      Session.currentStay = demoStays[1];

      expect(await ApiService().getNotifications(), isEmpty);
    });

    test('markNotificationRead and markAllNotificationsRead', () async {
      Session.currentStay = demoStays.first;

      await ApiService().markNotificationRead('ntf-1');
      var list = await ApiService().getNotifications();
      expect(list.firstWhere((n) => n.id == 'ntf-1').read, isTrue);

      await ApiService().markAllNotificationsRead();
      list = await ApiService().getNotifications();
      expect(list.every((n) => n.read), isTrue);
    });

    test('a pushed notification is added once', () async {
      ApiService.myNotificationsByRoom.clear();
      Session.currentStay = demoStays.first;
      final pushed = AppNotification(
        id: 'push-1',
        type: NotificationType.message,
        title: 'New message',
        body: 'Hello',
        createdAt: DateTime.now(),
      );

      ApiService().addNotification(pushed);
      ApiService().addNotification(pushed);

      expect(await ApiService().getNotifications(), hasLength(1));
    });

    test('registering a push token stores it', () async {
      await ApiService().registerPushToken('token-123');

      expect(ApiService.lastPushToken, 'token-123');
    });
  });
}
