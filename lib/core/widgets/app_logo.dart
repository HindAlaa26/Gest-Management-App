import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/widgets/logo_mark.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 56,
    this.showText = true,
    this.onDark = true,
  });

  final double height;
  final bool showText;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    if (!showText) {
      return LogoMark(size: height);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LogoMark(size: height),
        const SizedBox(width: 12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GMS',
              style: GoogleFonts.cormorantGaramond(
                fontSize: height * 0.4,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: onDark ? Colors.white : AppColors.navy,
                height: 1,
              ),
            ),
            Text(
              'BY ITECH PRO',
              style: GoogleFonts.inter(
                fontSize: height * 0.16,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: onDark ? AppColors.gold : AppColors.goldDeep,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
