import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

class IconCircle extends StatelessWidget {
  const IconCircle({
    super.key,
    required this.icon,
    this.size = 48,
    this.iconSize = 24,
    this.background = AppColors.goldLight,
    this.color = AppColors.goldDeep,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: background),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}
