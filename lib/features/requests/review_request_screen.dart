import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/widgets/delivery_room_card.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';
import 'package:gest_managment_app/core/widgets/request_line_row.dart';
import 'package:gest_managment_app/core/widgets/royal_card.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';
import 'package:gest_managment_app/core/widgets/segmented_toggle.dart';
import 'package:gest_managment_app/features/requests/request_sent_screen.dart';

class ReviewRequestScreen extends StatefulWidget {
  const ReviewRequestScreen({
    super.key,
    required this.vendorType,
    required this.lines,
  });

  final VendorType vendorType;
  final List<RequestLine> lines;

  @override
  State<ReviewRequestScreen> createState() => _ReviewRequestScreenState();
}

class _ReviewRequestScreenState extends State<ReviewRequestScreen> {
  static const int maxNoteLength = 300;

  final TextEditingController noteController = TextEditingController();

  int urgencyIndex = 0;
  bool loading = false;
  String? error;

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> sendRequest() async {
    if (loading) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final request = await ApiService().sendRequest(
        vendorType: widget.vendorType,
        urgency: urgencyIndex == 0
            ? RequestUrgency.normal
            : RequestUrgency.urgent,
        lines: widget.lines,
        note: noteController.text.trim(),
      );
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RequestSentScreen(request: request)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not send. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = requestTotal(widget.lines);
    final count = widget.lines.fold<int>(0, (sum, line) => sum + line.qty);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Review & Confirm')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DeliveryRoomCard(),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionLabel('Selected items'),
                  Text(
                    '$count ${count == 1 ? 'item' : 'items'}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RoyalCard(
                child: Column(
                  children: [
                    for (final line in widget.lines) ...[
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
                          formatPrice(total),
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
              const SizedBox(height: 22),
              const SectionLabel('Urgency'),
              const SizedBox(height: 12),
              SegmentedToggle(
                labels: [
                  RequestUrgency.normal.label,
                  RequestUrgency.urgent.label,
                ],
                selectedIndex: urgencyIndex,
                onChanged: (index) => setState(() => urgencyIndex = index),
              ),
              const SizedBox(height: 22),
              const SectionLabel('Note (optional)'),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLength: maxNoteLength,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Add any special instructions',
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
                    borderSide: const BorderSide(
                      color: AppColors.teal,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              LoadingButton(
                label: 'Send request',
                loading: loading,
                onPressed: loading ? null : sendRequest,
                trailingIcon: Icons.arrow_forward,
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
