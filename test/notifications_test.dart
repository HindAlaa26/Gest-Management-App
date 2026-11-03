import 'package:flutter_test/flutter_test.dart';
import 'package:gest_managment_app/core/models/app_notification.dart';
import 'package:gest_managment_app/core/network/api_service.dart';

AppNotification _note(String id, DateTime at, {bool read = false}) {
  return AppNotification(
    id: id,
    type: NotificationType.message,
    title: 'New message',
    body: 'Hello',
    createdAt: at,
    read: read,
  );
}

void main() {
  group('notifications', () {
    setUp(() {
      Session.currentStay = null;
      ApiService.myNotificationsByRoom.clear();
    });

    test('starts empty', () async {
      expect(await ApiService().getNotifications(), isEmpty);
    });

    test('a pushed notification is added once', () async {
      final pushed = _note('push-1', DateTime.now());

      ApiService().addNotification(pushed);
      ApiService().addNotification(pushed);

      expect(await ApiService().getNotifications(), hasLength(1));
    });

    test('list comes back newest first', () async {
      final now = DateTime.now();
      ApiService().addNotification(_note('old', now.subtract(const Duration(hours: 2))));
      ApiService().addNotification(_note('new', now));

      final list = await ApiService().getNotifications();

      expect(list.map((n) => n.id), ['new', 'old']);
    });

    test('markNotificationRead and markAllNotificationsRead', () async {
      final now = DateTime.now();
      ApiService().addNotification(_note('a', now));
      ApiService().addNotification(_note('b', now.subtract(const Duration(minutes: 1))));

      await ApiService().markNotificationRead('a');
      var list = await ApiService().getNotifications();
      expect(list.firstWhere((n) => n.id == 'a').read, isTrue);
      expect(list.firstWhere((n) => n.id == 'b').read, isFalse);

      await ApiService().markAllNotificationsRead();
      list = await ApiService().getNotifications();
      expect(list.every((n) => n.read), isTrue);
    });

    test('deleteNotification removes it', () async {
      ApiService().addNotification(_note('a', DateTime.now()));

      await ApiService().deleteNotification('a');

      expect(await ApiService().getNotifications(), isEmpty);
    });
  });
}
