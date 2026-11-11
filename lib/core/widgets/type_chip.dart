import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/event_item.dart';
import 'package:gest_managment_app/core/theme/theme.dart';

class TypeChip extends StatelessWidget {
  const TypeChip({super.key, required this.type, this.label});

  final EventType type;

   final String? label;

  @override
  Widget build(BuildContext context) {
    final isParty = type == EventType.party;
    final isOther = type == EventType.other;
    final text = label ?? (isParty ? 'Party' : 'Event');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOther
            ? AppColors.softGrey
            : (isParty ? AppColors.goldLight : AppColors.tealSoft),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.transparent, width: 0),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: isOther
              ? AppColors.muted
              : (isParty ? AppColors.goldDeep : AppColors.teal),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
