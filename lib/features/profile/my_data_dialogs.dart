import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

/// Asks twice before the guest's data is deleted. Returns true only if both are confirmed.
Future<bool> confirmDeleteMyData(BuildContext context) async {
  final first = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete my data?'),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('We will remove your personal data from our records:'),
            SizedBox(height: 8),
            _Bullet('Your name, phone, email, ID numbers and photos'),
            _Bullet(
              'Personal details in your messages, requests, feedback, surveys and loyalty',
            ),
            SizedBox(height: 12),
            Text(
              'Scores, dates and categories stay as anonymous statistics, so we can keep improving our service.',
            ),
            SizedBox(height: 12),
            Text(
              'This cannot be undone. It is completed within 24 hours.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Continue'),
        ),
      ],
    ),
  );
  if (first != true || !context.mounted) return false;

  final second = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Are you absolutely sure?'),
      content: const Text(
        'Your data will be deleted for good and you will not be able to get it back.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Keep my data'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Yes, delete my data'),
        ),
      ],
    ),
  );
  return second == true;
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
