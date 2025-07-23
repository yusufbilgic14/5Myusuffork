import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Microsoft OAuth token'ları için güvenli depolama servisi / Secure storage service for Microsoft OAuth tokens
class SecureStorageService {
  static const SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  const SecureStorageService._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Storage anahtarları / Storage keys
  static const String _accessTokenKey = 'microsoft_access_token';
  static const String _refreshTokenKey = 'microsoft_refresh_token';
  static const String _idTokenKey = 'microsoft_id_token';
  static const String _userDataKey = 'microsoft_user_data';
  static const String _tokenExpiryKey = 'microsoft_token_expiry';
  static const String _authStateKey = 'auth_state';
  
  // Remember me anahtarları / Remember me keys
  static const String _rememberMeKey = 'remember_me_enabled';
  static const String _rememberedEmailKey = 'remembered_email';
  static const String _rememberedPasswordKey = 'remembered_password';
  static const String _rememberMeAuthTypeKey = 'remember_me_auth_type';

  /// Access token'ı güvenli şekilde sakla / Securely store access token
  Future<void> storeAccessToken(String token) async {
    try {
      await _storage.write(key: _accessTokenKey, value: token);
    } catch (e) {
      throw StorageException(
        'Access token saklanamadı / Failed to store access token: $e',
      );
    }
  }

