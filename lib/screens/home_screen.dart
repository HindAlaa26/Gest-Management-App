import 'package:flutter/material.dart';

import '../network/api_service.dart';
import '../screens/sign_in_screen.dart';
import '../utils/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String monthName(int month) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month];
  }

  @override
  Widget build(BuildContext context) {
    final stay = Session.currentStay;

    if (stay == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: const Center(
          child: Text('No guest signed in.'),
        ),
      );
    }

    final checkout = stay.checkout;
    final checkoutText = '${checkout.day} ${monthName(checkout.month)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${stay.guestName}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Room ${stay.roomNumber}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check-out $checkoutText',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Session.currentStay = null;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const SignInScreen()),
                  );
                },
                icon: const Icon(Icons.logout_outlined),
                label: const Text('Sign out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
