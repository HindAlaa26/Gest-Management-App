import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/restaurant.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/widgets/empty_state_card.dart';
import 'package:gest_managment_app/core/widgets/error_retry_card.dart';
import 'package:gest_managment_app/core/widgets/gold_divider.dart';
import 'package:gest_managment_app/core/widgets/loading_view.dart';
import 'package:gest_managment_app/core/widgets/restaurant_card.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';

class RestaurantsScreen extends StatefulWidget {
  const RestaurantsScreen({super.key});

  @override
  State<RestaurantsScreen> createState() => _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreen> {
  bool _loading = false;
  String? _error;
  List<Restaurant> _restaurants = <Restaurant>[];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final restaurants = await ApiService().getRestaurants();
      if (!mounted) return;
      setState(() {
        _restaurants = restaurants;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Could not load restaurants';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dining'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRestaurants,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const SectionLabel('RESTAURANTS'),
            const SizedBox(height: 10),
            const GoldDivider(width: 220),
            const SizedBox(height: 20),
            if (_loading && _restaurants.isEmpty)
              const LoadingView()
            else if (_error != null && _restaurants.isEmpty)
              ErrorRetryCard(
                message: _error!,
                onRetry: _loadRestaurants,
              )
            else if (_restaurants.isEmpty)
              const EmptyStateCard('No restaurants available')
            else ...[
              for (final restaurant in _restaurants)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: RestaurantCard(restaurant: restaurant),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
