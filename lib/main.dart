import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'themes/app_themes.dart';
import 'screens/initial_loading_screen.dart';

void main() {
  runApp(const MedipolApp());
}

class MedipolApp extends StatelessWidget {
  const MedipolApp({super.key});

  // Uygulamanın ana widget'ı / Main application widget
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider()..initializeTheme(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Medipol Üniversitesi',
            debugShowCheckedModeBanner: false, // Debug banner'ını kaldır / Remove debug banner
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const InitialLoadingScreen(), // Yükleme ekranından başla / Start with loading screen
          );
        },
      ),
    );
  }
}
