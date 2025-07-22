import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../models/user_model.dart';
import '../services/authentication_service.dart';
import '../services/firebase_auth_service.dart';

/// Kimlik doğrulama durumu yönetimi için provider / Provider for authentication state management
class AuthenticationProvider extends ChangeNotifier {
  final AuthenticationService _authService = AuthenticationService();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  StreamSubscription<AuthenticationState>? _authSubscription;
  StreamSubscription<FirebaseAuthState>? _firebaseAuthSubscription;

  // Durum değişkenleri / State variables
  bool _isLoading = false;
  bool _isAuthenticated = false;
  AppUser? _currentUser;
  String? _errorMessage;
  bool _isInitialized = false;

  // Getter'lar / Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  AppUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  /// Provider'ı başlat / Initialize provider
  Future<void> initialize() async {
    try {
      // Microsoft OAuth servisini başlat / Initialize Microsoft OAuth service
      await _authService.initialize();

      // Firebase Auth servisini başlat / Initialize Firebase Auth service
      await _firebaseAuthService.initialize();

      // Kimlik doğrulama durumu değişikliklerini dinle
      // Listen to authentication state changes
      _authSubscription = _authService.authStateChanges.listen(
        _handleAuthStateChange,
        onError: _handleAuthError,
      );

      // Firebase kimlik doğrulama durumu değişikliklerini dinle
      // Listen to Firebase authentication state changes
      _firebaseAuthSubscription = _firebaseAuthService.authStateChanges.listen(
        _handleFirebaseAuthStateChange,
        onError: _handleFirebaseAuthError,
      );

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _handleError(
        'Kimlik doğrulama servisi başlatılamadı / Failed to initialize auth service: $e',
      );
    }
  }

