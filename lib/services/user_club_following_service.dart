import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../models/user_interaction_models.dart';
import 'firebase_auth_service.dart';

/// User club following management service
/// Kullanıcı kulüp takip yönetim servisi
class UserClubFollowingService {
  // Singleton pattern implementation
  static final UserClubFollowingService _instance =
      UserClubFollowingService._internal();
  factory UserClubFollowingService() => _instance;
  UserClubFollowingService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Stream subscriptions for memory management
  final Map<String, StreamSubscription> _subscriptions = {};

  // Cache for frequently accessed data
  final Map<String, List<UserFollowedClub>> _followedClubsCache = {};
  final Map<String, List<Club>> _clubsCache = {};
  Timer? _cacheExpireTimer;

  /// Get current user's Firebase UID
  String? get currentUserId => _authService.currentAppUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => _authService.isAuthenticated;

  // ==========================================
  // CLUB OPERATIONS / KULÜP İŞLEMLERİ
  // ==========================================

  /// Get all available clubs / Tüm mevcut kulüpleri getir
  Future<List<Club>> getAllClubs({
    String? category,
    String? clubType,
    int limit = 50,
  }) async {
    try {
      // Check cache first
      final cacheKey = 'all_clubs_${category ?? 'all'}_${clubType ?? 'all'}';
      if (_clubsCache.containsKey(cacheKey)) {
        debugPrint('📋 UserClubFollowingService: Returning cached clubs');
        return _clubsCache[cacheKey]!;
      }

      debugPrint('🔍 UserClubFollowingService: Fetching all clubs');

      // Simplified query to avoid composite index requirement
      Query query = _firestore
          .collection('clubs')
          .where('status', isEqualTo: 'active')
          .limit(limit * 2); // Get more to filter client-side

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (clubType != null) {
        query = query.where('clubType', isEqualTo: clubType);
      }

      final querySnapshot = await query.get();
      final allClubs = querySnapshot.docs.map((doc) {
        return Club.fromFirestoreData(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Client-side filtering and sorting
      final clubs = allClubs
          .where((club) => club.isActive)
          .toList()
        ..sort((a, b) => b.followerCount.compareTo(a.followerCount));

      // Take only the requested limit
      final limitedClubs = clubs.take(limit).toList();

      // Cache the results
      _clubsCache[cacheKey] = limitedClubs;
      _startCacheExpireTimer();

      debugPrint('✅ UserClubFollowingService: Retrieved ${limitedClubs.length} clubs');
      return limitedClubs;
    } catch (e) {
      debugPrint('❌ UserClubFollowingService: Failed to get clubs - $e');
      return [];
    }
  }

  /// Get club by ID / ID ile kulüp getir
  Future<Club?> getClubById(String clubId) async {
    try {
      debugPrint('🔍 UserClubFollowingService: Fetching club $clubId');

      final clubDoc = await _firestore.collection('clubs').doc(clubId).get();

      if (!clubDoc.exists) {
        debugPrint('❌ UserClubFollowingService: Club $clubId not found');
        return null;
      }

      final club = Club.fromFirestoreData(clubDoc.data()!, clubDoc.id);

      debugPrint('✅ UserClubFollowingService: Retrieved club ${club.name}');
      return club;
    } catch (e) {
      debugPrint('❌ UserClubFollowingService: Failed to get club - $e');
      return null;
    }
  }

  /// Search clubs / Kulüp ara
  Future<List<Club>> searchClubs(String query, {int limit = 30}) async {
    try {
      if (query.isEmpty) return [];

      debugPrint('🔍 UserClubFollowingService: Searching clubs for: $query');

      // For simple implementation, get all clubs and filter client-side
      // In production, you might want to use Algolia or similar service
      final clubs = await getAllClubs(limit: 100);

      final searchQuery = query.toLowerCase();
      final filteredClubs = clubs
          .where((club) {
            return club.name.toLowerCase().contains(searchQuery) ||
                club.displayName.toLowerCase().contains(searchQuery) ||
                club.description.toLowerCase().contains(searchQuery) ||
                club.category.toLowerCase().contains(searchQuery);
          })
          .take(limit)
          .toList();

      debugPrint(
        '✅ UserClubFollowingService: Found ${filteredClubs.length} clubs for query: $query',
      );
      return filteredClubs;
    } catch (e) {
      debugPrint('❌ UserClubFollowingService: Failed to search clubs - $e');
      return [];
    }
  }

  // ==========================================
  // FOLLOWING OPERATIONS / TAKİP İŞLEMLERİ
  // ==========================================

  /// Get user's followed clubs / Kullanıcının takip ettiği kulüpleri getir
  Future<List<UserFollowedClub>> getFollowedClubs([String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        debugPrint('❌ UserClubFollowingService: User not authenticated');
        return [];
      }

      // Check cache first
      final cacheKey = '${uid}_followed_clubs';
      if (_followedClubsCache.containsKey(cacheKey)) {
        debugPrint(
          '📋 UserClubFollowingService: Returning cached followed clubs',
        );
        return _followedClubsCache[cacheKey]!;
      }

      debugPrint(
        '🔍 UserClubFollowingService: Fetching followed clubs for user $uid',
      );

      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('followedClubs')
          .orderBy('followedAt', descending: true)
          .get();

      final followedClubs = querySnapshot.docs.map((doc) {
        return UserFollowedClub.fromFirestoreData(doc.data(), doc.id);
      }).toList();

      // Cache the results
      _followedClubsCache[cacheKey] = followedClubs;
      _startCacheExpireTimer();

      debugPrint(
        '✅ UserClubFollowingService: Retrieved ${followedClubs.length} followed clubs',
      );
      return followedClubs;
    } catch (e) {
      debugPrint(
        '❌ UserClubFollowingService: Failed to get followed clubs - $e',
      );
      return [];
    }
  }

  /// Check if user is following a club / Kullanıcının kulübü takip edip etmediğini kontrol et
  Future<bool> isFollowingClub(String clubId, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) return false;

      debugPrint(
        '🔍 UserClubFollowingService: Checking if user follows club $clubId',
      );

      final followDoc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('followedClubs')
          .doc(clubId)
          .get();

      return followDoc.exists;
    } catch (e) {
      debugPrint(
        '❌ UserClubFollowingService: Failed to check club follow status - $e',
      );
      return false;
    }
  }

