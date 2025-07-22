import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../themes/app_themes.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile_model.dart';

/// Tema yöneticisi provider / Theme manager provider
class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme = AppThemes.lightTheme;
  bool _isDarkMode = false;
  final UserProfileService _profileService = UserProfileService();

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
      // First try to load from Firebase
      final profile = await _profileService.getUserProfile();
      if (profile?.appPreferences != null) {
        _isDarkMode = profile!.appPreferences!.isDarkMode;
        print('🎨 ThemeProvider: Loaded theme from Firebase - isDark: $_isDarkMode');
      } else {
        // Fallback to SharedPreferences for existing users
        final prefs = await SharedPreferences.getInstance();
        _isDarkMode = prefs.getBool(_themePreferenceKey) ?? false;
        print('🎨 ThemeProvider: Loaded theme from SharedPreferences - isDark: $_isDarkMode');
        
        // Migrate to Firebase if user is authenticated
        if (_profileService.isAuthenticated) {
          await _syncThemeToFirebase();
        }
      }
      
      _currentTheme = _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;
      notifyListeners();
    } catch (e) {
      // Hata durumunda varsayılan açık temayı kullan / Use default light theme on error
      print('❌ ThemeProvider: Error loading theme preference: $e');
      _isDarkMode = false;
      _currentTheme = AppThemes.lightTheme;
    }
  }

  /// Tema tercihini kaydet / Save theme preference
  Future<void> _saveThemePreference() async {
    try {
      // Save to Firebase if user is authenticated
      if (_profileService.isAuthenticated) {
        await _syncThemeToFirebase();
      }
      
      // Also save to SharedPreferences as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, _isDarkMode);
      
      print('🎨 ThemeProvider: Theme preference saved - isDark: $_isDarkMode');
    } catch (e) {
      // Kaydetme hatası - kullanıcıya bildirilecek / Save error - will notify user
      print('❌ ThemeProvider: Error saving theme preference: $e');
    }
  }

  /// Firebase'e tema tercihini senkronize et / Sync theme preference to Firebase
  Future<void> _syncThemeToFirebase() async {
    try {
      final profile = await _profileService.getUserProfile();
      if (profile != null) {
        final currentPreferences = profile.appPreferences ?? const UserAppPreferences();
        final updatedPreferences = currentPreferences.copyWith(
          isDarkMode: _isDarkMode,
        );
        
        await _profileService.updateAppPreferences(updatedPreferences);
        print('🔄 ThemeProvider: Theme synced to Firebase');
      }
    } catch (e) {
      print('❌ ThemeProvider: Error syncing theme to Firebase: $e');
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
