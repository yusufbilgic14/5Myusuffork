import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'providers/authentication_provider.dart';
import 'services/firebase_auth_service.dart';
import 'services/cleanup_service.dart';
import 'services/notification_service.dart';
import 'widgets/common/notification_app_wrapper.dart';
import 'screens/login_screen.dart';
import 'constants/app_constants.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'providers/language_provider.dart';
import 'l10n/app_localizations.dart';

/// Ana uygulama başlatma fonksiyonu / Main application startup function
/// Firebase'i başlatır ve uygulamayı çalıştırır / Initializes Firebase and runs the app
void main() async {
  // Flutter widget binding'ini başlat / Initialize Flutter widget binding
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase'i başlat / Initialize Firebase
    // Firebase'i başlat / Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Firebase başarıyla başlatıldı / Firebase initialized successfully
    
    // Firebase App Check'i başlat / Initialize Firebase App Check
    await FirebaseAppCheck.instance.activate(
      // Debug mode için geliştirme ortamında debug token kullan
      // Use debug token in development environment for debug mode
      androidProvider: AndroidProvider.debug,
    );
    print('🔒 Main: Firebase App Check activated with debug provider');

    // Firebase Auth Service'i başlat / Initialize Firebase Auth Service
    final firebaseAuthService = FirebaseAuthService();
    await firebaseAuthService.initialize();
    
    // Setup Firebase Cloud Messaging background message handler
    // Firebase Cloud Messaging arka plan mesaj işleyicisini ayarla
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    print('🔔 Main: FCM background message handler registered');
    
    // Start cleanup service for automatic data maintenance
    final cleanupService = CleanupService();
    cleanupService.startCleanupService();
    print('🧹 Main: Cleanup service started for automatic data maintenance');

    // Uygulamayı çalıştır / Run the app
    runApp(const MyApp());
  } catch (e) {
    // Firebase başlatma başarısız: $e / Firebase initialization failed: $e
    // Firebase başarısız olsa bile uygulamayı çalıştır / Run app even if Firebase fails
    runApp(const MyApp());
  }
}

// deneme commit
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeProvider _themeProvider;
  late LanguageProvider _languageProvider;
  late AuthenticationProvider _authProvider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _themeProvider = ThemeProvider();
    _languageProvider = LanguageProvider();
    _authProvider = AuthenticationProvider();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    try {
      // Initialize providers with Firebase data
      await Future.wait([
        _themeProvider.initializeTheme(),
        _languageProvider.initializeLanguage(),
      ]);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      print('✅ App: Providers initialized successfully');
    } catch (e) {
      print('❌ App: Error initializing providers: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true; // Continue even with errors
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // Show loading screen while initializing
      return MaterialApp(
        title: 'Medipol Üniversitesi',
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    return MultiProvider(
      providers: [
        // Tema sağlayıcı / Theme provider
        ChangeNotifierProvider.value(value: _themeProvider),
        // Kimlik doğrulama sağlayıcı / Authentication provider
        ChangeNotifierProvider.value(value: _authProvider),
        // Dil sağlayıcı / Language provider
        ChangeNotifierProvider.value(value: _languageProvider),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return NotificationAppWrapper(
            child: MaterialApp(
              title:
                  AppLocalizations.of(context)?.appTitle ??
                  'Medipol Üniversitesi',
              theme: themeProvider.currentTheme,
              home: const LoginScreen(),
              debugShowCheckedModeBanner: false,
              color: AppConstants.primaryColor,
              locale: languageProvider.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            ),
          );
        },
      ),
    );
  }
}
