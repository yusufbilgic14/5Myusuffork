import 'package:msal_auth/msal_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import '../models/user_model.dart';
import 'secure_storage_service.dart';

/// Microsoft OAuth kimlik doğrulama servisi (MSAL tabanlı) / Microsoft OAuth authentication service (MSAL-based)
class AuthenticationService {
  // Singleton pattern implementation
  static final AuthenticationService _instance =
      AuthenticationService._internal();
  factory AuthenticationService() => _instance;
  AuthenticationService._internal();

  // MSAL instance / MSAL örneği
  SingleAccountPca? _msalApp;

  // Secure storage service instance / Güvenli depolama servisi
  final SecureStorageService _storage = SecureStorageService();

  // Stream controller for authentication state / Kimlik doğrulama durumu için stream controller
  final StreamController<AuthenticationState> _authStateController =
      StreamController<AuthenticationState>.broadcast();

  // Current user / Mevcut kullanıcı
  AppUser? _currentUser;

  // Initialization status / Başlatma durumu
  bool _isInitialized = false;

  // Rate limiting / Oran sınırlama
  DateTime? _lastLoginAttempt;
  int _consecutiveFailures = 0;
  static const int _maxConsecutiveFailures = 3;
  static const Duration _rateLimitDelay = Duration(seconds: 30);

  // MSAL Configuration / MSAL Konfigürasyonu
  static const String _clientId = '68351acb-be70-4759-bfd4-fbf8fa03f064';
  static const String _tenantId = '928e7780-98fd-42c3-831e-d63f2773c094';

  // Authentication state stream / Kimlik doğrulama durumu stream'i
  Stream<AuthenticationState> get authStateChanges =>
      _authStateController.stream;

  // Authentication status / Kimlik doğrulama durumu
  bool get isAuthenticated => _currentUser != null;

