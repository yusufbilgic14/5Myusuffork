import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import '../widgets/common/medipol_logo_widget.dart';
import '../services/secure_storage_service.dart';
import '../services/firebase_auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

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
  
  // Services
  final _secureStorage = SecureStorageService();

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

    // 2 saniye sonra otomatik giriş kontrolü veya login ekranına geçiş / After 2 seconds, check auto-login or go to login screen
    Future.delayed(const Duration(seconds: 2), () async {
      await _controller.reverse();
      if (mounted) {
        await _checkAutoLoginAndNavigate();
      }
    });
  }

  /// Otomatik giriş kontrolü ve navigasyon / Check auto-login and navigate
  Future<void> _checkAutoLoginAndNavigate() async {
    try {
      // Remember me durumunu kontrol et / Check remember me state
      final canAutoLogin = await _secureStorage.canAutoLogin();
      
      if (canAutoLogin) {
        // Hatırlanan bilgileri al / Get remembered credentials
        final credentials = await _secureStorage.getRememberedCredentials();
        final email = credentials['email'];
        final password = credentials['password'];
        final authType = credentials['authType'];
        
        if (email != null && password != null && authType == 'firebase') {
          // Firebase ile otomatik giriş yap / Auto-login with Firebase
          debugPrint('🔄 Attempting auto-login with Firebase...');
          final authService = FirebaseAuthService();
          
          if (authService.isFirebaseConfigured) {
            final result = await authService.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            
            if (result.isSuccess && mounted) {
              debugPrint('✅ Auto-login successful! Navigating to home screen...');
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const HomeScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 700),
                ),
              );
              return;
            } else {
              debugPrint('❌ Auto-login failed: ${result.errorMessage}');
              // Başarısız giriş durumunda remember me verilerini temizle / Clear remember me data on failed login
              await _secureStorage.clearRememberMeData();
            }
          }
        }
      }
      
      // Otomatik giriş başarısız veya mümkün değil, login ekranına git / Auto-login failed or not possible, go to login screen
      debugPrint('📱 Navigating to login screen...');
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
    } catch (e) {
      debugPrint('❌ Auto-login error: $e');
      // Hata durumunda da login ekranına git / Go to login screen on error
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
    }
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
