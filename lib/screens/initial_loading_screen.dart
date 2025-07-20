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

class _InitialLoadingScreenState extends State<InitialLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();

    // 2 saniye sonra login ekranına geçişte fade-out animasyonu
    Future.delayed(const Duration(seconds: 2), () async {
      await _controller.reverse();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 700),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Logo ortada animasyonlu
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const MedipolLogoWidget(
                  size: 150,
                  isRounded: true,
                  showFallbackText: true,
                ),
              ),
            ),
          ),
          // Alt copyright metni
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
