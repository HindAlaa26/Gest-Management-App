import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/data/demo_data.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/widgets/app_logo.dart';
import 'package:gest_managment_app/core/widgets/custom_text_field.dart';
import 'package:gest_managment_app/core/widgets/loading_button.dart';
import 'package:gest_managment_app/features/shell/main_shell.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController roomController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  bool loading = false;
  String? error;

  @override
  void dispose() {
    roomController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  void clearError() {
    if (error != null && mounted) {
      setState(() {
        error = null;
      });
    }
  }

  Future<void> signIn() async {
    final room = roomController.text.trim();
    final lastName = lastNameController.text.trim();

    if (room.isEmpty || lastName.isEmpty) {
      setState(() {
        error = 'Please enter your room number and last name';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final stay = await ApiService().signIn(room, lastName);
      if (!mounted) return;
      Session.currentStay = stay;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainShell()),
      );
    } on InvalidCredentialsException {
      if (!mounted) return;
      setState(() {
        error = 'Room number or last name is incorrect';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    Center(child: AppLogo(height: 64, onDark: true)),
                    const SizedBox(height: 16),
                    Text(
                      demoHotelName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 62, height: 1, color: AppColors.gold),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Transform.rotate(
                            angle: 0.7,
                            child: Container(
                              width: 8,
                              height: 8,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        Container(width: 62, height: 1, color: AppColors.gold),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                        decoration: const BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Welcome',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppColors.navy,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sign in to your stay',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 26),
                            buildField(
                              label: 'Room number',
                              context: context,
                              clearError: clearError,
                              hint: 'e.g. 305',
                              controller: roomController,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              icon: Icons.meeting_room_outlined,
                              hintText: '305',
                            ),
                            const SizedBox(height: 18),
                            buildField(
                              label: 'Last name',
                              context: context,
                              clearError: clearError,
                              hint: 'As on your booking',
                              controller: lastNameController,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.done,
                              icon: Icons.badge_outlined,
                              hintText: 'Smith',

                              onSubmitted: (_) => signIn(),
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 24),
                            LoadingButton(
                              label: 'Sign in',
                              onPressed: loading ? null : signIn,
                              loading: loading,
                             
                            ),
                            const SizedBox(height: 12),
                            if (error != null)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      color: AppColors.error, size: 16),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      error!,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: Container(height: 1, color: AppColors.muted.withAlpha(120))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'OR',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: AppColors.muted,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                                Expanded(child: Container(height: 1, color: AppColors.muted.withAlpha(120))),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 56,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('QR sign-in is coming soon'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.qr_code_scanner, color: AppColors.gold),
                                label: const Text('Scan keycard QR code'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.navy,
                                  side: const BorderSide(color: AppColors.gold, width: 1.2),
                                  backgroundColor: AppColors.card,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

 
}

