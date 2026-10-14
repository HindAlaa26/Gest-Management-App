import 'package:flutter/material.dart';

import '../utils/theme.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            color: AppColors.gold,
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}
