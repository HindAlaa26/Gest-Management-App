import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gest_managment_app/core/data/demo_data.dart';
import 'package:gest_managment_app/core/models/event_item.dart';
import 'package:gest_managment_app/core/models/guest_stay.dart';
import 'package:gest_managment_app/core/models/restaurant.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/helpers.dart';
import 'package:gest_managment_app/core/widgets/empty_state_card.dart';
import 'package:gest_managment_app/core/widgets/error_retry_card.dart';
import 'package:gest_managment_app/core/widgets/event_card.dart';
import 'package:gest_managment_app/core/widgets/loading_view.dart';
import 'package:gest_managment_app/core/widgets/logo_mark.dart';
import 'package:gest_managment_app/core/widgets/restaurant_card.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';
import 'package:gest_managment_app/features/auth/sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = false;
  String? error;
  List<EventItem> events = <EventItem>[];
  List<Restaurant> restaurants = <Restaurant>[];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final results = await Future.wait([
        ApiService().getEvents(),
        ApiService().getRestaurants(),
      ]);

      if (!mounted) return;

      setState(() {
        events = results[0] as List<EventItem>;
        restaurants = results[1] as List<Restaurant>;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Could not load. Pull to retry.';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void signOut() {
    Session.currentStay = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final stay = Session.currentStay;

    if (stay == null) {
      return const Scaffold(
        body: Center(
          child: Text('No guest signed in.'),
        ),
      );
    }

    final next = nextEvent(events);
    final openRestaurants = openToday(restaurants);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: RefreshIndicator(
        color: AppColors.teal,
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [
            buildHeader(stay),
            const SizedBox(height: 18),
            buildWelcomeCard(stay),
            if (loading)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: LoadingView(),
              )
            else if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: ErrorRetryCard(
                  message: error ?? 'Could not load. Pull to retry.',
                  onRetry: loadData,
                ),
              ),
            const SizedBox(height: 28),
            buildNextSection(next),
            const SizedBox(height: 28),
            buildRestaurantsSection(openRestaurants),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(GuestStay stay) {
    return Center(
      child: Row(
        children: [
          const LogoMark(size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Center(
              child: Text(
                demoHotelName,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline, color: AppColors.gold),
            color: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (value) {
              if (value == 'sign_out') {
                signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stay.guestName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Room ${stay.roomNumber}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'sign_out',
                child: Row(
                  children: [
                    Icon(Icons.logout_outlined, color: AppColors.navy),
                    SizedBox(width: 8),
                    Text('Sign out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildWelcomeCard(GuestStay stay) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.navySurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting().toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.gold,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome, ${stay.guestName}',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: AppColors.card,
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            color: AppColors.gold.withValues(alpha: 0.5),
            thickness: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: infoItem(
                  icon: Icons.meeting_room_outlined,
                  label: 'ROOM',
                  value: 'Room ${stay.roomNumber}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: infoItem(
                  icon: Icons.logout_outlined,
                  label: 'CHECK-OUT',
                  value: 'Check-out ${formatDay(stay.checkout)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget infoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.gold, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.gold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.card,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildNextSection(EventItem? next) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('NEXT'),
        const SizedBox(height: 12),
        if (next == null)
          const EmptyStateCard('No upcoming events')
        else
          EventCard(
            event: next,
            showDescription: true,
            showDate: !isSameDay(next.date, DateTime.now()),
          ),
      ],
    );
  }

  String timeLabel(EventItem event) {
    final now = DateTime.now();
    final isToday = event.date.year == now.year &&
        event.date.month == now.month &&
        event.date.day == now.day;

    if (isToday) {
      return '${event.startTime} – ${event.endTime}';
    }

    return '${formatDay(event.date)} · ${event.startTime} – ${event.endTime}';
  }

  Widget buildRestaurantsSection(List<Restaurant> openRestaurants) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Restaurants open today',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 12),
        if (openRestaurants.isEmpty)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Text(
              'No restaurants open today',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.navy,
              ),
            ),
          )
        else
          ...openRestaurants.map(
            (restaurant) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RestaurantCard(
                restaurant: restaurant,
                compact: true,
              ),
            ),
          ),
      ],
    );
  }
}
