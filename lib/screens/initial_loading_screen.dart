import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import '../widgets/common/medipol_logo_widget.dart';
import 'login_screen.dart';

class InitialLoadingScreen extends StatefulWidget {
  const InitialLoadingScreen({super.key});

  @override
  State<InitialLoadingScreen> createState() => _InitialLoadingScreenState();
}

class _InitialLoadingScreenState extends State<InitialLoadingScreen> {
  @override
  void initState() {
    super.initState();
    // 3 saniye sonra login ekranına geç / Navigate to login screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Logo ortada / Logo in center
          const Center(
            child: MedipolLogoWidget(
              size: 150,
              isRounded: true,
              showFallbackText: true,
            ),
          ),

          // Alt copyright metni / Bottom copyright text
          Positioned(
            bottom: AppConstants.paddingXLarge + 6,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Copyrighted 2025® Tüm Hakları Saklıdır',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: AppConstants.fontSizeSmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
