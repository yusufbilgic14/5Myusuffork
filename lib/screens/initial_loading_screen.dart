import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../widgets/common/medipol_logo_widget.dart';
import '../services/secure_storage_service.dart';
import '../services/firebase_auth_service.dart';
import '../providers/authentication_provider.dart';
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
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    print('🎬 InitialLoadingScreen: initState called');
    
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
    
    print('🎬 InitialLoadingScreen: Animation started, initiating authentication check');

    // Start authentication check after a short delay to allow providers to initialize
    Future.delayed(const Duration(milliseconds: 2000), () async {
      print('🎬 InitialLoadingScreen: Starting authentication check');
      if (mounted && !_hasNavigated) {
        await _performAuthenticationCheck();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🎬 InitialLoadingScreen: didChangeDependencies called');
    
    // Listen to authentication provider changes in real-time
    if (!_hasNavigated) {
      final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
      print('🎬 InitialLoadingScreen: Current auth state - authenticated: ${authProvider.isAuthenticated}, user: ${authProvider.currentUser?.email}');
      
      // If already authenticated, navigate immediately
      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        print('✅ InitialLoadingScreen: User already authenticated, navigating to home');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!_hasNavigated && mounted) {
            _navigateToHome();
          }
        });
      }
    }
  }

  /// Perform comprehensive authentication check
  Future<void> _performAuthenticationCheck() async {
    print('🔍 InitialLoadingScreen: _performAuthenticationCheck called');
    
    try {
      final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
      
      print('🔍 InitialLoadingScreen: AuthProvider state - initialized: ${authProvider.isInitialized}, authenticated: ${authProvider.isAuthenticated}');
      print('🔍 InitialLoadingScreen: AuthProvider currentUser: ${authProvider.currentUser?.email}');
      
      // First check: Is user already authenticated in provider?
      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        print('✅ InitialLoadingScreen: Found existing authenticated session in provider! Navigating to home...');
        print('   User: ${authProvider.currentUser!.email}');
        await _finishAnimationAndNavigate(true);
        return;
      }
      
      // Second check: Wait a bit more for provider to fully initialize and check again
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        print('✅ InitialLoadingScreen: Found authenticated session after delay! Navigating to home...');
        print('   User: ${authProvider.currentUser!.email}');
        await _finishAnimationAndNavigate(true);
        return;
      }
      
      // No authenticated session found, proceed to login
      print('🔐 InitialLoadingScreen: No authenticated session found. Navigating to login...');
      await _finishAnimationAndNavigate(false);
      
    } catch (e) {
      print('❌ InitialLoadingScreen: Error in _performAuthenticationCheck: $e');
      await _finishAnimationAndNavigate(false);
    }
  }

  /// Finish animation and navigate to appropriate screen
  Future<void> _finishAnimationAndNavigate(bool navigateToHome) async {
    if (_hasNavigated || !mounted) return;
    
    try {
      await _controller.reverse();
      if (navigateToHome) {
        _navigateToHome();
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      print('❌ InitialLoadingScreen: Error finishing animation: $e');
      if (navigateToHome) {
        _navigateToHome();
      } else {
        _navigateToLogin();
      }
    }
  }

  /// Navigate to home screen
  void _navigateToHome() {
    print('🏠 InitialLoadingScreen: _navigateToHome called - hasNavigated: $_hasNavigated, mounted: $mounted');
    if (_hasNavigated || !mounted) {
      print('🏠 InitialLoadingScreen: Navigation blocked - hasNavigated: $_hasNavigated, mounted: $mounted');
      return;
    }
    _hasNavigated = true;
    
    print('🏠 InitialLoadingScreen: Navigating to Home Screen...');
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
  }

  /// Navigate to login screen
  void _navigateToLogin() {
    print('🔐 InitialLoadingScreen: _navigateToLogin called - hasNavigated: $_hasNavigated, mounted: $mounted');
    if (_hasNavigated || !mounted) {
      print('🔐 InitialLoadingScreen: Navigation blocked - hasNavigated: $_hasNavigated, mounted: $mounted');
      return;
    }
    _hasNavigated = true;
    
    print('🔐 InitialLoadingScreen: Navigating to Login Screen...');
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


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, child) {
        // Check authentication state on every rebuild
        if (!_hasNavigated && authProvider.isAuthenticated && authProvider.currentUser != null) {
          print('🔄 InitialLoadingScreen: Consumer detected authenticated user: ${authProvider.currentUser?.email}');
          // Schedule navigation for next frame to avoid calling setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_hasNavigated && mounted) {
              print('✅ InitialLoadingScreen: Consumer triggering navigation to home');
              _navigateToHome();
            }
          });
        }
        
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
      },
    );
  }
}
