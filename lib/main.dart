import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'providers/authentication_provider.dart';
import 'services/firebase_auth_service.dart';
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

    // Firebase Auth Service'i başlat / Initialize Firebase Auth Service
    final firebaseAuthService = FirebaseAuthService();
    await firebaseAuthService.initialize();

    // Uygulamayı çalıştır / Run the app
    runApp(const MyApp());
  } catch (e) {
    // Firebase başlatma başarısız: $e / Firebase initialization failed: $e
    // Firebase başarısız olsa bile uygulamayı çalıştır / Run app even if Firebase fails
    runApp(const MyApp());
  }
}

// deneme commit
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Tema sağlayıcı / Theme provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        // Kimlik doğrulama sağlayıcı / Authentication provider
        ChangeNotifierProvider(create: (context) => AuthenticationProvider()),
        // Dil sağlayıcı / Language provider
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
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
          );
        },
      ),
    );
  }
}
