import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gest_managment_app/core/models/data_request.dart';
import 'package:gest_managment_app/core/models/guest_stay.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/helpers.dart';
import 'package:gest_managment_app/core/widgets/data_request_card.dart';
import 'package:gest_managment_app/core/widgets/error_retry_card.dart';
import 'package:gest_managment_app/core/widgets/icon_circle.dart';
import 'package:gest_managment_app/core/widgets/loading_view.dart';
import 'package:gest_managment_app/core/widgets/more_tile.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';
import 'package:gest_managment_app/features/profile/my_data_dialogs.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  bool sending = false;
  String? error;
  List<DataRequest> requests = const [];

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
      final result = await ApiService().getDataRequests();
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

  bool hasActive(DataRequestType type) {
    return requests.any((r) => r.type == type && r.isActive);
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> requestCopy() async {
    if (sending) return;
    if (hasActive(DataRequestType.export)) {
      showMessage('Your copy is already being prepared.');
      return;
    }

    setState(() {
      sending = true;
    });
    try {
      await ApiService().requestDataExport();
      if (!mounted) return;
      showMessage("Request received. We'll show your copy here when it is ready.");
      await load();
    } on DataRequestInProgressException {
      if (!mounted) return;
      showMessage('Your copy is already being prepared.');
      await load();
    } catch (_) {
      if (!mounted) return;
      showMessage('Could not send your request. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          sending = false;
        });
      }
    }
  }

  Future<void> requestDeletion() async {
    if (sending) return;
    if (hasActive(DataRequestType.delete)) {
      showMessage('Your deletion request is already in progress.');
      return;
    }

    final confirmed = await confirmDeleteMyData(context);
    if (!confirmed || !mounted) return;

    setState(() {
      sending = true;
    });
    try {
      await ApiService().requestDataDeletion();
      if (!mounted) return;
      showMessage("Request received. We'll delete your data within 24 hours.");
      await load();
    } on DataRequestInProgressException {
      if (!mounted) return;
      showMessage('Your deletion request is already in progress.');
      await load();
    } catch (_) {
      if (!mounted) return;
      showMessage('Could not send your request. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          sending = false;
        });
      }
    }
  }

  Future<void> copyLink(DataRequest request) async {
    final url = request.downloadUrl;
    if (url == null) return;

    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    showMessage('Download link copied.');
  }

  Widget buildGuestCard(GuestStay stay) {
    final textTheme = Theme.of(context).textTheme;

    return RoyalCard(
      dark: true,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconCircle(
            icon: Icons.person_outline,
            size: 56,
            iconSize: 28,
            background: AppColors.gold.withValues(alpha: 0.18),
            color: AppColors.gold,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stay.guestName,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.card,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Room ${stay.roomNumber} · Check-out ${formatDay(stay.checkout)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.card.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRequests() {
    if (loading) {
      return const LoadingView();
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 24),
        child: ErrorRetryCard(message: error!, onRetry: load),
      );
    }
    if (requests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SectionLabel('My requests'),
        const SizedBox(height: 12),
        for (final request in requests) ...[
          DataRequestCard(
            request: request,
            onCopyLink: request.canDownload ? () => copyLink(request) : null,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stay = Session.currentStay;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.teal,
          onRefresh: load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              if (sending)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(color: AppColors.teal),
                ),
              if (stay != null) buildGuestCard(stay),
              const SizedBox(height: 24),
              const SectionLabel('My data'),
              const SizedBox(height: 8),
              Text(
                'You decide what we keep. Ask for a copy of your data, or ask us to delete it.',
                style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              MoreTile(
                icon: Icons.download_outlined,
                title: 'Get a copy of my data',
                subtitle: 'A file with everything we keep about you',
                onTap: requestCopy,
              ),
              const SizedBox(height: 14),
              MoreTile(
                icon: Icons.delete_outline,
                title: 'Delete my data',
                subtitle: 'Remove your personal data from our records',
                destructive: true,
                onTap: requestDeletion,
              ),
              buildRequests(),
            ],
          ),
        ),
      ),
    );
  }
}
