import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile_model.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('tr');
  final UserProfileService _profileService = UserProfileService();
  
  static const String _languagePreferenceKey = 'languageCode';

  Locale get locale => _locale;

  /// Dil sağlayıcısını başlat / Initialize language provider
  Future<void> initializeLanguage() async {
    await _loadLanguagePreference();
  }

  /// Kaydedilen dil tercihini yükle / Load saved language preference
  Future<void> _loadLanguagePreference() async {
    try {
      // First try to load from Firebase
      final profile = await _profileService.getUserProfile();
      if (profile?.appPreferences != null) {
        _locale = Locale(profile!.appPreferences!.languageCode);
        print('🌐 LanguageProvider: Loaded language from Firebase - code: ${_locale.languageCode}');
      } else {
        // Fallback to SharedPreferences for existing users
        final prefs = await SharedPreferences.getInstance();
        final savedLanguageCode = prefs.getString(_languagePreferenceKey) ?? 'tr';
        _locale = Locale(savedLanguageCode);
        print('🌐 LanguageProvider: Loaded language from SharedPreferences - code: ${_locale.languageCode}');
        
        // Migrate to Firebase if user is authenticated
        if (_profileService.isAuthenticated) {
          await _syncLanguageToFirebase();
        }
      }
      
      notifyListeners();
    } catch (e) {
      // Hata durumunda varsayılan Türkçe dilini kullan / Use default Turkish on error
      print('❌ LanguageProvider: Error loading language preference: $e');
      _locale = const Locale('tr');
    }
  }

  /// Dil tercihini kaydet / Save language preference
  Future<void> _saveLanguagePreference() async {
    try {
      // Save to Firebase if user is authenticated
      if (_profileService.isAuthenticated) {
        await _syncLanguageToFirebase();
      }
      
      // Also save to SharedPreferences as backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languagePreferenceKey, _locale.languageCode);
      
      print('🌐 LanguageProvider: Language preference saved - code: ${_locale.languageCode}');
    } catch (e) {
      print('❌ LanguageProvider: Error saving language preference: $e');
    }
  }

  /// Firebase'e dil tercihini senkronize et / Sync language preference to Firebase
  Future<void> _syncLanguageToFirebase() async {
    try {
      final profile = await _profileService.getUserProfile();
      if (profile != null) {
        final currentPreferences = profile.appPreferences ?? const UserAppPreferences();
        final updatedPreferences = currentPreferences.copyWith(
          languageCode: _locale.languageCode,
        );
        
        await _profileService.updateAppPreferences(updatedPreferences);
        print('🔄 LanguageProvider: Language synced to Firebase');
      }
    } catch (e) {
      print('❌ LanguageProvider: Error syncing language to Firebase: $e');
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!['tr', 'en'].contains(locale.languageCode)) return;
    _locale = locale;
    await _saveLanguagePreference();
    notifyListeners();
  }
}
