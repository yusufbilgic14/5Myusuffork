import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../models/user_profile_model.dart';
import 'firebase_auth_service.dart';

/// Kullanıcı profil yönetim servisi / User profile management service
class UserProfileService {
  // Singleton pattern implementation
  static final UserProfileService _instance = UserProfileService._internal();
  factory UserProfileService() => _instance;
  UserProfileService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Stream subscriptions for memory management
  final Map<String, StreamSubscription> _subscriptions = {};

  // Cache for frequently accessed data
  UserProfile? _profileCache;
  Timer? _cacheExpireTimer;
  static const Duration _cacheExpiry = Duration(minutes: 10);

  /// Mevcut kullanıcının Firebase UID'sini getir / Get current user's Firebase UID
  String? get currentUserId => _authService.currentAppUser?.id;

  /// Kullanıcının kimlik doğrulaması yapılmış mı kontrol et / Check if user is authenticated
  bool get isAuthenticated => _authService.isAuthenticated;

  // ==========================================
  // PROFILE DATA OPERATIONS / PROFİL VERİ İŞLEMLERİ
  // ==========================================

  /// Kullanıcı profil verisini getir / Get user profile data
  Future<UserProfile?> getUserProfile([String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        print('❌ UserProfileService: User not authenticated');
        return null;
      }

      // Check cache first
      if (_profileCache != null && _profileCache!.userId == uid) {
        print('📋 UserProfileService: Returning cached profile for $uid');
        return _profileCache;
      }

      print('🔍 UserProfileService: Fetching profile for user $uid');
      
      final doc = await _firestore
          .collection('userProfiles')
          .doc(uid)
          .get();

      if (doc.exists && doc.data() != null) {
        final profile = UserProfile.fromFirestoreData(doc.data()!, doc.id);
        _updateCache(profile);
        print('✅ UserProfileService: Profile loaded successfully for $uid');
        return profile;
      } else {
        // Create empty profile if doesn't exist
        print('📝 UserProfileService: Creating empty profile for $uid');
        final emptyProfile = UserProfile.empty(uid);
        await createUserProfile(emptyProfile);
        return emptyProfile;
      }
    } catch (e) {
      print('❌ UserProfileService: Error fetching profile: $e');
      return null;
    }
  }

  /// Kullanıcı profil verisini stream olarak getir / Get user profile data as stream
  Stream<UserProfile?> getUserProfileStream([String? userId]) {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      print('❌ UserProfileService: User not authenticated for stream');
      return Stream.value(null);
    }

    print('📡 UserProfileService: Starting profile stream for $uid');
    
    return _firestore
        .collection('userProfiles')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final profile = UserProfile.fromFirestoreData(snapshot.data()!, snapshot.id);
        _updateCache(profile);
        return profile;
      }
      return null;
    }).handleError((error) {
      print('❌ UserProfileService: Stream error: $error');
      return null;
    });
  }

  /// Yeni kullanıcı profili oluştur / Create new user profile
  Future<bool> createUserProfile(UserProfile profile) async {
    try {
      final uid = profile.userId;
      if (uid.isEmpty) {
        print('❌ UserProfileService: Invalid user ID');
        return false;
      }

      print('📝 UserProfileService: Creating profile for $uid');

      final profileData = profile.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('userProfiles')
          .doc(uid)
          .set(profileData.toFirestoreData());

      _updateCache(profileData);
      print('✅ UserProfileService: Profile created successfully for $uid');
      return true;
    } catch (e) {
      print('❌ UserProfileService: Error creating profile: $e');
      return false;
    }
  }

  /// Kullanıcı profil verisini güncelle / Update user profile data
  Future<bool> updateUserProfile(UserProfile updatedProfile) async {
    try {
      final uid = updatedProfile.userId;
      if (uid.isEmpty) {
        print('❌ UserProfileService: Invalid user ID for update');
        return false;
      }

      print('🔄 UserProfileService: Updating profile for $uid');

      final profileData = updatedProfile.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('userProfiles')
          .doc(uid)
          .update(profileData.toFirestoreData());

      _updateCache(profileData);
      print('✅ UserProfileService: Profile updated successfully for $uid');
      return true;
    } catch (e) {
      print('❌ UserProfileService: Error updating profile: $e');
      return false;
    }
  }

  /// Akademik bilgileri güncelle / Update academic information
  Future<bool> updateAcademicInfo(UserAcademicInfo academicInfo, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        print('❌ UserProfileService: User not authenticated');
        return false;
      }

      print('🎓 UserProfileService: Updating academic info for $uid');

      // Get current profile
      final currentProfile = await getUserProfile(uid);
      if (currentProfile == null) {
        print('❌ UserProfileService: Profile not found for update');
        return false;
      }

      // Check if profile is now complete
      final updatedProfile = currentProfile.copyWith(
        academicInfo: academicInfo,
        updatedAt: DateTime.now(),
        isProfileComplete: _checkProfileCompleteness(currentProfile.copyWith(academicInfo: academicInfo)),
      );

      return await updateUserProfile(updatedProfile);
    } catch (e) {
      print('❌ UserProfileService: Error updating academic info: $e');
      return false;
    }
  }

  /// İstatistikleri güncelle / Update statistics
  Future<bool> updateStats(UserProfileStats stats, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        print('❌ UserProfileService: User not authenticated');
        return false;
      }

      print('📊 UserProfileService: Updating stats for $uid');

      // Get current profile
      final currentProfile = await getUserProfile(uid);
      if (currentProfile == null) {
        print('❌ UserProfileService: Profile not found for stats update');
        return false;
      }

      final updatedProfile = currentProfile.copyWith(
        stats: stats,
        updatedAt: DateTime.now(),
      );

      return await updateUserProfile(updatedProfile);
    } catch (e) {
      print('❌ UserProfileService: Error updating stats: $e');
      return false;
    }
  }

  /// App tercihlerini güncelle / Update app preferences
  Future<bool> updateAppPreferences(UserAppPreferences appPreferences, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        print('❌ UserProfileService: User not authenticated');
        return false;
      }

      print('⚙️ UserProfileService: Updating app preferences for $uid');

      // Get current profile
      final currentProfile = await getUserProfile(uid);
      if (currentProfile == null) {
        print('❌ UserProfileService: Profile not found for preferences update');
        return false;
      }

      final updatedProfile = currentProfile.copyWith(
        appPreferences: appPreferences,
        updatedAt: DateTime.now(),
      );

      return await updateUserProfile(updatedProfile);
    } catch (e) {
      print('❌ UserProfileService: Error updating app preferences: $e');
      return false;
    }
  }

  /// Bildirim tercihlerini güncelle / Update notification preferences
  Future<bool> updateNotificationPreferences(UserNotificationPreferences notificationPreferences, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        print('❌ UserProfileService: User not authenticated');
        return false;
      }

      print('🔔 UserProfileService: Updating notification preferences for $uid');

      // Get current profile
      final currentProfile = await getUserProfile(uid);
      if (currentProfile == null) {
        print('❌ UserProfileService: Profile not found for notification preferences update');
        return false;
      }

      final updatedProfile = currentProfile.copyWith(
        notificationPreferences: notificationPreferences,
        updatedAt: DateTime.now(),
      );

      return await updateUserProfile(updatedProfile);
    } catch (e) {
      print('❌ UserProfileService: Error updating notification preferences: $e');
      return false;
    }
  }

  /// Profil fotoğrafı URL'ini güncelle / Update profile photo URL
  Future<bool> updateProfilePhoto(String photoUrl, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        print('❌ UserProfileService: User not authenticated');
        return false;
      }

      print('📸 UserProfileService: Updating profile photo for $uid');

      await _firestore
          .collection('userProfiles')
          .doc(uid)
          .update({
        'profile_photo_url': photoUrl,
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });

      // Update cache if exists
      if (_profileCache != null && _profileCache!.userId == uid) {
        _profileCache = _profileCache!.copyWith(
          profilePhotoUrl: photoUrl,
          updatedAt: DateTime.now(),
        );
      }

      print('✅ UserProfileService: Profile photo updated successfully');
      return true;
    } catch (e) {
      print('❌ UserProfileService: Error updating profile photo: $e');
      return false;
    }
  }

  // ==========================================
  // UTILITY METHODS / YARDIMCI METOTLAR
  // ==========================================

  /// Profilin tamamlanma durumunu kontrol et / Check profile completeness
  bool _checkProfileCompleteness(UserProfile profile) {
    return profile.academicInfo?.studentId != null &&
           profile.academicInfo?.department != null &&
           profile.academicInfo?.grade != null &&
           profile.academicInfo?.faculty != null;
  }

  /// Cache'i güncelle / Update cache
  void _updateCache(UserProfile profile) {
    _profileCache = profile;
    _cacheExpireTimer?.cancel();
    _cacheExpireTimer = Timer(_cacheExpiry, () {
      _profileCache = null;
      print('🗑️ UserProfileService: Profile cache expired');
    });
  }

  /// Cache'i temizle / Clear cache
  void clearCache() {
    _profileCache = null;
    _cacheExpireTimer?.cancel();
    print('🗑️ UserProfileService: Profile cache cleared manually');
  }

  /// İstatistikleri yeniden hesapla ve güncelle / Recalculate and update statistics
  Future<bool> refreshStats([String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) return false;

      print('🔄 UserProfileService: Refreshing stats for $uid');

      // Calculate stats from other services
      int eventsCount = 0;
      double gpa = 0.0;
      int complaintsCount = 0;
      int assignmentsCount = 0;

      // Get events count from user events
      try {
        final eventsQuery = await _firestore
            .collection('users')
            .doc(uid)
            .collection('myEvents')
            .get();
        eventsCount = eventsQuery.docs.length;
      } catch (e) {
        print('⚠️ UserProfileService: Error getting events count: $e');
      }

      // Get GPA from academic info (if available)
      final profile = await getUserProfile(uid);
      if (profile?.academicInfo?.gpa != null) {
        gpa = profile!.academicInfo!.gpa!;
      }

      // TODO: Get complaints and assignments from respective services
      // These would need to be implemented in other parts of the app

      final newStats = UserProfileStats(
        eventsCount: eventsCount,
        gpa: gpa,
        complaintsCount: complaintsCount,
        assignmentsCount: assignmentsCount,
      );

      return await updateStats(newStats, uid);
    } catch (e) {
      print('❌ UserProfileService: Error refreshing stats: $e');
      return false;
    }
  }

  /// Get specific user profile by user ID (for notifications)
  /// Belirli kullanıcı profilini kullanıcı ID'si ile getir (bildirimler için)
  Future<UserProfile?> getSpecificUserProfile(String userId) async {
    try {
      print('👤 UserProfileService: Getting profile for user $userId');

      final profileDoc = await _firestore
          .collection('userProfiles')
          .doc(userId)
          .get();

      if (!profileDoc.exists) {
        print('❌ UserProfileService: Profile not found for user $userId');
        return null;
      }

      final profile = UserProfile.fromFirestoreData(profileDoc.data()!, profileDoc.id);
      print('✅ UserProfileService: Profile retrieved for user $userId');
      return profile;
    } catch (e) {
      print('❌ UserProfileService: Error getting profile for $userId: $e');
      return null;
    }
  }

  // ==========================================
  // MEMORY MANAGEMENT / BELLEK YÖNETİMİ
  // ==========================================

  /// Tüm stream aboneliklerini iptal et / Cancel all stream subscriptions
  void dispose() {
    for (var subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _cacheExpireTimer?.cancel();
    _profileCache = null;
    print('🧹 UserProfileService: All resources disposed');
  }

  /// Belirli bir stream aboneliğini iptal et / Cancel specific stream subscription
  void cancelSubscription(String key) {
    if (_subscriptions.containsKey(key)) {
      _subscriptions[key]!.cancel();
      _subscriptions.remove(key);
      print('🧹 UserProfileService: Subscription $key cancelled');
    }
  }
}