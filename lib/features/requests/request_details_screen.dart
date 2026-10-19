import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/widgets/error_retry_card.dart';
import 'package:gest_managment_app/core/widgets/info_row.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';
import 'package:gest_managment_app/core/widgets/loading_view.dart';
import 'package:gest_managment_app/core/widgets/request_line_row.dart';
import 'package:gest_managment_app/core/widgets/request_status_badge.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';
import 'package:gest_managment_app/core/widgets/star_rating.dart';
import 'package:gest_managment_app/core/widgets/status_timeline.dart';
import 'package:gest_managment_app/core/widgets/urgent_tag.dart';
import 'package:gest_managment_app/features/requests/cancel_request_sheet.dart';
import 'package:gest_managment_app/features/requests/change_request_screen.dart';

class RequestDetailsScreen extends StatefulWidget {
  const RequestDetailsScreen({super.key, required this.reference});

  final String reference;

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  static const Map<RequestStatus, String> captions = {
    RequestStatus.newRequest: 'Request received',
    RequestStatus.assigned: 'Assigned to our team',
    RequestStatus.inProgress: 'Being prepared',
    RequestStatus.done: 'Delivered',
  };

  final TextEditingController commentController = TextEditingController();

  GuestRequest? request;
  bool loading = true;
  String? error;
  int stars = 0;
  bool submitting = false;
  String? ratingError;

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    if (!mounted) return;

    setState(() {
      if (request == null) loading = true;
      error = null;
    });

