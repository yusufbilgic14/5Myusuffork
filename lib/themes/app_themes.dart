import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Uygulama tema konfigürasyonları / App theme configurations
class AppThemes {
  // Ana renkler / Primary colors (tema bağımsız / theme independent)
  static const Color primaryNavy = Color(0xFF1E3A8A);
  static const Color primaryNavyLight = Color(0xFF3B82F6);

  /// Açık tema / Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Ana renk şeması / Primary color scheme
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        onPrimary: Colors.white,
        secondary: primaryNavyLight,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black87,
        error: Colors.red,
        onError: Colors.white,
      ),

      // AppBar teması / AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: AppConstants.fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Bottom navigation teması / Bottom navigation theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryNavy,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Koyu tema / Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Ana renk şeması / Primary color scheme
      colorScheme: const ColorScheme.dark(
        primary:
            primaryNavyLight, // Koyu temada daha açık mavi / Lighter blue for dark theme
        onPrimary: Colors.white,
        secondary: primaryNavy,
        onSecondary: Colors.white,
        surface: Color(0xFF1E293B), // Koyu gri yüzey / Dark gray surface
        onSurface: Colors.white,
        error: Color(0xFFEF4444), // Daha yumuşak kırmızı / Softer red
        onError: Colors.white,
      ),

      // AppBar teması / AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: AppConstants.fontSizeXLarge,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Bottom navigation teması / Bottom navigation theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E293B),
        selectedItemColor: primaryNavyLight,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Tema-aware renk alıcıları / Theme-aware color getters
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.grey[600]!
        : Colors.grey[400]!;
  }

  /// Gölge stilleri artık AppShadows'tan alınıyor / Shadow styles now come from AppShadows
  static List<BoxShadow> getCardShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppShadows.card
        : AppShadows.elevated;
  }
}
