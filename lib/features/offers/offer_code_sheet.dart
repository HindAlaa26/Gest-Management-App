import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gest_managment_app/core/models/offer.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/offer_labels.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';

Future<void> showOfferCodeSheet(
  BuildContext context, {
  required Offer offer,
  required String code,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _OfferCodeSheet(offer: offer, code: code),
  );
}

class _OfferCodeSheet extends StatefulWidget {
  const _OfferCodeSheet({required this.offer, required this.code});

  final Offer offer;
  final String code;

  @override
  State<_OfferCodeSheet> createState() => _OfferCodeSheetState();
}

class _OfferCodeSheetState extends State<_OfferCodeSheet> {
  bool copied = false;

  Future<void> copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() {
      copied = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Show this code to our staff',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 8),
            Text(
              'Present this code to the hotel team to use "${widget.offer.title}".',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.goldLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'YOUR CODE',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.goldDeep,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.code,
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: copy,
                        tooltip: 'Copy code',
                        icon: Icon(
                          copied ? Icons.check : Icons.copy_outlined,
                          color: copied ? AppColors.success : AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                  if (copied)
                    Text(
                      'Code copied',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              validUntilText(widget.offer),
              style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: LoadingButton(
                label: 'Done',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}