  /// Access token'ı getir / Get access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      throw StorageException(
        'Access token alınamadı / Failed to get access token: $e',
      );
    }
  }

  /// Refresh token'ı güvenli şekilde sakla / Securely store refresh token
  Future<void> storeRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      throw StorageException(
        'Refresh token saklanamadı / Failed to store refresh token: $e',
      );
    }
  }

  /// Refresh token'ı getir / Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      throw StorageException(
        'Refresh token alınamadı / Failed to get refresh token: $e',
      );
    }
  }

  /// ID token'ı güvenli şekilde sakla / Securely store ID token
  Future<void> storeIdToken(String token) async {
    try {
      await _storage.write(key: _idTokenKey, value: token);
    } catch (e) {
      throw StorageException(
        'ID token saklanamadı / Failed to store ID token: $e',
      );
    }
  }

  /// ID token'ı getir / Get ID token
  Future<String?> getIdToken() async {
    try {
      return await _storage.read(key: _idTokenKey);
    } catch (e) {
      throw StorageException('ID token alınamadı / Failed to get ID token: $e');
    }
  }

  /// Kullanıcı verilerini güvenli şekilde sakla / Securely store user data
  Future<void> storeUserData(Map<String, dynamic> userData) async {
    try {
      final userDataJson = json.encode(userData);
      await _storage.write(key: _userDataKey, value: userDataJson);
    } catch (e) {
      throw StorageException(
        'Kullanıcı verisi saklanamadı / Failed to store user data: $e',
      );
    }
  }

  /// Kullanıcı verilerini getir / Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userDataJson = await _storage.read(key: _userDataKey);
      if (userDataJson != null) {
        return json.decode(userDataJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw StorageException(
        'Kullanıcı verisi alınamadı / Failed to get user data: $e',
      );
    }
  }

  /// Token son kullanma tarihini sakla / Store token expiry time
  Future<void> storeTokenExpiry(DateTime expiryTime) async {
    try {
      await _storage.write(
        key: _tokenExpiryKey,
        value: expiryTime.millisecondsSinceEpoch.toString(),
      );
    } catch (e) {
      throw StorageException(
        'Token süre bilgisi saklanamadı / Failed to store token expiry: $e',
      );
    }
  }

  /// Token son kullanma tarihini getir / Get token expiry time
  Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryString = await _storage.read(key: _tokenExpiryKey);
      if (expiryString != null) {
        final timestamp = int.tryParse(expiryString);
        if (timestamp != null) {
          return DateTime.fromMillisecondsSinceEpoch(timestamp);
        }
      }
      return null;
    } catch (e) {
      throw StorageException(
        'Token süre bilgisi alınamadı / Failed to get token expiry: $e',
      );
    }
  }

  /// Kimlik doğrulama durumunu sakla / Store authentication state
  Future<void> storeAuthState(bool isAuthenticated) async {
    try {
      await _storage.write(
        key: _authStateKey,
        value: isAuthenticated.toString(),
      );
    } catch (e) {
      throw StorageException(
        'Auth durumu saklanamadı / Failed to store auth state: $e',
      );
    }
  }

  /// Kimlik doğrulama durumunu getir / Get authentication state
  Future<bool> getAuthState() async {
    try {
      final authState = await _storage.read(key: _authStateKey);
      return authState == 'true';
    } catch (e) {
      throw StorageException(
        'Auth durumu alınamadı / Failed to get auth state: $e',
      );
    }
  }

  /// Token'ın geçerli olup olmadığını kontrol et / Check if token is valid
  Future<bool> isTokenValid() async {
    try {
      final accessToken = await getAccessToken();
      final expiryTime = await getTokenExpiry();

      if (accessToken == null || expiryTime == null) {
        return false;
      }

      // Token'ın süresi 5 dakika içinde dolarsa yenilenmesi gerekir
      // Token should be refreshed if it expires within 5 minutes
      final now = DateTime.now();
      final fiveMinutesFromNow = now.add(const Duration(minutes: 5));

      return expiryTime.isAfter(fiveMinutesFromNow);
    } catch (e) {
      return false;
    }
  }

  /// Tüm kimlik doğrulama verilerini temizle / Clear all authentication data
  Future<void> clearAllAuthData() async {
    try {
      await Future.wait([
        _storage.delete(key: _accessTokenKey),
        _storage.delete(key: _refreshTokenKey),
        _storage.delete(key: _idTokenKey),
        _storage.delete(key: _userDataKey),
        _storage.delete(key: _tokenExpiryKey),
        _storage.delete(key: _authStateKey),
        // Remember me verilerini de temizle / Also clear remember me data
        _storage.delete(key: _rememberMeKey),
        _storage.delete(key: _rememberedEmailKey),
        _storage.delete(key: _rememberedPasswordKey),
        _storage.delete(key: _rememberMeAuthTypeKey),
      ]);
    } catch (e) {
      throw StorageException(
        'Auth verileri temizlenemedi / Failed to clear auth data: $e',
      );
    }
  }

  /// Tüm token'ları bir arada sakla / Store all tokens together
  Future<void> storeTokenBundle({
    required String accessToken,
    String? refreshToken,
    String? idToken,
    required DateTime expiryTime,
    Map<String, dynamic>? userData,
  }) async {
    try {
      final futures = <Future<void>>[
        storeAccessToken(accessToken),
        storeTokenExpiry(expiryTime),
        storeAuthState(true),
      ];

      if (refreshToken != null) {
        futures.add(storeRefreshToken(refreshToken));
      }

      if (idToken != null) {
        futures.add(storeIdToken(idToken));
      }

      if (userData != null) {
        futures.add(storeUserData(userData));
      }

      await Future.wait(futures);
    } catch (e) {
      throw StorageException(
        'Token paketi saklanamadı / Failed to store token bundle: $e',
      );
    }
  }

  // ==========================================
  // REMEMBER ME FUNCTIONALITY / BENİ HATIRLA İŞLEVSELLİĞİ
  // ==========================================

  /// Remember me durumunu sakla / Store remember me state
  Future<void> storeRememberMe(bool rememberMe) async {
    try {
      await _storage.write(key: _rememberMeKey, value: rememberMe.toString());
    } catch (e) {
      throw StorageException(
        'Beni hatırla durumu saklanamadı / Failed to store remember me state: $e',
      );
    }
  }

  /// Remember me durumunu getir / Get remember me state
  Future<bool> getRememberMe() async {
    try {
      final rememberMe = await _storage.read(key: _rememberMeKey);
      return rememberMe == 'true';
    } catch (e) {
      return false; // Default to false if error occurs
    }
  }

  /// Hatırlanan giriş bilgilerini sakla / Store remembered login credentials
  Future<void> storeRememberedCredentials({
    required String email,
    required String password,
    required String authType, // 'firebase' or 'microsoft'
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _rememberedEmailKey, value: email),
        _storage.write(key: _rememberedPasswordKey, value: password),
        _storage.write(key: _rememberMeAuthTypeKey, value: authType),
        storeRememberMe(true),
      ]);
    } catch (e) {
      throw StorageException(
        'Giriş bilgileri hatırlanamadı / Failed to store remembered credentials: $e',
      );
    }
  }

  /// Hatırlanan giriş bilgilerini getir / Get remembered login credentials
  Future<Map<String, String?>> getRememberedCredentials() async {
    try {
      final isRemembered = await getRememberMe();
      if (!isRemembered) {
        return {'email': null, 'password': null, 'authType': null};
      }

      return {
        'email': await _storage.read(key: _rememberedEmailKey),
        'password': await _storage.read(key: _rememberedPasswordKey),
        'authType': await _storage.read(key: _rememberMeAuthTypeKey),
      };
    } catch (e) {
      return {'email': null, 'password': null, 'authType': null};
    }
  }

  /// Hatırlanan email'i getir / Get remembered email only
  Future<String?> getRememberedEmail() async {
    try {
      final isRemembered = await getRememberMe();
      if (!isRemembered) return null;
      return await _storage.read(key: _rememberedEmailKey);
    } catch (e) {
      return null;
    }
  }

  /// Remember me verilerini temizle / Clear remember me data
  Future<void> clearRememberMeData() async {
    try {
      await Future.wait([
        _storage.delete(key: _rememberMeKey),
        _storage.delete(key: _rememberedEmailKey),
        _storage.delete(key: _rememberedPasswordKey),
        _storage.delete(key: _rememberMeAuthTypeKey),
      ]);
    } catch (e) {
      throw StorageException(
        'Beni hatırla verileri temizlenemedi / Failed to clear remember me data: $e',
      );
    }
  }

  /// Remember me için otomatik giriş yapılabilir mi kontrol et / Check if auto-login is possible for remember me
  Future<bool> canAutoLogin() async {
    try {
      final isRemembered = await getRememberMe();
      if (!isRemembered) return false;

      final credentials = await getRememberedCredentials();
      final authType = credentials['authType'];
      
      if (authType == 'firebase') {
        // Firebase için email/password kontrolü / Email/password check for Firebase
        return credentials['email']?.isNotEmpty == true && 
               credentials['password']?.isNotEmpty == true;
      } else if (authType == 'microsoft') {
        // Microsoft OAuth için token geçerliliği kontrolü / Token validity check for Microsoft OAuth
        return await isTokenValid();
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Microsoft OAuth ile "Remember Me" durumunu ayarla / Set "Remember Me" state for Microsoft OAuth
  Future<void> enableMicrosoftRememberMe() async {
    try {
      await Future.wait([
        storeRememberMe(true),
        _storage.write(key: _rememberMeAuthTypeKey, value: 'microsoft'),
      ]);
    } catch (e) {
      throw StorageException(
        'Microsoft OAuth remember me ayarlanamadı / Failed to set Microsoft OAuth remember me: $e',
      );
    }
  }

  /// Otomatik giriş için geçerli session var mı kontrol et / Check if there's a valid session for auto-login
  Future<bool> hasValidSession() async {
    try {
      final authType = await _storage.read(key: _rememberMeAuthTypeKey);
      final isRemembered = await getRememberMe();
      
      if (!isRemembered) return false;
      
      if (authType == 'microsoft') {
        // Microsoft OAuth token geçerliliği kontrolü / Microsoft OAuth token validity check
        final isValid = await isTokenValid();
        final hasAuthState = await getAuthState();
        return isValid && hasAuthState;
      } else if (authType == 'firebase') {
        // Firebase için credentials kontrolü / Credentials check for Firebase
        final credentials = await getRememberedCredentials();
        return credentials['email']?.isNotEmpty == true && 
               credentials['password']?.isNotEmpty == true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Depolama verilerini kontrol et (debug için) / Check storage data (for debugging)
  Future<Map<String, String?>> getAllStoredData() async {
    try {
      return {
        'accessToken': await getAccessToken() != null ? 'STORED' : null,
        'refreshToken': await getRefreshToken() != null ? 'STORED' : null,
        'idToken': await getIdToken() != null ? 'STORED' : null,
        'userData': await getUserData() != null ? 'STORED' : null,
        'tokenExpiry': (await getTokenExpiry())?.toIso8601String(),
        'authState': (await getAuthState()).toString(),
        'rememberMe': (await getRememberMe()).toString(),
        'rememberedEmail': await getRememberedEmail() != null ? 'STORED' : null,
        'canAutoLogin': (await canAutoLogin()).toString(),
      };
    } catch (e) {
      throw StorageException(
        'Depolama verisi kontrol edilemedi / Failed to check storage data: $e',
      );
    }
  }
}

/// Güvenli depolama servisi için özel hata sınıfı / Custom exception class for secure storage service
class StorageException implements Exception {
  final String message;
  const StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
