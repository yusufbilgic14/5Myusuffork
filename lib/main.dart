import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'providers/authentication_provider.dart';
import 'screens/login_screen.dart';
import 'screens/initial_loading_screen.dart';
import 'constants/app_constants.dart';

/// Ana uygulama başlatma fonksiyonu / Main application startup function
/// Firebase'i başlatır ve uygulamayı çalıştırır / Initializes Firebase and runs the app
void main() async {
  // Flutter widget binding'ini başlat / Initialize Flutter widget binding
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Firebase'i başlat / Initialize Firebase
    print('🔥 Firebase initialization starting...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
    
    // Uygulamayı çalıştır / Run the app
    runApp(const MyApp());
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
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
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        // Kimlik doğrulama sağlayıcı / Authentication provider
        ChangeNotifierProvider(
          create: (context) => AuthenticationProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Medipol Üniversitesi',
            theme: themeProvider.currentTheme,
            home: const LoginScreen(),
            debugShowCheckedModeBanner: false,
            // Genel renkler / Global colors
            color: AppConstants.primaryColor,
          );
        },
      ),
    );
  }
}
