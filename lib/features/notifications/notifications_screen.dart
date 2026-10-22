import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/app_notification.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/notification_center.dart';
import 'package:gest_managment_app/core/utils/notification_router.dart';
import 'package:gest_managment_app/core/widgets/empty_state_card.dart';
import 'package:gest_managment_app/core/widgets/error_retry_card.dart';
import 'package:gest_managment_app/core/widgets/loading_view.dart';
import 'package:gest_managment_app/core/widgets/notification_tile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool loading = true;
  String? error;
  List<AppNotification> items = const [];

  @override
  void initState() {
    super.initState();
    load();
    NotificationCenter.unreadCount.addListener(onCountChanged);
  }

  @override
  void dispose() {
    NotificationCenter.unreadCount.removeListener(onCountChanged);
    super.dispose();
  }

  void onCountChanged() {
    if (mounted) load();
  }

  Future<void> load() async {
    if (!mounted) return;

    setState(() {
      if (items.isEmpty) loading = true;
      error = null;
    });

    try {
      final result = await ApiService().getNotifications();
      if (!mounted) return;
      setState(() {
        items = result;
        loading = false;
      });
      NotificationCenter.refresh();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Could not load your notifications. Please try again.';
        loading = false;
      });
    }
  }

  Future<void> openItem(AppNotification notification) async {
    final navigator = Navigator.of(context);

    try {
      await ApiService().markNotificationRead(notification.id);
    } catch (_) {
      // Opening the item matters more than the read mark.
    }
    NotificationCenter.refresh();

    if (notification.type == NotificationType.general) {
      if (mounted) await load();
      return;
    }

    await NotificationRouter.open(
      notification.type,
      notification.targetId,
      navigator: navigator,
    );
    if (!mounted) return;
    await load();
  }

  Future<bool> confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete notification?'),
        content: const Text('This notification will be removed from your list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> deleteItem(AppNotification notification) async {
    setState(() {
      items = items.where((n) => n.id != notification.id).toList();
    });
    try {
      await ApiService().deleteNotification(notification.id);
    } catch (_) {
      // The item is already gone from the list; the next refresh will fix any mismatch.
    }
    NotificationCenter.refresh();
  }

  Future<void> markAllRead() async {
    await ApiService().markAllNotificationsRead();
    await load();
  }

  Widget buildBody() {
    if (loading) {
      return const LoadingView();
    }
    if (error != null) {
      return ErrorRetryCard(message: error!, onRetry: load);
    }
    if (items.isEmpty) {
      return const EmptyStateCard('No notifications yet');
    }

    return Column(
      children: [
        for (final item in items) ...[
          Dismissible(
            key: ValueKey(item.id),
            direction: DismissDirection.horizontal,
            confirmDismiss: (_) => confirmDelete(),
            onDismissed: (_) => deleteItem(item),
            background: const _SwipeDeleteBackground(
              alignment: Alignment.centerLeft,
            ),
            secondaryBackground: const _SwipeDeleteBackground(
              alignment: Alignment.centerRight,
            ),
            child: NotificationTile(
              notification: item,
              onTap: () => openItem(item),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = items.any((n) => !n.read);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: hasUnread ? markAllRead : null,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.teal,
          onRefresh: load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [buildBody()],
          ),
        ),
      ),
    );
  }
}

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white),
    );
  }
}
