import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 90});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: height * 0.15, vertical: height * 0.15  ),
          decoration: BoxDecoration(
                  border: Border.all(color: AppColors.navySurface, width: 1.5),
                  borderRadius: BorderRadius.circular(18),
                  
                ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: height * 0.50,
                height: height * 0.50,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gold, width: 1.5),
                  borderRadius: BorderRadius.circular(18),
                  
                ),
                alignment: Alignment.center,
                child: Text(
                  'G',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: height * 0.22,
                    color: AppColors.gold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gest Management App',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'by ITechPro',
                    style: TextStyle(
                      fontSize: 8,
                      color: AppColors.goldLight,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
