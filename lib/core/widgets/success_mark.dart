import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

class SuccessMark extends StatelessWidget {
  const SuccessMark({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.tealSoft,
      ),
      child: Center(
        child: Container(
          width: size * 0.62,
          height: size * 0.62,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.teal,
          ),
          child: Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: size * 0.4,
          ),
        ),
      ),
    );
  }
}
