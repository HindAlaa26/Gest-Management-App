import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gest_managment_app/core/theme/theme.dart';

class AppLogoIcon extends StatelessWidget {
  const AppLogoIcon({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navySurface, AppColors.navyDeep],
        ),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.7),
          width: 1.2,
        ),
        boxShadow: size >= 40
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        'G',
        style: GoogleFonts.cormorantGaramond(
          fontSize: size * 0.6,
          fontWeight: FontWeight.w700,
          color: AppColors.gold,
          height: 1.0,
        ),
      ),
    );
  }
}
