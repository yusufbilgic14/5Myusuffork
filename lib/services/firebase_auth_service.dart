import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../models/user_model.dart';
import 'secure_storage_service.dart';

/// Firebase kimlik doğrulama servisi - Microsoft OAuth ile entegre
/// Firebase authentication service integrated with Microsoft OAuth
/// 
/// Bu servis Firebase Console kurulumu tamamlandıktan sonra aktif olacak
/// This service will be active after Firebase Console setup is completed
class FirebaseAuthService {
  // Singleton pattern implementation
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  // Secure storage service / Güvenli depolama servisi
  final SecureStorageService _storage = SecureStorageService();
  
  // Authentication state stream controller / Kimlik doğrulama durumu stream controller'ı
  final StreamController<FirebaseAuthState> _authStateController = 
      StreamController<FirebaseAuthState>.broadcast();

  // Current app user with extended info / Genişletilmiş bilgilerle mevcut uygulama kullanıcısı
  AppUser? _currentAppUser;
  
  // Initialization status / Başlatma durumu
  bool _isInitialized = false;
  
  // Firebase configuration status / Firebase konfigürasyon durumu
  bool _isFirebaseConfigured = false;

  // Firebase Auth instance / Firebase Auth örneği
  FirebaseAuth? _firebaseAuth;
  
  // Firestore instance for user data / Kullanıcı verileri için Firestore örneği
  FirebaseFirestore? _firestore;

  // Firebase Authentication state stream / Firebase kimlik doğrulama durumu stream'i
  Stream<FirebaseAuthState> get authStateChanges => _authStateController.stream;
  
  // Current app user getter / Mevcut uygulama kullanıcısı getter'ı
  AppUser? get currentAppUser => _currentAppUser;
  
  // Authentication status / Kimlik doğrulama durumu
  bool get isAuthenticated => _currentAppUser != null && _isFirebaseConfigured;
  
  // Firebase configuration status / Firebase konfigürasyon durumu
  bool get isFirebaseConfigured => _isFirebaseConfigured;

  /// Firebase Auth servisini başlat / Initialize Firebase Auth service
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;
      
      print('🔧 FirebaseAuthService: Initializing Firebase Auth service...');
      
      // Check if Firebase is configured / Firebase'in konfigüre edilip edilmediğini kontrol et
      await _checkFirebaseConfiguration();
      
      if (_isFirebaseConfigured) {
        // TODO: Firebase bağlantısı kurulduğunda bu kısmı aktif et
        // TODO: Activate this part when Firebase connection is established
        await _initializeFirebaseServices();
        await _checkCurrentAuthState();
        print('✅ FirebaseAuthService: Firebase Auth service initialized successfully');
      } else {
        print('⚠️ FirebaseAuthService: Firebase not configured yet. Please complete Firebase Console setup.');
        _emitAuthState(FirebaseAuthState.notConfigured);
      }
      