  /// Microsoft OAuth ile giriş yap / Sign in with Microsoft OAuth
  Future<bool> signInWithMicrosoft() async {
    try {
      _setLoading(true);
      _clearError();

      // İlk kez kullanılıyorsa initialize et / Initialize if first time use
      if (!_isInitialized) {
        await initialize();
      }

      // Microsoft OAuth girişi başlatılıyor / Starting Microsoft OAuth sign in
      final result = await _authService.signInWithMicrosoft();

      if (result.isSuccess && result.user != null) {
        // Microsoft OAuth başarılı, Firebase ile entegre ediliyor / Microsoft OAuth successful, integrating with Firebase

        // Microsoft OAuth başarılı, şimdi Firebase ile entegre et
        // Microsoft OAuth successful, now integrate with Firebase
        try {
          // Firebase'e Microsoft OAuth bilgileriyle giriş yap
          // Sign in to Firebase with Microsoft OAuth information
          if (_firebaseAuthService.isFirebaseConfigured) {
            // Firebase konfigüre edilmişse entegrasyon dene
            // Try integration if Firebase is configured
            // Microsoft kullanıcı verileri alındı / Microsoft user data retrieved
            await _authService.getDebugInfo();

            // TODO: Gelecekte custom token veya federated auth kullanılacak
            // TODO: Will use custom token or federated auth in the future
            // Firebase entegrasyonu hazırlandı / Firebase integration prepared
          } else {
            // Firebase konfigüre edilmemiş, sadece Microsoft OAuth ile devam et / Firebase not configured, continuing with Microsoft OAuth only
          }
        } catch (firebaseError) {
          // Firebase entegrasyonu başarısız: $firebaseError / Firebase integration failed: $firebaseError
          // Firebase entegrasyonu başarısız olsa bile Microsoft OAuth'la devam et
          // Continue with Microsoft OAuth even if Firebase integration fails
        }

        // AuthenticationState stream zaten durumu güncelleyecek
        // AuthenticationState stream will update the state
        return true;
      } else if (result.isCancelled) {
        _handleInfo('Giriş işlemi iptal edildi / Sign in was cancelled');
        return false;
      } else {
        _handleError(result.errorMessage ?? 'Bilinmeyen hata / Unknown error');
        return false;
      }
    } catch (e) {
      _handleError('Giriş hatası / Sign in error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Çıkış yap / Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _clearError();

      // Çıkış işlemi başlatılıyor / Starting sign out process

      // Microsoft OAuth'dan çıkış yap / Sign out from Microsoft OAuth
      await _authService.signOut();

      // Firebase'den çıkış yap / Sign out from Firebase
      try {
        if (_firebaseAuthService.isFirebaseConfigured) {
          await _firebaseAuthService.signOut();
          // Firebase çıkış işlemi tamamlandı / Firebase sign out completed
        }
      } catch (firebaseError) {
        // Firebase çıkış hatası (devam ediliyor) / Firebase sign out error (continuing): $firebaseError
        // Firebase çıkış hatası olsa bile Microsoft OAuth çıkışıyla devam et
        // Continue with Microsoft OAuth sign out even if Firebase sign out fails
      }

      // Çıkış işlemi tamamlandı / Sign out completed

      // Durum AuthenticationState stream tarafından güncellenecek
      // State will be updated by AuthenticationState stream
    } catch (e) {
      _handleError('Çıkış hatası / Sign out error: $e');
      // Hataya rağmen local durumu temizle / Clear local state despite error
      _setUnauthenticated();
    } finally {
      _setLoading(false);
    }
  }

  /// Token'ı yenile / Refresh token
  Future<bool> refreshToken() async {
    try {
      return await _authService.refreshToken();
    } catch (e) {
      _handleError('Token yenileme hatası / Token refresh error: $e');
      return false;
    }
  }

  /// Kimlik doğrulama durumu değişikliklerini işle / Handle authentication state changes
  void _handleAuthStateChange(AuthenticationState state) {
    if (state == AuthenticationState.loading) {
      _setLoading(true);
    } else if (state.runtimeType.toString().contains('_AuthenticatedState')) {
      // Authenticated state contains user data
      final user = _authService.currentUser;
      if (user != null) {
        _setAuthenticated(user);
      }
    } else if (state == AuthenticationState.unauthenticated) {
      _setUnauthenticated();
    } else if (state.runtimeType.toString().contains('_ErrorState')) {
      // Error state - extract message if possible
      _handleError('Kimlik doğrulama hatası / Authentication error occurred');
    }
  }

  /// Kimlik doğrulama hatalarını işle / Handle authentication errors
  void _handleAuthError(dynamic error) {
    _handleError('Auth stream hatası / Auth stream error: $error');
  }

  /// Firebase kimlik doğrulama durumu değişikliklerini işle / Handle Firebase authentication state changes
  void _handleFirebaseAuthStateChange(FirebaseAuthState state) {
    if (state == FirebaseAuthState.loading) {
      // Firebase loading state handled in combination with MSAL
      // Firebase Auth yükleniyor / Firebase Auth loading state
    } else if (state.runtimeType.toString().contains('_AuthenticatedState')) {
      // Firebase authenticated - this means Microsoft OAuth + Firebase integration successful
      // Firebase Auth: Kullanıcı Firebase'de doğrulandı / Firebase Auth: User authenticated in Firebase
    } else if (state == FirebaseAuthState.unauthenticated) {
      // Firebase Auth: Kullanıcı Firebase'de doğrulanmamış / Firebase Auth: User unauthenticated in Firebase
    } else if (state == FirebaseAuthState.notConfigured) {
      // Firebase Auth: Henüz konfigüre edilmemiş / Firebase Auth: Not configured yet
    } else if (state.runtimeType.toString().contains('_ErrorState')) {
      // Firebase Auth: Hata oluştu / Firebase Auth: Error occurred
    }
    // Firebase state changes complement MSAL state, no need to modify main UI state here
  }

  /// Firebase kimlik doğrulama hatalarını işle / Handle Firebase authentication errors
  void _handleFirebaseAuthError(dynamic error) {
    // Firebase Auth stream hatası / Firebase Auth stream error: $error
    // Firebase errors are logged but don't break the main authentication flow
  }

  /// Kullanıcı giriş yapmış durumuna ayarla / Set user as authenticated
  void _setAuthenticated(AppUser user) {
    _isAuthenticated = true;
    _currentUser = user;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Kullanıcı giriş yapmamış durumuna ayarla / Set user as unauthenticated
  void _setUnauthenticated() {
    _isAuthenticated = false;
    _currentUser = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Yükleme durumunu ayarla / Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Hata mesajını ayarla / Set error message
  void _handleError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  /// Bilgi mesajını işle / Handle info message
  void _handleInfo(String message) {
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
    // İsteğe bağlı olarak info mesajını gösterebilirsiniz
    // Optionally you can show info message
    debugPrint('Auth Info: $message');
  }

  /// Hata mesajını temizle / Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Kullanıcının öğrenci olup olmadığını kontrol et / Check if user is a student
  bool get isStudent => _currentUser?.isStudent ?? false;

  /// Kullanıcının personel olup olmadığını kontrol et / Check if user is staff
  bool get isStaff => _currentUser?.isStaff ?? false;

  /// Kullanıcının tam adını getir / Get user's full name
  String get userFullName => _currentUser?.fullName ?? 'Kullanıcı';

  /// Kullanıcının email adresini getir / Get user's email
  String get userEmail => _currentUser?.primaryEmail ?? '';

  /// Kullanıcının rolünü getir / Get user's role
  String get userRole => _currentUser?.role ?? 'Kullanıcı';

  /// Kullanıcının departmanını getir / Get user's department
  String get userDepartment => _currentUser?.department ?? '';

  /// Debug bilgileri al / Get debug information
  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final authDebugInfo = await _authService.getDebugInfo();
      return {
        'provider': {
          'isLoading': _isLoading,
          'isAuthenticated': _isAuthenticated,
          'isInitialized': _isInitialized,
          'errorMessage': _errorMessage,
          'currentUser': _currentUser?.toString(),
        },
        'service': authDebugInfo,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Provider'ı temizle / Dispose provider
  @override
  void dispose() {
    _authSubscription?.cancel();
    _firebaseAuthSubscription?.cancel();
    _authService.dispose();
    _firebaseAuthService.dispose();
    super.dispose();
  }

  /// Hata durumunu kontrol et / Check error state
  bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

  /// Kullanıcı avatarı için initials getir / Get initials for user avatar
  String get userInitials {
    if (_currentUser?.displayName != null &&
        _currentUser!.displayName.isNotEmpty) {
      final nameParts = _currentUser!.displayName.split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
      } else if (nameParts.isNotEmpty) {
        return nameParts[0][0].toUpperCase();
      }
    }
    return 'U'; // Default user initial
  }

  /// Kullanıcının profil fotoğrafı URL'si / User's profile photo URL
  String? get userProfilePhotoUrl => _currentUser?.profilePhotoUrl;

  /// Kullanıcı bilgilerini yenile / Refresh user information
  Future<void> refreshUserInfo() async {
    if (_isAuthenticated && _currentUser != null) {
      try {
        // Token yenileme işlemini dene / Try to refresh token
        final refreshSuccess = await refreshToken();
        if (refreshSuccess) {
          // Token yenilendi, durumu kontrol et / Token refreshed, check state
          notifyListeners();
        } else {
          // Token yenilenemedi, yeniden giriş gerekli / Cannot refresh token, need to sign in again
          _handleError(
            'Oturum süresi doldu, lütfen yeniden giriş yapın / Session expired, please sign in again',
          );
          await signOut();
        }
      } catch (e) {
        _handleError(
          'Kullanıcı bilgileri yenilenemedi / Failed to refresh user info: $e',
        );
      }
    }
  }
}

/// Kimlik doğrulama durumu kontrol utility'si / Authentication state check utility
class AuthenticationGuard {
  static bool isAuthenticated(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();
    return authProvider.isAuthenticated;
  }

  static bool requiresAuthentication(BuildContext context) {
    return !isAuthenticated(context);
  }

  static AppUser? getCurrentUser(BuildContext context) {
    final authProvider = context.read<AuthenticationProvider>();
    return authProvider.currentUser;
  }
}