  /// Follow/Unfollow a club / Kulübü takip et/takibi bırak
  Future<bool> toggleClubFollow(String clubId, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      debugPrint(
        '🔄 UserClubFollowingService: Toggling follow for club $clubId',
      );

      final batch = _firestore.batch();

      // Check if already following
      final isCurrentlyFollowing = await isFollowingClub(clubId, uid);

      final followRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('followedClubs')
          .doc(clubId);

      if (isCurrentlyFollowing) {
        // Unfollow
        batch.delete(followRef);

        // Update club follower count
        final clubRef = _firestore.collection('clubs').doc(clubId);
        batch.update(clubRef, {
          'followerCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Follow
        // Get club details first
        final clubDoc = await _firestore.collection('clubs').doc(clubId).get();
        if (!clubDoc.exists) {
          throw Exception('Club not found');
        }

        final clubData = clubDoc.data()!;
        final followedClub = UserFollowedClub(
          clubId: clubId,
          clubName:
              clubData['name'] ?? clubData['displayName'] ?? 'Unknown Club',
          clubType: clubData['category'] ?? 'student_club',
          clubAvatar: clubData['logoUrl'],
          followedAt: DateTime.now(),
          notificationsEnabled: true,
          eventCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        batch.set(followRef, followedClub.toFirestoreData());

        // Update club follower count
        final clubRef = _firestore.collection('clubs').doc(clubId);
        batch.update(clubRef, {
          'followerCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Clear cache to force refresh
      _followedClubsCache.remove('${uid}_followed_clubs');
      _clubsCache.clear();

      debugPrint(
        '✅ UserClubFollowingService: Club follow toggled successfully',
      );
      return !isCurrentlyFollowing;
    } catch (e) {
      debugPrint(
        '❌ UserClubFollowingService: Failed to toggle club follow - $e',
      );
      rethrow;
    }
  }

  /// Update notification preferences for a followed club / Takip edilen kulüp için bildirim ayarlarını güncelle
  Future<void> updateClubNotificationPreferences(
    String clubId,
    bool notificationsEnabled, [
    String? userId,
  ]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      debugPrint(
        '🔄 UserClubFollowingService: Updating notification preferences for club $clubId',
      );

      final followRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('followedClubs')
          .doc(clubId);

      // Check if user follows the club
      final followDoc = await followRef.get();
      if (!followDoc.exists) {
        throw Exception('User does not follow this club');
      }

      await followRef.update({
        'notificationsEnabled': notificationsEnabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear cache
      _followedClubsCache.remove('${uid}_followed_clubs');

      debugPrint(
        '✅ UserClubFollowingService: Notification preferences updated successfully',
      );
    } catch (e) {
      debugPrint(
        '❌ UserClubFollowingService: Failed to update notification preferences - $e',
      );
      rethrow;
    }
  }

  // ==========================================
  // REAL-TIME OPERATIONS / GERÇEK ZAMANLI İŞLEMLER
  // ==========================================

  /// Watch followed clubs in real-time / Takip edilen kulüpleri gerçek zamanlı dinle
  Stream<List<UserFollowedClub>> watchFollowedClubs([String? userId]) {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      debugPrint(
        '❌ UserClubFollowingService: Cannot watch followed clubs - user not authenticated',
      );
      return Stream.value([]);
    }

    debugPrint(
      '👁️ UserClubFollowingService: Starting to watch followed clubs for user $uid',
    );

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('followedClubs')
        .orderBy('followedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          final followedClubs = snapshot.docs.map((doc) {
            return UserFollowedClub.fromFirestoreData(doc.data(), doc.id);
          }).toList();

          // Update cache
          _followedClubsCache['${uid}_followed_clubs'] = followedClubs;

          return followedClubs;
        })
        .handleError((error) {
          debugPrint(
            '❌ UserClubFollowingService: Error watching followed clubs - $error',
          );
        });
  }

  /// Watch all clubs in real-time / Tüm kulüpleri gerçek zamanlı dinle
  Stream<List<Club>> watchClubs({
    String? category,
    String? clubType,
    int limit = 50,
  }) {
    debugPrint('👁️ UserClubFollowingService: Starting to watch clubs');

    Query query = _firestore
        .collection('clubs')
        .where('status', isEqualTo: 'active')
        .where('isActive', isEqualTo: true)
        .orderBy('followerCount', descending: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (clubType != null) {
      query = query.where('clubType', isEqualTo: clubType);
    }

    query = query.limit(limit);

    return query
        .snapshots()
        .map((snapshot) {
          final clubs = snapshot.docs.map((doc) {
            return Club.fromFirestoreData(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
          }).toList();

          return clubs;
        })
        .handleError((error) {
          debugPrint(
            '❌ UserClubFollowingService: Error watching clubs - $error',
          );
        });
  }

  // ==========================================
  // UTILITY METHODS / YARDIMCI METODLAR
  // ==========================================

  /// Get club categories / Kulüp kategorilerini getir
  Future<List<String>> getClubCategories() async {
    try {
      debugPrint('🔍 UserClubFollowingService: Fetching club categories');

      final querySnapshot = await _firestore
          .collection('clubs')
          .where('status', isEqualTo: 'active')
          .get();

      final categories = <String>{};
      for (final doc in querySnapshot.docs) {
        final category = doc.data()['category'] as String?;
        if (category != null && category.isNotEmpty) {
          categories.add(category);
        }
      }

      final categoriesList = categories.toList()..sort();

      debugPrint(
        '✅ UserClubFollowingService: Retrieved ${categoriesList.length} categories',
      );
      return categoriesList;
    } catch (e) {
      debugPrint('❌ UserClubFollowingService: Failed to get categories - $e');
      return [];
    }
  }

  /// Get user's club following statistics / Kullanıcının kulüp takip istatistiklerini getir
  Future<ClubFollowingStatistics> getFollowingStatistics([
    String? userId,
  ]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        return const ClubFollowingStatistics(
          totalFollowedClubs: 0,
          clubsByCategory: {},
          totalUpcomingEvents: 0,
          notificationsEnabled: 0,
        );
      }

      debugPrint(
        '🔍 UserClubFollowingService: Fetching following statistics for user $uid',
      );

      final followedClubs = await getFollowedClubs(uid);

      final Map<String, int> clubsByCategory = {};
      int notificationsEnabled = 0;
      int totalUpcomingEvents = 0;

      for (final club in followedClubs) {
        // Count by category/type
        clubsByCategory[club.clubType] =
            (clubsByCategory[club.clubType] ?? 0) + 1;

        // Count notifications enabled
        if (club.notificationsEnabled) {
          notificationsEnabled++;
        }

        // Add event count
        totalUpcomingEvents += club.eventCount;
      }

      final statistics = ClubFollowingStatistics(
        totalFollowedClubs: followedClubs.length,
        clubsByCategory: clubsByCategory,
        totalUpcomingEvents: totalUpcomingEvents,
        notificationsEnabled: notificationsEnabled,
      );

      debugPrint('✅ UserClubFollowingService: Retrieved following statistics');
      return statistics;
    } catch (e) {
      debugPrint(
        '❌ UserClubFollowingService: Failed to get following statistics - $e',
      );
      return const ClubFollowingStatistics(
        totalFollowedClubs: 0,
        clubsByCategory: {},
        totalUpcomingEvents: 0,
        notificationsEnabled: 0,
      );
    }
  }

  /// Clear cache / Cache'i temizle
  void clearCache() {
    _followedClubsCache.clear();
    _clubsCache.clear();
    _cacheExpireTimer?.cancel();
    debugPrint('🧹 UserClubFollowingService: Cache cleared');
  }

  /// Start cache expire timer / Cache süre dolumu timer'ını başlat
  void _startCacheExpireTimer() {
    _cacheExpireTimer?.cancel();
    _cacheExpireTimer = Timer(const Duration(minutes: 5), () {
      clearCache();
    });
  }

  /// Cancel all subscriptions / Tüm subscription'ları iptal et
  void cancelAllSubscriptions() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    debugPrint('🔌 UserClubFollowingService: All subscriptions cancelled');
  }

  /// Dispose service / Servisi temizle
  void dispose() {
    cancelAllSubscriptions();
    clearCache();
    debugPrint('🧹 UserClubFollowingService: Service disposed');
  }
}

/// Club following statistics model
/// Kulüp takip istatistikleri modeli
class ClubFollowingStatistics {
  final int totalFollowedClubs;
  final Map<String, int> clubsByCategory;
  final int totalUpcomingEvents;
  final int notificationsEnabled;