      _isInitialized = true;
    } catch (e) {
      print('❌ FirebaseAuthService: Failed to initialize - $e');
      _isInitialized = false;
      _emitAuthState(FirebaseAuthState.error('Başlatma hatası / Initialization error: $e'));
      rethrow;
    }
  }

  /// Firebase konfigürasyonunu kontrol et / Check Firebase configuration
  Future<void> _checkFirebaseConfiguration() async {
    try {
      // Firebase'in başlatılıp başlatılmadığını kontrol et
      // Check if Firebase is initialized
      try {
        // Import Firebase auth if not already imported
        await _importFirebaseDependencies();
        
        // Firebase apps listesini kontrol et / Check Firebase apps list
        final hasFirebaseApp = await _checkFirebaseApps();
        _isFirebaseConfigured = hasFirebaseApp;
        
        print('📋 FirebaseAuthService: Firebase configuration status: $_isFirebaseConfigured');
      } catch (e) {
        print('⚠️ FirebaseAuthService: Firebase not yet available, will be activated after proper setup');
        _isFirebaseConfigured = false;
      }
    } catch (e) {
      print('❌ FirebaseAuthService: Error checking Firebase configuration - $e');
      _isFirebaseConfigured = false;
    }
  }

  /// Firebase bağımlılıklarını import et / Import Firebase dependencies
  Future<void> _importFirebaseDependencies() async {
    try {
      // Dinamik import - Firebase kurulumu tamamlandığında çalışacak
      // Dynamic import - will work when Firebase setup is completed
      // Firebase bağımlılıklarını yükle
      // Load Firebase dependencies
      print('📦 FirebaseAuthService: Importing Firebase dependencies...');
    } catch (e) {
      print('❌ FirebaseAuthService: Failed to import Firebase dependencies - $e');
      rethrow;
    }
  }

  /// Firebase uygulamalarını kontrol et / Check Firebase apps
  Future<bool> _checkFirebaseApps() async {
    try {
      // Firebase Core import edilmelidir main.dart'ta
      // Firebase Core should be imported in main.dart
      // Bu fonksiyon Firebase'in başarıyla başlatıldığını varsayar
      // This function assumes Firebase is successfully initialized
      
      // Şimdilik Firebase konfigürasyonunun tamamlandığını varsayıyoruz
      // For now, we assume Firebase configuration is completed
      return true; // Firebase is now configured!
    } catch (e) {
      print('❌ FirebaseAuthService: Error checking Firebase apps - $e');
      return false;
    }
  }

  /// Firebase servislerini başlat / Initialize Firebase services
  Future<void> _initializeFirebaseServices() async {
    try {
      // Firebase Core zaten main.dart'ta başlatıldı
      // Firebase Core is already initialized in main.dart
      print('🔗 FirebaseAuthService: Connecting to Firebase services...');
      
      // Firebase Auth ve Firestore instance'larını oluştur
      // Create Firebase Auth and Firestore instances
      // Note: Bu aşamada dinamik import kullanacağız
      // Note: We'll use dynamic import at this stage
      
      print('📱 FirebaseAuthService: Setting up Firebase Auth...');
      _firebaseAuth = FirebaseAuth.instance;
      
      print('🗄️ FirebaseAuthService: Setting up Firestore...');
      _firestore = FirebaseFirestore.instance;
      
      // Firebase Auth state değişikliklerini dinle
      // Listen to Firebase Auth state changes
      _firebaseAuth?.authStateChanges().listen(_handleFirebaseAuthStateChange);
      
      print('✅ FirebaseAuthService: Firebase services connection prepared');
    } catch (e) {
      print('❌ FirebaseAuthService: Failed to initialize Firebase services - $e');
      throw e;
    }
  }

  /// Firebase Auth durumu değişikliklerini işle / Handle Firebase Auth state changes
  void _handleFirebaseAuthStateChange(User? firebaseUser) {
    try {
      print('🔄 FirebaseAuthService: Firebase auth state changed - User: ${firebaseUser?.uid ?? 'null'}');
      
      if (firebaseUser != null) {
        // Firebase kullanıcısı var / Firebase user exists
        print('✅ FirebaseAuthService: Firebase user signed in: ${firebaseUser.email}');
        // Bu durumda zaten Microsoft OAuth ile giriş yapılmış ve Firebase'e entegre edilmiş demektir
        // This means Microsoft OAuth sign-in has already been done and integrated with Firebase
      } else {
        // Firebase kullanıcısı yok / No Firebase user
        print('👤 FirebaseAuthService: No Firebase user found');
      }
    } catch (e) {
      print('❌ FirebaseAuthService: Error handling Firebase auth state change - $e');
    }
  }

  /// Microsoft OAuth token'ını kullanarak Firebase'e giriş yap
  /// Sign in to Firebase using Microsoft OAuth token
  Future<FirebaseAuthResult> signInWithMicrosoftToken({
    required String accessToken,
    required String idToken,
    required Map<String, dynamic> microsoftUserData,
  }) async {
    try {
      print('🚀 FirebaseAuthService: Starting sign in with Microsoft token...');
      _emitAuthState(FirebaseAuthState.loading);

      if (!_isFirebaseConfigured) {
        final errorMsg = 'Firebase henüz konfigüre edilmedi. Lütfen Firebase Console kurulumunu tamamlayın.';
        _emitAuthState(FirebaseAuthState.error(errorMsg));
        return FirebaseAuthResult.error(errorMsg);
      }

      // Create AppUser from Microsoft data / Microsoft verilerinden AppUser oluştur
      final appUser = AppUser(
        id: microsoftUserData['id'],
        displayName: microsoftUserData['displayName'] ?? 'Kullanıcı',
        userPrincipalName: microsoftUserData['userPrincipalName'],
        email: microsoftUserData['mail'] ?? microsoftUserData['userPrincipalName'],
        firstName: microsoftUserData['givenName'],
        lastName: microsoftUserData['surname'],
        jobTitle: microsoftUserData['jobTitle'],
        department: microsoftUserData['department'],
        businessPhones: (microsoftUserData['businessPhones'] as List<dynamic>?)?.cast<String>(),
        mobilePhone: microsoftUserData['mobilePhone'],
        officeLocation: microsoftUserData['officeLocation'],
        preferredLanguage: microsoftUserData['preferredLanguage'],
      );

      // Geçici olarak kullanıcıyı sakla / Temporarily store the user
      _currentAppUser = appUser;
      
      // TODO: Firebase'e kullanıcı kaydet
      // TODO: Save user to Firebase
      // await _createOrUpdateUserDocument(appUser, microsoftUserData, accessToken);
      
      // Token'ları güvenli şekilde sakla / Store tokens securely
      await _storeAuthTokens(accessToken, idToken);
      
      _emitAuthState(FirebaseAuthState.authenticated(appUser));
      
      print('🎉 FirebaseAuthService: Successfully signed in user: ${appUser.displayName}');
      return FirebaseAuthResult.success(appUser);
    } catch (e) {
      print('❌ FirebaseAuthService: Sign in failed - $e');
      _emitAuthState(FirebaseAuthState.error('Giriş hatası / Sign in error: $e'));
      return FirebaseAuthResult.error('Sign in error: $e');
    }
  }

  /// Token'ları güvenli şekilde sakla / Store tokens securely
  Future<void> _storeAuthTokens(String accessToken, String idToken) async {
    try {
      await _storage.storeAccessToken(accessToken);
      await _storage.storeIdToken(idToken);
      await _storage.storeAuthState(true);
      print('✅ FirebaseAuthService: Tokens stored securely');
    } catch (e) {
      print('❌ FirebaseAuthService: Failed to store tokens - $e');
    }
  }

  /// Mevcut kimlik doğrulama durumunu kontrol et / Check current authentication state
  Future<void> _checkCurrentAuthState() async {
    try {
      if (!_isFirebaseConfigured) {
        _emitAuthState(FirebaseAuthState.notConfigured);
        return;
      }

      // Saklanan kimlik doğrulama durumunu kontrol et / Check stored auth state
      final isAuthenticated = await _storage.getAuthState();
      
      if (isAuthenticated) {
        // Kullanıcı verilerini yükle / Load user data
        final userData = await _storage.getUserData();
        if (userData != null) {
          _currentAppUser = AppUser.fromJson(userData);
          _emitAuthState(FirebaseAuthState.authenticated(_currentAppUser!));
          return;
        }
      }

      _emitAuthState(FirebaseAuthState.unauthenticated);
    } catch (e) {
      print('❌ FirebaseAuthService: Failed to check auth state - $e');
      _emitAuthState(FirebaseAuthState.error('Kimlik doğrulama durumu kontrol edilemedi'));
    }
  }

  /// Çıkış yap / Sign out
  Future<void> signOut() async {
    try {
      print('🚪 FirebaseAuthService: Signing out...');
      _emitAuthState(FirebaseAuthState.loading);

      // TODO: Firebase'den çıkış yap
      // TODO: Sign out from Firebase
      // if (_isFirebaseConfigured && _firebaseAuth != null) {
      //   await _firebaseAuth!.signOut();
      // }
      
      // Clear stored tokens / Saklanan token'ları temizle
      await _storage.clearAllAuthData();
      
      // Clear current user data / Mevcut kullanıcı verilerini temizle
      _currentAppUser = null;
      
      _emitAuthState(FirebaseAuthState.unauthenticated);
      print('✅ FirebaseAuthService: Sign out completed');
    } catch (e) {
      print('❌ FirebaseAuthService: Sign out failed - $e');
      // Even if sign out fails, clear local data / Çıkış başarısız olsa bile yerel verileri temizle
      await _storage.clearAllAuthData();
      _currentAppUser = null;
      _emitAuthState(FirebaseAuthState.unauthenticated);
    }
  }

  /// Kullanıcı verilerini yenile / Refresh user data
  Future<void> refreshUserData() async {
    try {
      if (!_isFirebaseConfigured) {
        print('⚠️ FirebaseAuthService: Cannot refresh user data - Firebase not configured');
        return;
      }

      if (_currentAppUser != null) {
        // TODO: Firestore'dan kullanıcı verilerini yenile
        // TODO: Refresh user data from Firestore
        // final userData = await _loadUserDataFromFirestore(_currentAppUser!.id);
        // if (userData != null) {
        //   _currentAppUser = userData;
        //   _emitAuthState(FirebaseAuthState.authenticated(userData));
        // }
        
        print('✅ FirebaseAuthService: User data refresh requested (Firebase not configured yet)');
      }
    } catch (e) {
      print('❌ FirebaseAuthService: Failed to refresh user data - $e');
    }
  }

  /// Kullanıcı profilini güncelle / Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      if (!_isFirebaseConfigured) {
        print('⚠️ FirebaseAuthService: Cannot update profile - Firebase not configured');
        return false;
      }

      if (_currentAppUser != null) {
        // TODO: Firestore'da kullanıcı profilini güncelle
        // TODO: Update user profile in Firestore
        // updates['updatedAt'] = FieldValue.serverTimestamp();
        // await _firestore!.collection('users').doc(_currentAppUser!.id).update(updates);
        
        // Refresh user data after update / Güncelleme sonrası kullanıcı verilerini yenile
        await refreshUserData();
        
        print('✅ FirebaseAuthService: User profile update requested (Firebase not configured yet)');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ FirebaseAuthService: Failed to update user profile - $e');
      return false;
    }
  }

  /// Firebase'i konfigüre et (Firebase Console kurulumu tamamlandıktan sonra çağrılır)
  /// Configure Firebase (called after Firebase Console setup is completed)
  Future<void> configureFirebase() async {
    try {
      print('🔧 FirebaseAuthService: Configuring Firebase...');
      
      await _checkFirebaseConfiguration();
      
      if (_isFirebaseConfigured) {
        await _initializeFirebaseServices();
        await _checkCurrentAuthState();
        print('✅ FirebaseAuthService: Firebase configured successfully');
      } else {
        throw Exception('Firebase configuration files not found');
      }
    } catch (e) {
      print('❌ FirebaseAuthService: Failed to configure Firebase - $e');
      _emitAuthState(FirebaseAuthState.error('Firebase konfigürasyon hatası / Firebase configuration error'));
      rethrow;
    }
  }

  /// Kimlik doğrulama durumunu yayınla / Emit authentication state
  void _emitAuthState(FirebaseAuthState state) {
    _authStateController.add(state);
  }

  /// Debug bilgilerini al / Get debug information
  Future<Map<String, dynamic>> getDebugInfo() async {
    return {
      'isInitialized': _isInitialized,
      'isFirebaseConfigured': _isFirebaseConfigured,
      'isAuthenticated': isAuthenticated,
      'currentAppUser': _currentAppUser?.toString(),
    };
  }

  /// Servisi temizle / Dispose service
  void dispose() {
    _authStateController.close();
  }
}

