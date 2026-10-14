import 'package:flutter/material.dart';

import '../utils/theme.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.gold,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}
