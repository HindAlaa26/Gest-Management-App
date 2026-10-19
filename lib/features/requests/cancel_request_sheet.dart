import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/guest_request.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';

const List<String> cancelReasons = [
  'Changed my mind',
  'Ordered by mistake',
  'Taking too long',
  'Other',
];

Future<bool?> showCancelRequestSheet(
  BuildContext context,
  GuestRequest request,
) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _CancelRequestSheet(request: request),
  );
}

class _CancelRequestSheet extends StatefulWidget {
  const _CancelRequestSheet({required this.request});

  final GuestRequest request;

  @override
  State<_CancelRequestSheet> createState() => _CancelRequestSheetState();
}

class _CancelRequestSheetState extends State<_CancelRequestSheet> {
  String? selected;
  bool loading = false;
  String? error;

  Future<void> cancel() async {
    final reason = selected;
    if (reason == null || loading) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await ApiService().cancelRequest(
        reference: widget.request.reference,
        reason: reason,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not cancel. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cancel this request?',
              style: textTheme.titleLarge?.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 6),
            Text(
              'Please tell us why you wish to cancel ${widget.request.reference}. This action cannot be undone.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            for (final reason in cancelReasons) ...[
              _ReasonTile(
                label: reason,
                selected: selected == reason,
                onTap: loading ? null : () => setState(() => selected = reason),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: selected == null || loading ? null : cancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
              ),
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Cancel request'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: loading ? null : () => Navigator.of(context).pop(false),
              child: const Text('Keep request'),
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
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.tealSoft : AppColors.ivory,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.teal : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppColors.teal : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}