  /// MSAL servisini başlat / Initialize MSAL service
  Future<void> initialize() async {
    try {
      if (_isInitialized) return; // Zaten başlatılmışsa / Already initialized

      print('🔧 AuthenticationService: Initializing MSAL service...');

      // MSAL uygulamasını oluştur / Create MSAL application
      _msalApp = await SingleAccountPca.create(
        clientId: _clientId,
        androidConfig: AndroidConfig(
          configFilePath: 'assets/msal_config.json',
          redirectUri:
              'msauth://com.example.medipolapp/3ZLW/TAqPvR43Zh79ejFQDOdka8=',
        ),
        appleConfig: AppleConfig(
          authority: 'https://login.microsoftonline.com/$_tenantId',
          authorityType: AuthorityType.aad,
          broker: Broker
              .msAuthenticator, // Microsoft Authenticator kullan / Use Microsoft Authenticator
        ),
      );

      // Uygulama başladığında kimlik doğrulama durumunu kontrol et
      // Check authentication state when app starts
      await _checkAuthenticationState();

      _isInitialized = true;
      print('✅ AuthenticationService: MSAL service initialized successfully');
    } catch (e) {
      print('❌ AuthenticationService: Failed to initialize - $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Mevcut kullanıcı / Current user
  AppUser? get currentUser => _currentUser;

  /// Kullanıcının giriş yapıp yapmadığını kontrol et / Check if user is signed in
  Future<bool> get isSignedIn async {
    try {
      final isAuthenticated = await _storage.getAuthState();
      final hasValidToken = await _storage.isTokenValid();
      return isAuthenticated && hasValidToken;
    } catch (e) {
      return false;
    }
  }

  /// Rate limiting kontrolü / Rate limiting check
  bool _isRateLimited() {
    if (_lastLoginAttempt == null) return false;

    final timeSinceLastAttempt = DateTime.now().difference(_lastLoginAttempt!);
    final shouldDelay =
        _consecutiveFailures >= _maxConsecutiveFailures &&
        timeSinceLastAttempt < _rateLimitDelay;

    if (shouldDelay) {
      final remainingSeconds =
          _rateLimitDelay.inSeconds - timeSinceLastAttempt.inSeconds;
      print('⏰ Rate limited: Wait $remainingSeconds more seconds');
    }

    return shouldDelay;
  }

  /// Clear all cached data / Tüm önbelleğe alınmış verileri temizle
  Future<void> _clearAllCachedData() async {
    try {
      print('🧹 Clearing all cached authentication data...');
      await _storage.clearAllAuthData();
      _currentUser = null;
      _consecutiveFailures = 0;
      print('✅ All cached data cleared successfully');
    } catch (e) {
      print('❌ Failed to clear cached data: $e');
    }
  }

  /// Microsoft OAuth ile giriş yap / Sign in with Microsoft OAuth
  Future<AuthenticationResult> signInWithMicrosoft() async {
    try {
      // Rate limiting kontrolü / Rate limiting check
      if (_isRateLimited()) {
        final remainingSeconds =
            _rateLimitDelay.inSeconds -
            DateTime.now().difference(_lastLoginAttempt!).inSeconds;
        return AuthenticationResult.error(
          'Çok fazla başarısız deneme. $remainingSeconds saniye bekleyin. / Too many failed attempts. Wait $remainingSeconds seconds.',
        );
      }

      // İlk kez kullanılıyorsa initialize et / Initialize if first time use
      if (!_isInitialized) {
        await initialize();
      }

      if (_msalApp == null) {
        throw AuthenticationException(
          'MSAL app not initialized / MSAL uygulaması başlatılmadı',
        );
      }

      print('🚀 Starting Microsoft OAuth login...');
      _lastLoginAttempt = DateTime.now();
      _emitAuthState(AuthenticationState.loading);

      // Önce mevcut token'ları ve MSAL hesabını temizle / Clear existing tokens and MSAL account first
      await _clearAllCachedData();

      // MSAL hesabını da temizle / Also clear MSAL account
      try {
        print('🔄 Signing out any existing MSAL account...');
        await _msalApp!.signOut();
        print('✅ MSAL account cleared');
      } catch (e) {
        print(
          '⚠️ Warning: Could not sign out existing account (may not exist): $e',
        );
        // Continue with authentication even if signout fails
      }

      // MSAL ile giriş yap / Sign in with MSAL
      print('🔐 Initiating MSAL authentication...');
      final authResult = await _msalApp!.acquireToken(
        scopes: [
          'https://graph.microsoft.com/User.Read',
          'openid',
          'profile',
          'email',
        ],
        prompt: Prompt
            .login, // Kullanıcıdan her zaman giriş istenmesini sağlar / Always prompt for login
      );

      if (authResult.accessToken.isNotEmpty) {
        print('✅ MSAL authentication successful, processing tokens...');

        // Token süresini hesapla / Calculate token expiry
        final expiryTime =
            authResult.expiresOn ??
            DateTime.now().add(const Duration(hours: 1));

        // Token'ları güvenli depolama alanına kaydet / Save tokens to secure storage
        await _storage.storeAccessToken(authResult.accessToken);
        await _storage.storeTokenExpiry(expiryTime);

        // ID token varsa kaydet / Store ID token if available
        if (authResult.idToken != null && authResult.idToken!.isNotEmpty) {
          await _storage.storeIdToken(authResult.idToken!);
        }

        // Kullanıcı bilgilerini Microsoft Graph API'den al / Get user info from Microsoft Graph API
        final userInfoData = await _getUserInfo(authResult.accessToken);
        if (userInfoData != null) {
          final userInfo = AppUser.fromJson(userInfoData);
          _currentUser = userInfo;
          await _storage.storeUserData(userInfoData);
          await _storage.storeAuthState(true);

          // Başarılı giriş / Successful login
          _consecutiveFailures = 0;
          _emitAuthState(AuthenticationState.authenticated(userInfo));

          print(
            '🎉 Microsoft OAuth login completed successfully for user: ${userInfo.displayName}',
          );
          return AuthenticationResult.success(userInfo);
        } else {
          throw AuthenticationException(
            'Kullanıcı bilgileri alınamadı / Failed to get user info',
          );
        }
      } else {
        // Giriş başarısız / Login failed
        print('⏹️ MSAL authentication returned empty token');
        _emitAuthState(AuthenticationState.unauthenticated);
        return AuthenticationResult.error('Giriş başarısız / Login failed');
      }
    } on MsalException catch (e) {
      print('❌ MSAL Exception: ${e.toString()}');

      // MSAL özel hata türlerini kontrol et / Check MSAL specific error types
      if (e.toString().contains('user_cancelled') ||
          e.toString().contains('cancelled')) {
        print('⏹️ User cancelled MSAL login');
        _emitAuthState(AuthenticationState.unauthenticated);
        return AuthenticationResult.cancelled();
      } else {
        _consecutiveFailures++;
        String errorMessage =
            'MSAL Hatası: ${e.toString()} / MSAL Error: ${e.toString()}';
        _emitAuthState(AuthenticationState.error(errorMessage));
        return AuthenticationResult.error(errorMessage);
      }
    } catch (e) {
      _consecutiveFailures++;
      print(
        '❌ Microsoft OAuth login failed (attempt $_consecutiveFailures): $e',
      );

      String errorMessage = 'Giriş hatası / Login error';

      // Özel hata mesajları / Custom error messages
      if (e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        errorMessage =
            'Ağ bağlantısı hatası. İnternet bağlantınızı kontrol edin. / Network error. Check your internet connection.';
      } else if (e.toString().contains('cancelled') ||
          e.toString().contains('user_cancelled')) {
        errorMessage = 'Giriş işlemi iptal edildi / Login was cancelled';
        _consecutiveFailures--; // Don't count cancellations as failures
      }

      _emitAuthState(AuthenticationState.error(errorMessage));
      return AuthenticationResult.error(errorMessage);
    }
  }

  /// Çıkış yap / Sign out
  Future<void> signOut() async {
    try {
      _emitAuthState(AuthenticationState.loading);

      // MSAL çıkışı / MSAL logout
      if (_msalApp != null) {
        try {
          await _msalApp!.signOut();
          print('✅ MSAL sign out completed');
        } catch (e) {
          print('⚠️ MSAL sign out warning: $e');
          // Continue with local cleanup even if MSAL logout fails
        }
      }

      // Güvenli depolamadaki tüm verileri temizle / Clear all data from secure storage
      await _storage.clearAllAuthData();

      _currentUser = null;
      _emitAuthState(AuthenticationState.unauthenticated);
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
      // Çıkış hatası olsa bile kullanıcıyı çıkar / Sign out user even if there's an error
      await _storage.clearAllAuthData();
      _currentUser = null;
      _emitAuthState(AuthenticationState.unauthenticated);
    }
  }

  /// Token'ı yenile / Refresh token
  Future<bool> refreshToken() async {
    try {
      if (_msalApp == null) {
        return false;
      }

      print('🔄 Attempting to refresh token...');

      // Silent token acquisition / Sessiz token alımı
      final authResult = await _msalApp!.acquireTokenSilent(
        scopes: [
          'https://graph.microsoft.com/User.Read',
          'openid',
          'profile',
          'email',
        ],
      );

      if (authResult.accessToken.isNotEmpty) {
        // Token süresini hesapla / Calculate token expiry
        final expiryTime =
            authResult.expiresOn ??
            DateTime.now().add(const Duration(hours: 1));

        // Yeni token'ları sakla / Store new tokens
        await _storage.storeAccessToken(authResult.accessToken);
        await _storage.storeTokenExpiry(expiryTime);

        if (authResult.idToken != null && authResult.idToken!.isNotEmpty) {
          await _storage.storeIdToken(authResult.idToken!);
        }

        print('✅ Token refreshed successfully');
        return true;
      }

      return false;
    } on MsalException catch (e) {
      if (e.toString().contains('ui_required') ||
          e.toString().contains('interaction_required')) {
        print('🔄 UI required for token refresh: ${e.toString()}');
        return false; // Interactive login required
      }
      print('❌ Token refresh failed with MSAL error: ${e.toString()}');
      return false;
    } catch (e) {
      print('❌ Token refresh failed: $e');
      return false;
    }
  }

  /// Microsoft Graph API'den kullanıcı bilgilerini al / Get user info from Microsoft Graph API
  Future<Map<String, dynamic>?> _getUserInfo(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://graph.microsoft.com/v1.0/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw AuthenticationException(
          'Kullanıcı bilgileri alınamadı / Failed to get user info: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Microsoft Graph API error: $e');
      return null;
    }
  }

  /// Kimlik doğrulama durumunu kontrol et / Check authentication state
  Future<void> _checkAuthenticationState() async {
    try {
      _emitAuthState(AuthenticationState.loading);

      final isAuthenticated = await isSignedIn;

      if (isAuthenticated) {
        // Kullanıcı bilgilerini yükle / Load user information
        final userData = await _storage.getUserData();
        if (userData != null) {
          _currentUser = AppUser.fromJson(userData);
          _emitAuthState(AuthenticationState.authenticated(_currentUser!));
          return;
        }
      }

      _emitAuthState(AuthenticationState.unauthenticated);
    } catch (e) {
      print('❌ Authentication state check failed: $e');
      _emitAuthState(AuthenticationState.error(e.toString()));
    }
  }

  /// Kimlik doğrulama durumunu yayınla / Emit authentication state
  void _emitAuthState(AuthenticationState state) {
    _authStateController.add(state);
  }

  /// Servisi temizle / Dispose service
  void dispose() {
    _authStateController.close();
  }

  /// Debug bilgileri al / Get debug information
  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final storageData = await _storage.getAllStoredData();
      return {
        'isSignedIn': await isSignedIn,
        'currentUser': _currentUser?.toString(),
        'storage': storageData,
        'config': {'clientId': _clientId, 'tenantId': _tenantId},
        'isInitialized': _isInitialized,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}

/// Kimlik doğrulama durumu sınıfı / Authentication state class
abstract class AuthenticationState {
  const AuthenticationState();

  static const AuthenticationState loading = _LoadingState();
  static const AuthenticationState unauthenticated = _UnauthenticatedState();

  static AuthenticationState authenticated(AppUser user) =>
      _AuthenticatedState(user);
  static AuthenticationState error(String message) => _ErrorState(message);
}

class _LoadingState extends AuthenticationState {
  const _LoadingState();
}

class _UnauthenticatedState extends AuthenticationState {
  const _UnauthenticatedState();
}

class _AuthenticatedState extends AuthenticationState {
  final AppUser user;
  const _AuthenticatedState(this.user);
}

class _ErrorState extends AuthenticationState {
  final String message;
  const _ErrorState(this.message);
}

/// Kimlik doğrulama sonucu sınıfı / Authentication result class
class AuthenticationResult {
  final bool isSuccess;
  final AppUser? user;
  final String? errorMessage;
  final bool isCancelled;

  const AuthenticationResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
    this.isCancelled = false,
  });

  static AuthenticationResult success(AppUser user) =>
      AuthenticationResult._(isSuccess: true, user: user);

  static AuthenticationResult error(String message) =>
      AuthenticationResult._(isSuccess: false, errorMessage: message);

  static AuthenticationResult cancelled() =>
      AuthenticationResult._(isSuccess: false, isCancelled: true);
}

/// Kimlik doğrulama hata sınıfı / Authentication exception class
class AuthenticationException implements Exception {
  final String message;
  const AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}
