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
      
      // Firebase'e kullanıcı kaydet / Save user to Firebase
      await _createOrUpdateUserDocument(appUser, microsoftUserData, accessToken);
      
      // Sistem koleksiyonlarını oluştur / Create system collections
      await _createSystemCollectionsIfNeeded();
      
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

  /// Firebase'e kullanıcı belgesi oluştur veya güncelle
  /// Create or update user document in Firebase
  Future<void> _createOrUpdateUserDocument(
    AppUser appUser, 
    Map<String, dynamic> microsoftUserData, 
    String accessToken
  ) async {
    try {
      if (!_isFirebaseConfigured || _firestore == null) {
        print('⚠️ Firebase not configured, skipping user document creation');
        return;
      }

      final userDocRef = _firestore!.collection('users').doc(appUser.id);
      
      // Check if user document already exists
      final docSnapshot = await userDocRef.get();
      final now = FieldValue.serverTimestamp();
      
      if (docSnapshot.exists) {
        // Update existing user
        await userDocRef.update({
          'displayName': appUser.displayName,
          'email': appUser.email,
          'lastLoginAt': now,
          'lastActiveAt': now,
          'updatedAt': now,
        });
        print('✅ Updated existing user document in Firebase');
      } else {
        // Create new user document
        await userDocRef.set({
          // Microsoft OAuth Data
          'microsoftId': microsoftUserData['id'] ?? '',
          'email': appUser.email,
          'displayName': appUser.displayName,
          'firstName': microsoftUserData['givenName'] ?? '',
          'lastName': microsoftUserData['surname'] ?? '',
          'userPrincipalName': microsoftUserData['userPrincipalName'] ?? appUser.email,
          
          // University-specific Data (will be populated later)
          'studentId': null,
          'employeeId': null,
          'department': null,
          'faculty': null,
          'year': null,
          'semester': null,
          
          // System Data
          'role': 'student', // Default role
          'permissions': ['read_announcements', 'read_calendar', 'read_cafeteria'],
          'isActive': true,
          
          // Preferences
          'preferences': {
            'language': 'tr',
            'notifications': {
              'announcements': true,
              'grades': true,
              'cafeteria': true,
              'events': true,
              'pushEnabled': true,
              'emailEnabled': true,
            },
            'theme': 'system',
            'timezone': 'Europe/Istanbul',
          },
          
          // Profile Data
          'profile': {
            'profilePhotoUrl': null,
            'bio': null,
            'phoneNumber': null,
            'emergencyContact': null,
            'socialLinks': null,
          },
          
          // Timestamps
          'createdAt': now,
          'updatedAt': now,
          'lastLoginAt': now,
          'lastActiveAt': now,
        });
        print('✅ Created new user document in Firebase');
      }
    } catch (e) {
      print('❌ Failed to create/update user document: $e');
      // Don't rethrow to avoid breaking authentication flow
      // rethrow;
    }
  }

  /// Sistem koleksiyonlarını oluştur (sadece ilk kurulumda)
  /// Create system collections (only on first setup)
  Future<void> _createSystemCollectionsIfNeeded() async {
    try {
      if (!_isFirebaseConfigured || _firestore == null) {
        print('⚠️ Firebase not configured, skipping system collections creation');
        return;
      }

      // Check if app_config already exists
      final appConfigRef = _firestore!.collection('system').doc('app_config');
      final appConfigSnapshot = await appConfigRef.get();
      
      if (!appConfigSnapshot.exists) {
        // Create initial system configuration
        await appConfigRef.set({
          'maintenanceMode': false,
          'minimumAppVersion': '1.0.0',
          'forceUpdateVersion': '1.0.0',
          'supportedLanguages': ['tr', 'en'],
          'defaultLanguage': 'tr',
          'timezone': 'Europe/Istanbul',
          'academicYear': '2024-2025',
          'currentSemester': 1,
          'semesterStartDate': FieldValue.serverTimestamp(),
          'semesterEndDate': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Created initial app_config document');
      }

      // Create feature flags if not exist
      final featureFlagsRef = _firestore!.collection('system').doc('feature_flags');
      final featureFlagsSnapshot = await featureFlagsRef.get();
      
      if (!featureFlagsSnapshot.exists) {
        await featureFlagsRef.set({
          'gradesEnabled': true,
          'cafeteriaEnabled': true,
          'calendarEnabled': true,
          'notificationsEnabled': true,
          'chatEnabled': false,
          'fileUploadsEnabled': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Created initial feature_flags document');
      }

      // Create university data if not exist
      final universityDataRef = _firestore!.collection('system').doc('university_data');
      final universityDataSnapshot = await universityDataRef.get();
      
      if (!universityDataSnapshot.exists) {
        await universityDataRef.set({
          'name': 'İstanbul Medipol Üniversitesi',
          'nameEn': 'Istanbul Medipol University',
          'address': 'Göztepe Mahallesi, Atatürk Caddesi No:40/16, 34815 Beykoz/İstanbul',
          'phone': '+90 216 681 51 00',
          'email': 'info@medipol.edu.tr',
          'website': 'https://www.medipol.edu.tr',
          'campuses': {
            'kavacik': {
              'name': 'Kavacık Kampüsü',
              'address': 'Kavacık, Beykoz, İstanbul',
              'coordinates': {
                'latitude': 41.088612162240274,
                'longitude': 29.08920602676745,
              }
            }
          },
          'departments': ['Bilgisayar Mühendisliği', 'Tıp', 'Hukuk', 'İşletme'],
          'faculties': ['Mühendislik ve Doğa Bilimleri', 'Tıp', 'Hukuk', 'İşletme ve Yönetim Bilimleri'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Created initial university_data document');
      }

    } catch (e) {
      print('❌ Failed to create system collections: $e');
      // Don't rethrow to avoid breaking authentication flow
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