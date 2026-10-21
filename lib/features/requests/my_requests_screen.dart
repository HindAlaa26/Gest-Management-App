import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/app_nav.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/widgets/empty_state_card.dart';
import 'package:gest_managment_app/core/widgets/error_retry_card.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';
import 'package:gest_managment_app/core/widgets/loading_view.dart';
import 'package:gest_managment_app/core/widgets/request_summary_card.dart';
import 'package:gest_managment_app/core/widgets/segmented_toggle.dart';
import 'package:gest_managment_app/features/requests/request_details_screen.dart';
import 'package:gest_managment_app/features/requests/requests_screen.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  bool loading = true;
  String? error;
  List<GuestRequest> requests = const [];
  int filterIndex = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (!mounted) return;

    setState(() {
      if (requests.isEmpty) loading = true;
      error = null;
    });

    try {
      final result = await ApiService().getMyRequests();
      if (!mounted) return;
      setState(() {
        requests = result;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Could not load your requests. Please try again.';
        loading = false;
      });
    }
  }

  Future<void> openDetails(GuestRequest request) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDetailsScreen(reference: request.reference),
      ),
    );
    if (!mounted) return;
    await load();
  }

  void makeRequest() {
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppNav.tab.value = 3;
      navigator.push(
        MaterialPageRoute(builder: (_) => const RequestsScreen()),
      );
    });
  }

  List<GuestRequest> get visibleRequests {
    switch (filterIndex) {
      case 1:
        return requests.where((r) => r.status.isActive).toList();
      case 2:
        return requests.where((r) => !r.status.isActive).toList();
      default:
        return requests;
    }
  }

  Widget buildBody() {
    if (loading) {
      return const LoadingView();
    }
    if (error != null) {
      return ErrorRetryCard(message: error!, onRetry: load);
    }
    if (requests.isEmpty) {
      return const EmptyStateCard(
        'No requests yet. When you order amenities, they will appear here.',
      );
    }

    final activeCount = requests.where((r) => r.status.isActive).length;
    final visible = visibleRequests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedToggle(
          labels: [
            'All (${requests.length})',
            'Active ($activeCount)',
            'Past (${requests.length - activeCount})',
          ],
          selectedIndex: filterIndex,
          onChanged: (index) => setState(() => filterIndex = index),
        ),
        const SizedBox(height: 16),
        if (visible.isEmpty)
          const EmptyStateCard('Nothing here')
        else
          for (final request in visible) ...[
            RequestSummaryCard(
              request: request,
              onTap: () => openDetails(request),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
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
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border(
            top: BorderSide(color: AppColors.gold.withValues(alpha: 0.3)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: LoadingButton(
              label: 'Make a request',
              trailingIcon: Icons.add,
              onPressed: makeRequest,
            ),
          ),
        ),
      ),
    );
  }
}
