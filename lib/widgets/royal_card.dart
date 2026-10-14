import 'package:flutter/material.dart';

import '../utils/theme.dart';

class RoyalCard extends StatelessWidget {
  const RoyalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.dark = false,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.navySurface : AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: card,
      ),
    );
  }
}
