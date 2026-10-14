import 'package:flutter/material.dart';

import '../models/event_item.dart';
import '../network/api_service.dart';
import '../utils/helpers.dart';
import '../widgets/day_header.dart';
import '../widgets/empty_state_card.dart';
import '../widgets/error_retry_card.dart';
import '../widgets/event_card.dart';
import '../widgets/gold_divider.dart';
import '../widgets/loading_view.dart';
import '../widgets/section_label.dart';
import 'event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  bool loading = false;
  String? error;
  List<EventItem> events = <EventItem>[];

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final allEvents = await ApiService().getEvents();
      final stay = Session.currentStay;

      if (!mounted) return;

      setState(() {
        events = stay == null ? <EventItem>[] : eventsDuringStay(allEvents, stay);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Could not load events';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events & Parties'),
      ),
      body: RefreshIndicator(
        onRefresh: loadEvents,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const SectionLabel('DURING YOUR STAY'),
            const SizedBox(height: 10),
            const GoldDivider(width: 220),
            const SizedBox(height: 20),
            if (loading && events.isEmpty)
              const LoadingView()
            else if (error != null && events.isEmpty)
              ErrorRetryCard(
                message: error!,
                onRetry: loadEvents,
              )
            else if (events.isEmpty)
              const EmptyStateCard('No events during your stay')
            else ...buildDayGroups(),
          ],
        ),
      ),
    );
  }

  List<Widget> buildDayGroups() {
    final grouped = <DateTime, List<EventItem>>{};

    for (final event in events) {
      final day = DateTime(event.date.year, event.date.month, event.date.day);
      grouped.putIfAbsent(day, () => <EventItem>[]).add(event);
    }

    final days = grouped.keys.toList()..sort();

    final widgets = <Widget>[];
    for (final day in days) {
      final dayEvents = grouped[day]!;
      widgets.add(
        DayHeader(
          title: dayTitle(day),
          count: dayEvents.length,
        ),
      );

      for (final event in dayEvents) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: EventCard(
              event: event,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetailScreen(event: event),
                  ),
                );
              },
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