  const ClubFollowingStatistics({
    required this.totalFollowedClubs,
    required this.clubsByCategory,
    required this.totalUpcomingEvents,
    required this.notificationsEnabled,
  });

  @override
  String toString() =>
      'ClubFollowingStatistics{totalFollowedClubs: $totalFollowedClubs, clubsByCategory: $clubsByCategory, totalUpcomingEvents: $totalUpcomingEvents, notificationsEnabled: $notificationsEnabled}';
}

// ==========================================
// CLUB CREATION EXTENSION / KULÜP OLUŞTURMA EKLEMESİ
// ==========================================

extension UserClubFollowingServiceCreation on UserClubFollowingService {
  /// Create a new club / Yeni kulüp oluştur
  Future<String> createClub(Club club) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      debugPrint('📝 UserClubFollowingService: Creating club - ${club.displayName}');

      // Firebase'e kulübü kaydet
      await _firestore
          .collection('clubs')
          .doc(club.clubId)
          .set(club.toFirestoreData());

      // Cache'i temizle
      clearCache();

      debugPrint('✅ UserClubFollowingService: Club created successfully - ${club.clubId}');
      return club.clubId;
    } catch (e) {
      debugPrint('❌ UserClubFollowingService: Failed to create club - $e');
      throw Exception('Failed to create club: $e');
    }
  }

  /// Update an existing club / Mevcut kulübü güncelle
  Future<void> updateClub(String clubId, Club updatedClub) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      debugPrint('📝 UserClubFollowingService: Updating club - $clubId');

      // Kullanıcının kulübü güncelleme yetkisi var mı kontrol et
      final currentClub = await getClubById(clubId);
      if (currentClub == null) {
        throw Exception('Club not found');
      }

      if (!currentClub.adminIds.contains(currentUserId) && 
          !currentClub.moderatorIds.contains(currentUserId)) {
        throw Exception('Unauthorized to update this club');
      }

      // Firebase'de kulübü güncelle (updatedAt ile)
      final updateData = updatedClub.toFirestoreData();
      updateData['updatedAt'] = Timestamp.fromDate(DateTime.now());
      
      await _firestore
          .collection('clubs')
          .doc(clubId)
          .update(updateData);

      // Cache'i temizle
      clearCache();

      debugPrint('✅ UserClubFollowingService: Club updated successfully - $clubId');
    } catch (e) {
      debugPrint('❌ UserClubFollowingService: Failed to update club - $e');
      throw Exception('Failed to update club: $e');
    }
  }

  /// Delete a club / Kulübü sil
  Future<void> deleteClub(String clubId) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    try {
      debugPrint('🗑️ UserClubFollowingService: Deleting club - $clubId');

      // Kullanıcının kulübü silme yetkisi var mı kontrol et
      final currentClub = await getClubById(clubId);
      if (currentClub == null) {
        throw Exception('Club not found');
      }

      if (!currentClub.adminIds.contains(currentUserId)) {
        throw Exception('Unauthorized to delete this club');
      }

      // Firebase'den kulübü sil
      await _firestore
          .collection('clubs')
          .doc(clubId)
          .delete();

      // İlgili takip verilerini de sil
      final batch = _firestore.batch();
      
      final followingQuery = await _firestore
          .collection('user_followed_clubs')
          .where('clubId', isEqualTo: clubId)
          .get();

      for (final doc in followingQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      // Cache'i temizle
      clearCache();

      debugPrint('✅ UserClubFollowingService: Club deleted successfully - $clubId');
    } catch (e) {
      debugPrint('❌ UserClubFollowingService: Failed to delete club - $e');
      throw Exception('Failed to delete club: $e');
    }
  }
}
