import 'package:flutter/material.dart';

import '../models/event_item.dart';
import '../utils/theme.dart';

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
        color: isParty ? AppColors.goldLight : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isParty ? AppColors.gold : AppColors.navy,
          width: 1.2,
        ),
      ),
      child: Text(
        isParty ? 'Party' : 'Event',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: isParty ? AppColors.navy : AppColors.navy,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
