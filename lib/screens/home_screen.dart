import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/demo_data.dart';
import '../models/event_item.dart';
import '../models/guest_stay.dart';
import '../models/restaurant.dart';
import '../network/api_service.dart';
import '../screens/sign_in_screen.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/type_chip.dart';

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
        color: AppColors.gold,
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
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: AppColors.gold,
                      strokeWidth: 3,
                    ),
                  ),
                ),
              )
            else if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: buildErrorCard(),
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
           AppLogo(height: 36, logoPath: "assets/images/mini_logo.png"),
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

  Widget buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            error ?? 'Could not load. Pull to retry.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: loadData,
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNextSection(EventItem? next) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NEXT',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.gold,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        if (next == null)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Text(
              'No upcoming events',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.navy,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        next.title,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TypeChip(type: next.type),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  next.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.gold,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              next.place,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppColors.gold,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              timeLabel(next),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.navy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
          ...openRestaurants.map((restaurant) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: AppColors.ivory,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          color: AppColors.gold,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              restaurant.openDays,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'OPEN TODAY',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            todayHours(restaurant),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.navy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}