    try {
      final result = await ApiService().getRequest(widget.reference);
      if (!mounted) return;
      setState(() {
        request = result;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Could not load this request. Please try again.';
        loading = false;
      });
    }
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> openChange(GuestRequest current) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ChangeRequestScreen(request: current)),
    );
    if (!mounted) return;
    if (changed == true) {
      await load();
      if (!mounted) return;
      showMessage('Request updated');
    }
  }

  Future<void> openCancel(GuestRequest current) async {
    final cancelled = await showCancelRequestSheet(context, current);
    if (!mounted) return;
    if (cancelled == true) {
      await load();
      if (!mounted) return;
      showMessage('Request cancelled');
    }
  }

  Future<void> submitRating() async {
    if (stars == 0 || submitting) return;

    setState(() {
      submitting = true;
      ratingError = null;
    });

    try {
      final updated = await ApiService().rateRequest(
        reference: widget.reference,
        stars: stars,
        comment: commentController.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        request = updated;
        submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        submitting = false;
        ratingError = 'Could not send your rating. Please try again.';
      });
    }
  }

  List<TimelineStep> buildSteps(GuestRequest r) {
    const flow = [
      RequestStatus.newRequest,
      RequestStatus.assigned,
      RequestStatus.inProgress,
      RequestStatus.done,
    ];
    final currentIndex = flow.indexOf(r.status);
    final cancelled = r.status == RequestStatus.cancelled;
    final steps = <TimelineStep>[];

    for (var i = 0; i < flow.length; i++) {
      final status = flow[i];
      final at = r.reachedAt(status);

      if (cancelled) {
        if (at == null) continue;
        steps.add(
          TimelineStep(
            title: status.label,
            caption: captions[status] ?? '',
            state: TimelineStepState.reached,
            time: formatRequestTime(at),
          ),
        );
        continue;
      }

      final TimelineStepState state;
      if (i < currentIndex ||
          (i == currentIndex && r.status == RequestStatus.done)) {
        state = TimelineStepState.reached;
      } else if (i == currentIndex) {
        state = TimelineStepState.current;
      } else {
        state = TimelineStepState.pending;
      }

      steps.add(
        TimelineStep(
          title: status.label,
          caption: captions[status] ?? '',
          state: state,
          time: state == TimelineStepState.pending || at == null
              ? null
              : formatRequestTime(at),
        ),
      );
    }

    if (cancelled) {
      final at = r.reachedAt(RequestStatus.cancelled);
      steps.add(
        TimelineStep(
          title: 'Cancelled',
          caption: r.cancelReason ?? '',
          state: TimelineStepState.cancelled,
          time: at == null ? null : formatRequestTime(at),
        ),
      );
    }

    return steps;
  }

  List<Widget> buildRatingSection(GuestRequest r) {
    final textTheme = Theme.of(context).textTheme;
    final rating = r.rating;

    if (rating != null) {
      return [
        const SizedBox(height: 22),
        RoyalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Your rating'),
              const SizedBox(height: 8),
              StarRating(value: rating.stars, size: 28),
              if (rating.comment.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  rating.comment,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.navy),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Thanks for your rating',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ];
    }

    if (r.canRate) {
      return [
        const SizedBox(height: 22),
        RoyalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionLabel('Rate this request'),
              const SizedBox(height: 8),
              Center(
                child: StarRating(
                  value: stars,
                  onChanged: (value) => setState(() => stars = value),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You can rate within 24 hours of completion.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                maxLength: 300,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add a comment (optional)',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              LoadingButton(
                label: 'Submit rating',
                loading: submitting,
                onPressed: stars == 0 ? null : submitRating,
              ),
              if (ratingError != null) ...[
                const SizedBox(height: 10),
                Text(
                  ratingError!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ],
            ],
          ),
        ),
      ];
    }

    if (r.status == RequestStatus.done) {
      return [
        const SizedBox(height: 16),
        Text(
          'The rating period has ended.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ];
    }

    return const [];
  }

  List<Widget> buildActions(GuestRequest r) {
    final textTheme = Theme.of(context).textTheme;

    if (r.canChange || r.canCancel) {
      return [
        const SizedBox(height: 24),
        if (r.canChange)
          OutlinedButton(
            onPressed: () => openChange(r),
            child: const Text('Change request'),
          ),
        if (r.canChange && r.canCancel) const SizedBox(height: 8),
        if (r.canCancel)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => openCancel(r),
            child: const Text('Cancel request'),
          ),
      ];
    }

    if (r.status == RequestStatus.inProgress) {
      return [
        const SizedBox(height: 20),
        Text(
          'This request is being handled and can no longer be changed.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
      ];
    }

    return const [];
  }

  Widget buildBody(GuestRequest r) {
    final textTheme = Theme.of(context).textTheme;
    final room = Session.currentStay?.roomNumber;
    final count = r.lines.fold<int>(0, (sum, line) => sum + line.qty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          r.reference,
          style: textTheme.headlineMedium?.copyWith(color: AppColors.navy),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            RequestStatusBadge(status: r.status),
            if (r.urgency == RequestUrgency.urgent) const UrgentTag(),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Requested ${formatRequestTime(r.createdAt)}${room == null ? '' : ' · Room $room'}',
          style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 22),
        const SectionLabel('Status timeline'),
        const SizedBox(height: 12),
        RoyalCard(child: StatusTimeline(steps: buildSteps(r))),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionLabel('Items requested'),
            Text(
              '$count ${count == 1 ? 'item' : 'items'}',
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RoyalCard(
          child: Column(
            children: [
              for (final line in r.lines) ...[
                RequestLineRow(line: line),
                const Divider(height: 24),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total charged to room',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    formatPrice(requestTotal(r.lines)),
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.navy,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        RoyalCard(
          child: Column(
            children: [
              InfoRow(
                icon: Icons.bolt_outlined,
                label: 'Urgency',
                text: r.urgency.label,
              ),
              if (r.note.isNotEmpty) ...[
                const SizedBox(height: 14),
                InfoRow(
                  icon: Icons.sticky_note_2_outlined,
                  label: 'Note',
                  text: r.note,
                ),
              ],
            ],
          ),
        ),
        ...buildRatingSection(r),
        ...buildActions(r),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = request;

    Widget body;
    if (loading) {
      body = const LoadingView();
    } else if (error != null || current == null) {
      body = ErrorRetryCard(
        message: error ?? 'Could not load this request. Please try again.',
        onRetry: load,
      );
    } else {
      body = buildBody(current);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Request Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: body,
        ),
      ),
    );
  }
}
