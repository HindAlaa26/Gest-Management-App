import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/theme.dart';

class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key, this.width = 200});

  final double width;

  @override
  Widget build(BuildContext context) {
    final lineWidth = (width - 24) / 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: lineWidth,
          child: const Divider(
            color: AppColors.gold,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Transform.rotate(
            angle: pi / 4,
            child: Container(
              width: 8,
              height: 8,
              color: AppColors.gold,
            ),
          ),
        ),
        SizedBox(
          width: lineWidth,
          child: const Divider(
            color: AppColors.gold,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
