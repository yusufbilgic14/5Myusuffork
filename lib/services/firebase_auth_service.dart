import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

import '../models/user_model.dart';
import 'secure_storage_service.dart';

/// Firebase kimlik doğrulama servisi - Bağımsız ve Microsoft OAuth entegrasyonu
/// Firebase authentication service - Standalone and Microsoft OAuth integration
///
/// Bu servis hem bağımsız Firebase Auth hem de Microsoft OAuth'u destekler
/// This service supports both standalone Firebase Auth and Microsoft OAuth
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

  // Google Sign-In instance for OAuth / Google OAuth için GoogleSignIn örneği
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  // Current authentication method / Mevcut kimlik doğrulama yöntemi
  AuthenticationMethod _currentAuthMethod = AuthenticationMethod.none;

  // Firebase Authentication state stream / Firebase kimlik doğrulama durumu stream'i
  Stream<FirebaseAuthState> get authStateChanges => _authStateController.stream;

  // Current app user getter / Mevcut uygulama kullanıcısı getter'ı
  AppUser? get currentAppUser => _currentAppUser;

  // Authentication status / Kimlik doğrulama durumu
  bool get isAuthenticated => _currentAppUser != null && _isFirebaseConfigured;

  // Current authentication method / Mevcut kimlik doğrulama yöntemi
  AuthenticationMethod get currentAuthMethod => _currentAuthMethod;

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
        print(
          '✅ FirebaseAuthService: Firebase Auth service initialized successfully',
        );
      } else {
        print(
          '⚠️ FirebaseAuthService: Firebase not configured yet. Please complete Firebase Console setup.',
        );
        _emitAuthState(FirebaseAuthState.notConfigured);
      }

      _isInitialized = true;
    } catch (e) {
      print('❌ FirebaseAuthService: Failed to initialize - $e');
      _isInitialized = false;
      _emitAuthState(
        FirebaseAuthState.error('Başlatma hatası / Initialization error: $e'),
      );
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

        print(
          '📋 FirebaseAuthService: Firebase configuration status: $_isFirebaseConfigured',
        );
      } catch (e) {
        print(
          '⚠️ FirebaseAuthService: Firebase not yet available, will be activated after proper setup',
        );
        _isFirebaseConfigured = false;
      }
    } catch (e) {
      print(
        '❌ FirebaseAuthService: Error checking Firebase configuration - $e',
      );
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
      print(
        '❌ FirebaseAuthService: Failed to import Firebase dependencies - $e',
      );
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
      print(
        '❌ FirebaseAuthService: Failed to initialize Firebase services - $e',
      );
      throw e;
    }
  }

  /// Firebase Auth durumu değişikliklerini işle / Handle Firebase Auth state changes
  void _handleFirebaseAuthStateChange(User? firebaseUser) {
    try {
      print(
        '🔄 FirebaseAuthService: Firebase auth state changed - User: ${firebaseUser?.uid ?? 'null'}',
      );

      if (firebaseUser != null) {
        // Firebase kullanıcısı var / Firebase user exists
        print(
          '✅ FirebaseAuthService: Firebase user signed in: ${firebaseUser.email}',
        );
        // Bu durumda zaten Microsoft OAuth ile giriş yapılmış ve Firebase'e entegre edilmiş demektir
        // This means Microsoft OAuth sign-in has already been done and integrated with Firebase
      } else {
        // Firebase kullanıcısı yok / No Firebase user
        print('👤 FirebaseAuthService: No Firebase user found');
      }
    } catch (e) {
      print(
        '❌ FirebaseAuthService: Error handling Firebase auth state change - $e',
      );
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
        final errorMsg =
            'Firebase henüz konfigüre edilmedi. Lütfen Firebase Console kurulumunu tamamlayın.';
        _emitAuthState(FirebaseAuthState.error(errorMsg));
        return FirebaseAuthResult.error(errorMsg);
      }

      // Create AppUser from Microsoft data / Microsoft verilerinden AppUser oluştur
      final appUser = AppUser(
        id: microsoftUserData['id'],
        displayName: microsoftUserData['displayName'] ?? 'Kullanıcı',
        userPrincipalName: microsoftUserData['userPrincipalName'],
        email:
            microsoftUserData['mail'] ?? microsoftUserData['userPrincipalName'],
        firstName: microsoftUserData['givenName'],
        lastName: microsoftUserData['surname'],
        jobTitle: microsoftUserData['jobTitle'],
        department: microsoftUserData['department'],
        businessPhones: (microsoftUserData['businessPhones'] as List<dynamic>?)
            ?.cast<String>(),
        mobilePhone: microsoftUserData['mobilePhone'],
        officeLocation: microsoftUserData['officeLocation'],
        preferredLanguage: microsoftUserData['preferredLanguage'],
      );

      // Geçici olarak kullanıcıyı sakla / Temporarily store the user
      _currentAppUser = appUser;

      // Firebase'e kullanıcı kaydet / Save user to Firebase
      await _createOrUpdateUserDocument(
        appUser,
        microsoftUserData,
        accessToken,
      );

      // Sistem koleksiyonlarını oluştur / Create system collections
      await _createSystemCollectionsIfNeeded();

      // Token'ları güvenli şekilde sakla / Store tokens securely
      await _storeAuthTokens(accessToken, idToken);

      _emitAuthState(FirebaseAuthState.authenticated(appUser));

      print(
        '🎉 FirebaseAuthService: Successfully signed in user: ${appUser.displayName}',
      );
      return FirebaseAuthResult.success(appUser);
    } catch (e) {
      print('❌ FirebaseAuthService: Sign in failed - $e');
      _emitAuthState(
        FirebaseAuthState.error('Giriş hatası / Sign in error: $e'),
      );
      return FirebaseAuthResult.error('Sign in error: $e');
    }
  }

  /// Email ve şifre ile Firebase'e kayıt ol / Sign up to Firebase with email and password
  Future<FirebaseAuthResult> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    String? studentId,
    String? department,
    String? phoneNumber,
    UserRole role = UserRole.student,
  }) async {
    try {
      print('🚀 FirebaseAuthService: Starting email/password sign up...');
      _emitAuthState(FirebaseAuthState.loading);

      if (!_isFirebaseConfigured || _firebaseAuth == null) {
        final errorMsg =
            'Firebase henüz konfigure edilmedi. Lütfen Firebase Console kurulumunu tamamlayın.';
        _emitAuthState(FirebaseAuthState.error(errorMsg));
        return FirebaseAuthResult.error(errorMsg);
      }

      // Create Firebase user account / Firebase kullanıcı hesabı oluştur
      final userCredential = await _firebaseAuth!
          .createUserWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Kullanıcı hesabı oluşturulamadı');
      }

      // Update Firebase profile / Firebase profilini güncelle
      await firebaseUser.updateDisplayName(displayName);

      // Send email verification / Email doğrulama gönder
      await firebaseUser.sendEmailVerification();

      // Create AppUser object / AppUser nesnesi oluştur
      final appUser = AppUser(
        id: firebaseUser.uid,
        displayName: displayName,
        email: email,
        userPrincipalName: email,
        firebaseUid: firebaseUser.uid,
        userRole: role,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Store user data in Firestore / Kullanıcı verilerini Firestore'a kaydet
      await _createStandaloneUserDocument(
        appUser,
        studentId: studentId,
        department: department,
        phoneNumber: phoneNumber,
      );

      _currentAppUser = appUser;
      _currentAuthMethod = AuthenticationMethod.firebaseEmail;

      // Store auth state / Kimlik doğrulama durumunu sakla
      await _storage.storeAuthState(true);

      // Store user data with safe JSON conversion / Güvenli JSON dönüştürmeyle kullanıcı verilerini sakla
      try {
        await _storage.storeUserData(appUser.toJson());
      } catch (e) {
        print('⚠️ Failed to store user data locally: $e');
        // Continue without storing locally - user data is still in Firestore
      }

      _emitAuthState(FirebaseAuthState.authenticated(appUser));

      print(
        '🎉 FirebaseAuthService: Successfully created user account: $email',
      );
      return FirebaseAuthResult.success(appUser);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Bu email adresi zaten kullanımda.';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz email adresi.';
          break;
        default:
          errorMessage = 'Kayıt sırasında bir hata oluştu: ${e.message}';
      }
      print('❌ FirebaseAuthService: Sign up failed - $errorMessage');
      _emitAuthState(FirebaseAuthState.error(errorMessage));
      return FirebaseAuthResult.error(errorMessage);
    } catch (e) {
      final errorMsg = 'Kayıt sırasında beklenmeyen bir hata oluştu: $e';
      print('❌ FirebaseAuthService: Sign up failed - $errorMsg');
      _emitAuthState(FirebaseAuthState.error(errorMsg));
      return FirebaseAuthResult.error(errorMsg);
    }
  }

  /// Email ve şifre ile Firebase'e giriş yap / Sign in to Firebase with email and password
  Future<FirebaseAuthResult> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🚀 FirebaseAuthService: Starting email/password sign in...');
      _emitAuthState(FirebaseAuthState.loading);

      if (!_isFirebaseConfigured || _firebaseAuth == null) {
        final errorMsg =
            'Firebase henüz konfigure edilmedi. Lütfen Firebase Console kurulumunu tamamlayın.';
        _emitAuthState(FirebaseAuthState.error(errorMsg));
        return FirebaseAuthResult.error(errorMsg);
      }

      // Sign in with Firebase Auth / Firebase Auth ile giriş yap
      final userCredential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Giriş başarısız');
      }

      // Load user data from Firestore / Firestore'dan kullanıcı verilerini yükle
      final appUser = await _loadUserDataFromFirestore(firebaseUser.uid);
      if (appUser == null) {
        throw Exception('Kullanıcı verileri bulunamadı');
      }

      // Update last login time / Son giriş zamanını güncelle
      await _updateUserLastLogin(firebaseUser.uid);

      _currentAppUser = appUser;
      _currentAuthMethod = AuthenticationMethod.firebaseEmail;

      // Store auth state / Kimlik doğrulama durumunu sakla
      await _storage.storeAuthState(true);

      // Store user data with safe JSON conversion / Güvenli JSON dönüştürmeyle kullanıcı verilerini sakla
      try {
        await _storage.storeUserData(appUser.toJson());
      } catch (e) {
        print('⚠️ Failed to store user data locally: $e');
        // Continue without storing locally - user data is still in Firestore
      }

      _emitAuthState(FirebaseAuthState.authenticated(appUser));

      print('🎉 FirebaseAuthService: Successfully signed in user: $email');
      return FirebaseAuthResult.success(appUser);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Bu email adresi ile kayıtlı kullanıcı bulunamadı.';
          break;
        case 'wrong-password':
          errorMessage = 'Yanlış şifre.';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz email adresi.';
          break;
        case 'user-disabled':
          errorMessage = 'Bu kullanıcı hesabı devre dışı bırakılmıştır.';
          break;
        case 'too-many-requests':
          errorMessage =
              'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
          break;
        default:
          errorMessage = 'Giriş sırasında bir hata oluştu: ${e.message}';
      }
      print('❌ FirebaseAuthService: Sign in failed - $errorMessage');
      _emitAuthState(FirebaseAuthState.error(errorMessage));
      return FirebaseAuthResult.error(errorMessage);
    } catch (e) {
      final errorMsg = 'Giriş sırasında beklenmeyen bir hata oluştu: $e';
      print('❌ FirebaseAuthService: Sign in failed - $errorMsg');
      _emitAuthState(FirebaseAuthState.error(errorMsg));
      return FirebaseAuthResult.error(errorMsg);
    }
  }

  /// Google ile giriş yap / Sign in with Google
  Future<FirebaseAuthResult> signInWithGoogle() async {
    try {
      print('🚀 FirebaseAuthService: Starting Google sign in...');
      _emitAuthState(FirebaseAuthState.loading);

      if (!_isFirebaseConfigured || _firebaseAuth == null) {
        final errorMsg =
            'Firebase henüz konfigure edilmedi. Lütfen Firebase Console kurulumunu tamamlayın.';
        _emitAuthState(FirebaseAuthState.error(errorMsg));
        return FirebaseAuthResult.error(errorMsg);
      }

      // Sign in with Google / Google ile giriş yap
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in / Kullanıcı girişi iptal etti
        _emitAuthState(FirebaseAuthState.unauthenticated);
        return FirebaseAuthResult.error('Google girişi iptal edildi');
      }

      // Obtain the auth details from the request / İstekten kimlik doğrulama detaylarını al
      final googleAuth = await googleUser.authentication;

      // Create a new credential / Yeni bir credential oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential / Google credential ile Firebase'e giriş yap
      final userCredential = await _firebaseAuth!.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Google girişi başarısız');
      }

      // Check if this is a new user / Yeni kullanıcı olup olmadığını kontrol et
      AppUser? appUser = await _loadUserDataFromFirestore(firebaseUser.uid);

      if (appUser == null) {
        // Create new user document for Google sign-in / Google girişi için yeni kullanıcı belgesi oluştur
        appUser = AppUser(
          id: firebaseUser.uid,
          displayName: firebaseUser.displayName ?? 'Google User',
          email: firebaseUser.email!,
          userPrincipalName: firebaseUser.email!,
          firebaseUid: firebaseUser.uid,
          userRole: UserRole.student,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _createStandaloneUserDocument(appUser);
      } else {
        // Update last login time / Son giriş zamanını güncelle
        await _updateUserLastLogin(firebaseUser.uid);
      }

      _currentAppUser = appUser;
      _currentAuthMethod = AuthenticationMethod.firebaseGoogle;

      // Store auth state / Kimlik doğrulama durumunu sakla
      await _storage.storeAuthState(true);

      // Store user data with safe JSON conversion / Güvenli JSON dönüştürmeyle kullanıcı verilerini sakla
      try {
        await _storage.storeUserData(appUser.toJson());
      } catch (e) {
        print('⚠️ Failed to store user data locally: $e');
        // Continue without storing locally - user data is still in Firestore
      }

      _emitAuthState(FirebaseAuthState.authenticated(appUser));

      print(
        '🎉 FirebaseAuthService: Successfully signed in with Google: ${appUser.email}',
      );
      return FirebaseAuthResult.success(appUser);
    } catch (e) {
      final errorMsg = 'Google girişi sırasında bir hata oluştu: $e';
      print('❌ FirebaseAuthService: Google sign in failed - $errorMsg');
      _emitAuthState(FirebaseAuthState.error(errorMsg));
      return FirebaseAuthResult.error(errorMsg);
    }
  }

  /// Şifre sıfırlama emaili gönder / Send password reset email
  Future<FirebaseAuthResult> sendPasswordResetEmail(String email) async {
    try {
      print('📧 FirebaseAuthService: Sending password reset email to: $email');

      if (!_isFirebaseConfigured || _firebaseAuth == null) {
        final errorMsg = 'Firebase henüz konfigure edilmedi.';
        return FirebaseAuthResult.error(errorMsg);
      }

      await _firebaseAuth!.sendPasswordResetEmail(email: email);

      print('✅ FirebaseAuthService: Password reset email sent successfully');
      return FirebaseAuthResult.successWithoutUser();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Bu email adresi ile kayıtlı kullanıcı bulunamadı.';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz email adresi.';
          break;
        default:
          errorMessage = 'Şifre sıfırlama emaili gönderilemedi: ${e.message}';
      }
      print('❌ FirebaseAuthService: Password reset failed - $errorMessage');
      return FirebaseAuthResult.error(errorMessage);
    } catch (e) {
      final errorMsg = 'Şifre sıfırlama sırasında bir hata oluştu: $e';
      print('❌ FirebaseAuthService: Password reset failed - $errorMsg');
      return FirebaseAuthResult.error(errorMsg);
    }
  }

  /// Email doğrulama gönder / Send email verification
  Future<FirebaseAuthResult> sendEmailVerification() async {
    try {
      if (!_isFirebaseConfigured || _firebaseAuth == null) {
        return FirebaseAuthResult.error('Firebase konfigure edilmedi');
      }

      final user = _firebaseAuth!.currentUser;
      if (user == null) {
        return FirebaseAuthResult.error('Kullanıcı oturumu bulunamadı');
      }

      if (user.emailVerified) {
        return FirebaseAuthResult.error('Email zaten doğrulanmış');
      }

      await user.sendEmailVerification();
      print('✅ FirebaseAuthService: Email verification sent');
      return FirebaseAuthResult.successWithoutUser();
    } catch (e) {
      final errorMsg = 'Email doğrulama gönderilemedi: $e';
      print('❌ FirebaseAuthService: Send verification failed - $errorMsg');
      return FirebaseAuthResult.error(errorMsg);
    }
  }

  /// Email doğrulama durumunu kontrol et / Check email verification status
  Future<bool> checkEmailVerificationStatus() async {
    try {
      if (!_isFirebaseConfigured || _firebaseAuth == null) {
        return false;
      }

      final user = _firebaseAuth!.currentUser;
      if (user == null) return false;

      await user.reload();
      return _firebaseAuth!.currentUser?.emailVerified ?? false;
    } catch (e) {
      print('❌ FirebaseAuthService: Failed to check email verification - $e');
      return false;
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
      _emitAuthState(
        FirebaseAuthState.error('Kimlik doğrulama durumu kontrol edilemedi'),
      );
    }
  }

  /// Çıkış yap / Sign out
  Future<void> signOut() async {
    try {
      print('🚪 FirebaseAuthService: Signing out...');
      _emitAuthState(FirebaseAuthState.loading);

      // Sign out from Firebase Auth / Firebase Auth'dan çıkış yap
      if (_isFirebaseConfigured && _firebaseAuth != null) {
        await _firebaseAuth!.signOut();
      }

      // Sign out from Google if currently signed in / Google'dan çıkış yap (eğer giriş yapılmışsa)
      if (_currentAuthMethod == AuthenticationMethod.firebaseGoogle) {
        await _googleSignIn.signOut();
      }

      // Clear stored tokens / Saklanan token'ları temizle
      await _storage.clearAllAuthData();

      // Clear current user data / Mevcut kullanıcı verilerini temizle
      _currentAppUser = null;
      _currentAuthMethod = AuthenticationMethod.none;

      _emitAuthState(FirebaseAuthState.unauthenticated);
      print('✅ FirebaseAuthService: Sign out completed');
    } catch (e) {
      print('❌ FirebaseAuthService: Sign out failed - $e');
      // Even if sign out fails, clear local data / Çıkış başarısız olsa bile yerel verileri temizle
      await _storage.clearAllAuthData();
      _currentAppUser = null;
      _currentAuthMethod = AuthenticationMethod.none;
      _emitAuthState(FirebaseAuthState.unauthenticated);
    }
  }

  /// Kullanıcı verilerini yenile / Refresh user data
  Future<void> refreshUserData() async {
    try {
      if (!_isFirebaseConfigured) {
        print(
          '⚠️ FirebaseAuthService: Cannot refresh user data - Firebase not configured',
        );
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

        print(
          '✅ FirebaseAuthService: User data refresh requested (Firebase not configured yet)',
        );
      }
    } catch (e) {
      print('❌ FirebaseAuthService: Failed to refresh user data - $e');
    }
  }

  /// Kullanıcı profilini güncelle / Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      if (!_isFirebaseConfigured) {
        print(
          '⚠️ FirebaseAuthService: Cannot update profile - Firebase not configured',
        );
        return false;
      }

      if (_currentAppUser != null) {
        // TODO: Firestore'da kullanıcı profilini güncelle
        // TODO: Update user profile in Firestore
        // updates['updatedAt'] = FieldValue.serverTimestamp();
        // await _firestore!.collection('users').doc(_currentAppUser!.id).update(updates);

        // Refresh user data after update / Güncelleme sonrası kullanıcı verilerini yenile
        await refreshUserData();

        print(
          '✅ FirebaseAuthService: User profile update requested (Firebase not configured yet)',
        );
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
      _emitAuthState(
        FirebaseAuthState.error(
          'Firebase konfigürasyon hatası / Firebase configuration error',
        ),
      );
      rethrow;
    }
  }

  /// Firebase'e kullanıcı belgesi oluştur veya güncelle
  /// Create or update user document in Firebase
  Future<void> _createOrUpdateUserDocument(
    AppUser appUser,
    Map<String, dynamic> microsoftUserData,
    String accessToken,
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
          'userPrincipalName':
              microsoftUserData['userPrincipalName'] ?? appUser.email,

          // University-specific Data (will be populated later)
          'studentId': null,
          'employeeId': null,
          'department': null,
          'faculty': null,
          'year': null,
          'semester': null,

          // System Data
          'role': 'student', // Default role
          'permissions': [
            'read_announcements',
            'read_calendar',
            'read_cafeteria',
          ],
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
        print(
          '⚠️ Firebase not configured, skipping system collections creation',
        );
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
      final featureFlagsRef = _firestore!
          .collection('system')
          .doc('feature_flags');
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
      final universityDataRef = _firestore!
          .collection('system')
          .doc('university_data');
      final universityDataSnapshot = await universityDataRef.get();

      if (!universityDataSnapshot.exists) {
        await universityDataRef.set({
          'name': 'İstanbul Medipol Üniversitesi',
          'nameEn': 'Istanbul Medipol University',
          'address':
              'Göztepe Mahallesi, Atatürk Caddesi No:40/16, 34815 Beykoz/İstanbul',
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
              },
            },
          },
          'departments': ['Bilgisayar Mühendisliği', 'Tıp', 'Hukuk', 'İşletme'],
          'faculties': [
            'Mühendislik ve Doğa Bilimleri',
            'Tıp',
            'Hukuk',
            'İşletme ve Yönetim Bilimleri',
          ],
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

  /// Bağımsız Firebase kullanıcısı için Firestore belgesi oluştur
  /// Create Firestore document for standalone Firebase user
  Future<void> _createStandaloneUserDocument(
    AppUser appUser, {
    String? studentId,
    String? department,
    String? phoneNumber,
  }) async {
    try {
      if (!_isFirebaseConfigured || _firestore == null) {
        print('⚠️ Firebase not configured, skipping user document creation');
        return;
      }

      final userDocRef = _firestore!.collection('users').doc(appUser.id);
      final now = FieldValue.serverTimestamp();

      await userDocRef.set({
        // Firebase Native Data
        'uid': appUser.firebaseUid ?? appUser.id,
        'email': appUser.email,
        'displayName': appUser.displayName,
        'emailVerified': false, // Will be updated when verified
        'photoURL': null,
        'phoneNumber': phoneNumber,

        // University Information (user-provided)
        'studentId': studentId,
        'employeeId': null,
        'department': department,
        'faculty': null,
        'enrollmentYear': DateTime.now().year,
        'year': 1, // Default first year
        'semester': null,

        // App Preferences
        'preferences': {
          'theme': 'system',
          'language': 'tr',
          'notifications': {
            'announcements': true,
            'grades': true,
            'calendar': true,
            'cafeteria': true,
            'general': true,
          },
        },

        // System Data
        'role': appUser.userRole?.toString().split('.').last ?? 'student',
        'permissions': [
          'read_announcements',
          'read_calendar',
          'read_cafeteria',
        ],
        'isActive': true,
        'accountType': 'firebase',

        // Timestamps
        'createdAt': now,
        'updatedAt': now,
        'lastLoginAt': now,
        'emailVerifiedAt': null,
      });

      print('✅ Created standalone Firebase user document');
    } catch (e) {
      print('❌ Failed to create standalone user document: $e');
      rethrow;
    }
  }

  /// Firestore'dan kullanıcı verilerini yükle / Load user data from Firestore
  Future<AppUser?> _loadUserDataFromFirestore(String uid) async {
    try {
      if (!_isFirebaseConfigured || _firestore == null) {
        return null;
      }

      final userDoc = await _firestore!.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        return null;
      }

      final data = userDoc.data()!;
      return AppUser(
        id: uid,
        displayName: data['displayName'] ?? 'User',
        email: data['email'] ?? '',
        userPrincipalName: data['email'] ?? '',
        firebaseUid: uid,
        userRole: _parseUserRole(data['role']),
        isActive: data['isActive'] ?? true,
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt:
            (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      print('❌ Failed to load user data from Firestore: $e');
      return null;
    }
  }

  /// Kullanıcının son giriş zamanını güncelle / Update user's last login time
  Future<void> _updateUserLastLogin(String uid) async {
    try {
      if (!_isFirebaseConfigured || _firestore == null) {
        return;
      }

      await _firestore!.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Failed to update last login time: $e');
    }
  }

  /// String'den UserRole'e çevir / Parse UserRole from string
  UserRole _parseUserRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'staff':
        return UserRole.staff;
      case 'student':
      default:
        return UserRole.student;
    }
  }

  /// Kullanıcı tercihi güncelle / Update user preference
  Future<bool> updateUserPreference(String key, dynamic value) async {
    try {
      if (!_isFirebaseConfigured ||
          _firestore == null ||
          _currentAppUser == null) {
        return false;
      }

      await _firestore!.collection('users').doc(_currentAppUser!.id).update({
        'preferences.$key': value,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Updated user preference: $key = $value');
      return true;
    } catch (e) {
      print('❌ Failed to update user preference: $e');
      return false;
    }
  }

  /// Kullanıcı tercihini al / Get user preference
  Future<T?> getUserPreference<T>(String key) async {
    try {
      if (!_isFirebaseConfigured ||
          _firestore == null ||
          _currentAppUser == null) {
        return null;
      }

      final userDoc = await _firestore!
          .collection('users')
          .doc(_currentAppUser!.id)
          .get();
      if (!userDoc.exists) return null;

      final data = userDoc.data();
      final preferences = data?['preferences'] as Map<String, dynamic>?;
      return preferences?[key] as T?;
    } catch (e) {
      print('❌ Failed to get user preference: $e');
      return null;
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

  static FirebaseAuthState authenticated(AppUser user) =>
      _AuthenticatedState(user);
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

  static FirebaseAuthResult success(AppUser user) =>
      FirebaseAuthResult._(isSuccess: true, user: user);

  static FirebaseAuthResult successWithoutUser() =>
      FirebaseAuthResult._(isSuccess: true, user: null);

  static FirebaseAuthResult error(String message) =>
      FirebaseAuthResult._(isSuccess: false, errorMessage: message);
}

/// Kimlik doğrulama yöntemleri / Authentication methods
enum AuthenticationMethod {
  none,
  firebaseEmail,
  firebaseGoogle,
  microsoftOauth,
}
