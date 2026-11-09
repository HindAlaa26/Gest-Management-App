import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:gest_managment_app/core/network/api_client.dart';
import 'package:gest_managment_app/core/network/api_service.dart';
import 'package:gest_managment_app/core/theme/theme.dart';
import 'package:gest_managment_app/core/utils/qr_token.dart';
import 'package:gest_managment_app/features/shell/main_shell.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  bool busy = false;
  String? error;
  String? failedToken;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> onDetect(BarcodeCapture capture) async {
    if (busy) return;

    String? token;
    for (final barcode in capture.barcodes) {
      token = qrTokenFrom(barcode.rawValue ?? '');
      if (token != null) break;
    }
    if (token == null || token == failedToken) return;

    setState(() {
      busy = true;
      error = null;
    });

    try {
      await ApiService().signInWithQr(token);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainShell()),
        (route) => false,
      );
      return;
    } on InvalidCredentialsException {
      failedToken = token;
      error = 'This QR code is not valid or has expired. Please ask the reception for help.';
    } on NetworkException {
      failedToken = token;
      error = 'No connection. Check your internet and try again.';
    } catch (_) {
      failedToken = token;
      error = 'Something went wrong. Please try again.';
    }

    if (mounted) {
      setState(() {
        busy = false;
      });
    }
  }

  void scanAgain() {
    setState(() {
      failedToken = null;
      error = null;
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: controller, onDetect: onDetect),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.gold, width: 2),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (busy)
                    const CircularProgressIndicator(color: AppColors.gold)
                  else if (error != null) ...[
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: scanAgain,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.gold),
                      ),
                      child: const Text('Scan again'),
                    ),
                  ] else
                    Text(
                      'Point the camera at the QR code on your keycard',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
