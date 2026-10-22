//import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'package:gest_managment_app/core/network/push_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/notification_router.dart';
import 'package:gest_managment_app/features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushService.init();
  //  DevicePreview.enable();
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
      navigatorKey: NotificationRouter.navigatorKey,
      scaffoldMessengerKey: NotificationRouter.messengerKey,
      home: const SplashScreen(),
    );
  }
}
