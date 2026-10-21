import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/chat_message.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/chat_time.dart';
import 'package:gest_managment_app/core/widgets/chat_bubble.dart';
import 'package:gest_managment_app/core/widgets/day_separator.dart';
import 'package:gest_managment_app/core/widgets/error_retry_card.dart';
import 'package:gest_managment_app/core/widgets/gold_divider.dart';
import 'package:gest_managment_app/core/widgets/loading_view.dart';
import 'package:gest_managment_app/core/widgets/message_composer.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ScrollController scrollController = ScrollController();

  List<ChatMessage> messages = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> loadMessages() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await ApiService().getMessages();
      if (!mounted) return;
      setState(() {
        messages = List<ChatMessage>.from(result);
        loading = false;
      });
      scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Could not load your messages. Please try again.';
        loading = false;
      });
    }
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> sendText(String text, {ChatMessage? retrying}) async {
    final pending = ChatMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      text: text,
      fromGuest: true,
      sentAt: DateTime.now(),
      status: MessageDeliveryStatus.sending,
    );

    setState(() {
      if (retrying != null) {
        messages.removeWhere((m) => m.id == retrying.id);
      }
      messages.add(pending);
    });
    scrollToBottom();

    try {
      final sent = await ApiService().sendMessage(text);
      if (!mounted) return;
      setState(() {
        final index = messages.indexWhere((m) => m.id == pending.id);
        if (index != -1) messages[index] = sent;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final index = messages.indexWhere((m) => m.id == pending.id);
        if (index != -1) {
          messages[index] = pending.copyWith(status: MessageDeliveryStatus.failed);
        }
      });
    }
  }

  List<Widget> buildItems() {
    final items = <Widget>[];
    DateTime? lastDay;
    ChatMessage? previous;

    for (final message in messages) {
      final day = DateTime(
        message.sentAt.year,
        message.sentAt.month,
        message.sentAt.day,
      );

      if (lastDay == null || day != lastDay) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(child: DaySeparator(label: chatDayLabel(message.sentAt))),
          ),
        );
        lastDay = day;
        previous = null;
      }

      items.add(
        ChatBubble(
          message: message,
          showSenderLabel: previous == null || previous.fromGuest,
          onRetry: message.status == MessageDeliveryStatus.failed
              ? () => sendText(message.text, retrying: message)
              : null,
        ),
      );
      previous = message;
    }

    return items;
  }

  Widget buildContent() {
    if (loading) {
      return const Center(child: LoadingView());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ErrorRetryCard(message: error!, onRetry: loadMessages),
        ),
      );
    }

    if (messages.isEmpty) {
      return const _EmptyMessages();
    }

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      children: buildItems(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Chat with the hotel team',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ),
            Expanded(child: buildContent()),
            if (!loading && error == null) MessageComposer(onSend: sendText),
          ],
        ),
      ),
    );
  }
}

class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tealSoft,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.teal,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No messages yet',
              style: textTheme.titleLarge?.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            Text(
              'Say hello — the hotel team will reply here.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            const GoldDivider(width: 140),
          ],
        ),
      ),
    );
  }
}
