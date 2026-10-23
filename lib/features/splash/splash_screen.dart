import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/widgets/app_logo_icon.dart';
import 'package:gest_managment_app/features/auth/sign_in_screen.dart';

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
      duration: const Duration(milliseconds: 3000),
    );

    _controller.forward().then((_) {
      if (!mounted) return;
      Future<void>.delayed(const Duration(milliseconds: 450), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder<void>(
            pageBuilder: (_, animation, _) => FadeTransition(
              opacity: animation,
              child: const SignInScreen(),
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
        final emblemOpacity = CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
        ).value;
        final ringOpacity = CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.10, 0.55, curve: Curves.easeOut),
        ).value;
        final titleOpacity = CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
        ).value;
        final titleOffset = Tween<Offset>(
          begin: const Offset(0, 14),
          end: Offset.zero,
        ).chain(CurveTween(curve: const Interval(0.35, 0.65, curve: Curves.easeOut))).evaluate(_controller);
        final lineWidth = Tween<double>(begin: 0.0, end: 48.0)
            .chain(CurveTween(curve: const Interval(0.55, 0.78)))
            .evaluate(_controller);
        final taglineOpacity = CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.65, 0.88, curve: Curves.easeOut),
        ).value;
        final footerOpacity = CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.80, 1.0, curve: Curves.easeOut),
        ).value;
        final scale = Tween<double>(begin: 0.88, end: 1.0)
            .chain(CurveTween(curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic)))
            .evaluate(_controller);
        final dotRotation = _controller.value * 2 * math.pi * 0.35;

        return Scaffold(
          backgroundColor: AppColors.navyDeep,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.navySurface, AppColors.navyDeep],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 0.7,
                          colors: [
                            AppColors.gold.withValues(alpha: 0.08),
                            AppColors.navySurface.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
                        opacity: emblemOpacity,
                        child: Transform.scale(
                          scale: scale,
                          child: SizedBox(
                            width: 220,
                            height: 220,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                               
                                Opacity(
                                  opacity: ringOpacity,
                                  child: Transform.rotate(
                                    angle: dotRotation,
                                    child: CustomPaint(
                                      size: const Size(110, 110),
                                      painter: _DotRingPainter(),
                                    ),
                                  ),
                                ),
                                const AppLogoIcon(size: 112),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Opacity(
                        opacity: titleOpacity,
                        child: Transform.translate(
                          offset: titleOffset,
                          child: Text(
                            'GMS Guest',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Opacity(
                        opacity: 1.0,
                        child: Container(
                          width: lineWidth,
                          height: 1,
                          color: AppColors.gold.withValues(alpha: 0.7),
                        ),
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
          ),
        );
      },
    );
  }
}

class _DotRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = 92.0 / 2;
    const dotCount = 60;
    const dotRadius = 1.6;

    for (var i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * math.pi;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      final dot = Paint()..color = AppColors.gold.withValues(alpha: 0.55);
      canvas.drawCircle(Offset(x, y), dotRadius, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