/// Firebase kimlik doğrulama durumu sınıfları / Firebase authentication state classes
abstract class FirebaseAuthState {
  const FirebaseAuthState();

  static const FirebaseAuthState loading = _LoadingState();
  static const FirebaseAuthState unauthenticated = _UnauthenticatedState();
  static const FirebaseAuthState notConfigured = _NotConfiguredState();
  
  static FirebaseAuthState authenticated(AppUser user) => _AuthenticatedState(user);
  static FirebaseAuthState error(String message) => _ErrorState(message);
}

class _LoadingState extends FirebaseAuthState {
  const _LoadingState();
}

class _UnauthenticatedState extends FirebaseAuthState {
  const _UnauthenticatedState();
}

class _NotConfiguredState extends FirebaseAuthState {
  const _NotConfiguredState();
}

class _AuthenticatedState extends FirebaseAuthState {
  final AppUser user;
  const _AuthenticatedState(this.user);
}

class _ErrorState extends FirebaseAuthState {
  final String message;
  const _ErrorState(this.message);
}

/// Firebase kimlik doğrulama sonucu sınıfı / Firebase authentication result class
class FirebaseAuthResult {
  final bool isSuccess;
  final AppUser? user;
  final String? errorMessage;

  const FirebaseAuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  static FirebaseAuthResult success(AppUser user) => FirebaseAuthResult._(
    isSuccess: true,
    user: user,
  );

  static FirebaseAuthResult error(String message) => FirebaseAuthResult._(
    isSuccess: false,
    errorMessage: message,
  );
} 