import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.goldDeep,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}
