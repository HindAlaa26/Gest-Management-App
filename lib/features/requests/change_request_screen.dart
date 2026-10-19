import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/request_labels.dart';
import 'package:gest_managment_app/core/widgets/catalogue_item_card.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';
import 'package:gest_managment_app/core/widgets/section_label.dart';
import 'package:gest_managment_app/core/widgets/segmented_toggle.dart';

class ChangeRequestScreen extends StatefulWidget {
  const ChangeRequestScreen({super.key, required this.request});

  final GuestRequest request;

  @override
  State<ChangeRequestScreen> createState() => _ChangeRequestScreenState();
}

class _ChangeRequestScreenState extends State<ChangeRequestScreen> {
  late final Map<String, int> quantities = {
    for (final line in widget.request.lines) line.item.id: line.qty,
  };
  late int urgencyIndex =
      widget.request.urgency == RequestUrgency.urgent ? 1 : 0;

  bool loading = false;
  String? error;

  List<RequestLine> get lines => [
        for (final line in widget.request.lines)
          if ((quantities[line.item.id] ?? 0) > 0)
            RequestLine(item: line.item, qty: quantities[line.item.id]!),
      ];

  RequestUrgency get urgency =>
      urgencyIndex == 1 ? RequestUrgency.urgent : RequestUrgency.normal;

  bool get hasChanges {
    if (urgency != widget.request.urgency) return true;
    for (final line in widget.request.lines) {
      if ((quantities[line.item.id] ?? 0) != line.qty) return true;
    }
    return false;
  }

  Future<void> save() async {
    if (loading) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await ApiService().changeRequest(
        reference: widget.request.reference,
        lines: lines,
        urgency: urgency,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not save changes. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final room = Session.currentStay?.roomNumber;
    final selected = lines;
    final canSave = selected.isNotEmpty && hasChanges;

    return Scaffold(
      appBar: AppBar(title: const Text('Change Request')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.tealSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Modifying ${widget.request.reference}${room == null ? '' : ' · Room $room'}',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Change quantities or urgency. To add other types of items, make a new request.',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              const SectionLabel('Requested amenities'),
              const SizedBox(height: 12),
              for (final line in widget.request.lines) ...[
                CatalogueItemCard(
                  item: line.item,
                  qty: quantities[line.item.id] ?? 0,
                  onChanged: (value) {
                    setState(() {
                      quantities[line.item.id] = value;
                      error = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 10),
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
              if (error != null) ...[
                const SizedBox(height: 14),
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total ${formatPrice(requestTotal(selected))}',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Charged to room',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: LoadingButton(
                    label: 'Save changes',
                    loading: loading,
                    onPressed: canSave ? save : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
