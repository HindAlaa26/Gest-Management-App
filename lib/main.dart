import 'package:flutter/material.dart';
import 'package:gest_managment_app/screens/sign_in_screen.dart';
import 'package:gest_managment_app/utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GMS Guest',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: const SignInScreen(),
    );
  }
}
