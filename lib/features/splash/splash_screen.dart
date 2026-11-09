import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/features/auth/sign_in_screen.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/features/shell/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    final restored = Session.restore().catchError((_) => false);

    _controller.forward().then((_) async {
      final signedIn = await restored;
      if (!mounted) return;
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder<void>(
            pageBuilder: (_, animation, _) => FadeTransition(
              opacity: animation,
              child: signedIn ? const MainShell() : const SignInScreen(),
            ),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final logoOpacity = CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
        ).value;
        final scale = Tween<double>(begin: 0.92, end: 1.0)
            .chain(CurveTween(curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)))
            .evaluate(_controller);
        final lineWidth = Tween<double>(begin: 0.0, end: 48.0)
            .chain(CurveTween(curve: const Interval(0.4, 0.65)))
            .evaluate(_controller);
        final taglineOpacity = CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
        ).value;
        final footerOpacity = CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
        ).value;

        return Scaffold(
          backgroundColor: AppColors.navy,
          body: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 36,
                child: Opacity(
                  opacity: footerOpacity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'FROM',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          letterSpacing: 3,
                          color: Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ITechPro',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: logoOpacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Image.asset(
                          'assets/images/gms_logo.png',
                          width: 260,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: lineWidth,
                      height: 1,
                      color: AppColors.gold.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 14),
                    Opacity(
                      opacity: taglineOpacity,
                      child: Text(
                        'GUEST EXPERIENCE & SERVICES',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
