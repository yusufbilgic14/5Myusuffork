import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/authentication_provider.dart';
import 'screens/login_screen.dart';
import 'constants/app_constants.dart';

void main() {
  runApp(const MyApp());
}

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
