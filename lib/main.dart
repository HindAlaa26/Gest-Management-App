import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/features/auth/sign_in_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gest Management App',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: const SignInScreen(),
    );
  }
}
