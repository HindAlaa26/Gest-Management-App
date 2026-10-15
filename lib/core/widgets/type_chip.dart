import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/models/event_item.dart';
import 'package:gest_managment_app/core/theme/theme.dart';

class TypeChip extends StatelessWidget {
  const TypeChip({
    super.key,
    required this.type,
  });

  final EventType type;

  @override
  Widget build(BuildContext context) {
    final isParty = type == EventType.party;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isParty ? AppColors.goldLight : AppColors.tealSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.transparent,
          width: 0,
        ),
      ),
      child: Text(
        isParty ? 'Party' : 'Event',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: isParty ? AppColors.goldDeep : AppColors.teal,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
