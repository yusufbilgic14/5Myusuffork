import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_themes.dart';

/// Tema yöneticisi provider / Theme manager provider
class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = AppThemes.lightTheme;
  bool _isDarkMode = false;
  
  static const String _themePreferenceKey = 'isDarkMode';
  
  ThemeData get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;
  
  /// Tema sağlayıcısını başlat / Initialize theme provider
  Future<void> initializeTheme() async {
    await _loadThemePreference();
  }
  
  /// Kaydedilen tema tercihini yükle / Load saved theme preference
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themePreferenceKey) ?? false;
      _currentTheme = _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;
      notifyListeners();
    } catch (e) {
      // Hata durumunda varsayılan açık temayı kullan / Use default light theme on error
      _isDarkMode = false;
      _currentTheme = AppThemes.lightTheme;
    }
  }
  
  /// Tema tercihini kaydet / Save theme preference
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, _isDarkMode);
    } catch (e) {
      // Kaydetme hatası - kullanıcıya bildirilecek / Save error - will notify user
      debugPrint('Tema tercihi kaydedilemedi: $e');
    }
  }
  
  /// Temayı değiştir / Toggle theme
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _currentTheme = _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;
    
    await _saveThemePreference();
    notifyListeners();
  }
  
  /// Belirli bir temayı ayarla / Set specific theme
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      _currentTheme = _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;
      
      await _saveThemePreference();
      notifyListeners();
    }
  }
  
  /// Tema durumunu kontrol et / Check theme status
  String get currentThemeName => _isDarkMode ? 'Koyu Tema' : 'Açık Tema';
  
  /// Tema ikonu al / Get theme icon
  IconData get themeIcon => _isDarkMode ? Icons.light_mode : Icons.dark_mode;
} 