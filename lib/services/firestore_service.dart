import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../models/user_model.dart';

/// Firestore veritabanı işlemleri için kapsamlı servis sınıfı
/// Comprehensive service class for Firestore database operations
class FirestoreService {
  // Singleton pattern implementation
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  // Firestore instance / Firestore örneği
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase Auth instance / Firebase Auth örneği
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream subscriptions for memory management / Bellek yönetimi için stream subscriptions
  final Map<String, StreamSubscription> _subscriptions = {};

  // Cache for frequently accessed data / Sık erişilen veriler için önbellek
  final Map<String, dynamic> _cache = {};

  // Error handling / Hata yönetimi
  final StreamController<FirestoreError> _errorController =
      StreamController<FirestoreError>.broadcast();

  Stream<FirestoreError> get errors => _errorController.stream;

  /// Mevcut kullanıcının Firebase UID'sini getir / Get current user's Firebase UID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Kullanıcının kimlik doğrulaması yapılmış mı kontrol et / Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;

  // ==========================================
  // USER OPERATIONS / KULLANICI İŞLEMLERİ
  // ==========================================

  /// Kullanıcı profili oluştur / Create user profile
  Future<void> createUserProfile(AppUser user) async {
    try {
      if (!isAuthenticated) {
        throw FirestoreException(
          'User not authenticated',
          'auth/not-authenticated',
        );
      }

      print(
        '🔥 FirestoreService: Creating user profile for ${user.displayName}',
      );

      final userRef = _firestore.collection('users').doc(currentUserId);

      // Firebase'e uygun veri formatına çevir / Convert to Firebase-compatible format
      final userData = user.toFirestoreData();

      // Zaman damgalarını ayarla / Set timestamps
      userData['createdAt'] = FieldValue.serverTimestamp();
      userData['updatedAt'] = FieldValue.serverTimestamp();
      userData['lastLoginAt'] = FieldValue.serverTimestamp();
      userData['lastActiveAt'] = FieldValue.serverTimestamp();

      await userRef.set(userData, SetOptions(merge: true));

      print('✅ FirestoreService: User profile created successfully');
    } catch (e) {
      print('❌ FirestoreService: Failed to create user profile - $e');
      _handleError('createUserProfile', e);
      rethrow;
    }
  }

  /// Kullanıcı profili güncelle / Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      print('🔄 FirestoreService: Updating user profile for $userId');

      final userRef = _firestore.collection('users').doc(userId);

      // Güncellenme zamanını ekle / Add update timestamp
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await userRef.update(updates);

      // Cache'i güncelle / Update cache
      if (_cache.containsKey('user_$userId')) {
        _cache['user_$userId'] = {..._cache['user_$userId'], ...updates};
      }

      print('✅ FirestoreService: User profile updated successfully');
    } catch (e) {
      print('❌ FirestoreService: Failed to update user profile - $e');
      _handleError('updateUserProfile', e);
      rethrow;
    }
  }

  /// Kullanıcı profilini getir / Get user profile
  Future<AppUser?> getUserProfile(String userId) async {
    try {
      // Önce cache'den kontrol et / Check cache first
      if (_cache.containsKey('user_$userId')) {
        print('📋 FirestoreService: Returning cached user profile for $userId');
        return AppUser.fromFirestoreData(_cache['user_$userId'], userId);
      }

      print('🔍 FirestoreService: Fetching user profile for $userId');

      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print('⚠️ FirestoreService: User profile not found for $userId');
        return null;
      }

      final userData = userDoc.data()!;

      // Cache'e kaydet / Save to cache
      _cache['user_$userId'] = userData;

      print('✅ FirestoreService: User profile retrieved successfully');
      return AppUser.fromFirestoreData(userData, userId);
    } catch (e) {
      print('❌ FirestoreService: Failed to get user profile - $e');
      _handleError('getUserProfile', e);
      return null;
    }
  }

  /// Kullanıcının son aktif zamanını güncelle / Update user's last active time
  Future<void> updateLastActive(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Sessizce hata ver, kritik olmayan işlem / Silent error, non-critical operation
      print('⚠️ FirestoreService: Failed to update last active time - $e');
    }
  }

  /// Kullanıcı profilinde real-time değişiklikleri dinle / Listen to real-time user profile changes
  Stream<AppUser?> watchUserProfile(String userId) {
    print('👁️ FirestoreService: Starting to watch user profile for $userId');

    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;

          final userData = doc.data()!;

          // Cache'i güncelle / Update cache
          _cache['user_$userId'] = userData;

          return AppUser.fromFirestoreData(userData, userId);
        })
        .handleError((error) {
          print('❌ FirestoreService: Error watching user profile - $error');
          _handleError('watchUserProfile', error);
        });
  }

  // ==========================================
  // ANNOUNCEMENT OPERATIONS / DUYURU İŞLEMLERİ
  // ==========================================

  /// Duyuruları kullanıcı rolüne göre getir / Get announcements based on user role
  Future<List<Map<String, dynamic>>> getAnnouncements({
    required List<String> userRoles,
    String? department,
    String? faculty,
    int? year,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      print(
        '📢 FirestoreService: Fetching announcements for roles: $userRoles',
      );

      Query query = _firestore
          .collection('announcements')
          .where('status', isEqualTo: 'published')
          .where(
            'targetAudience.roles',
            arrayContainsAny: [...userRoles, 'all'],
          )
          .orderBy('createdAt', descending: true);

      // Sayfalama desteği / Pagination support
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();

      final announcements = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print(
        '✅ FirestoreService: Retrieved ${announcements.length} announcements',
      );
      return announcements;
    } catch (e) {
      print('❌ FirestoreService: Failed to get announcements - $e');
      _handleError('getAnnouncements', e);
      return [];
    }
  }

  /// Duyuruları real-time olarak dinle / Listen to announcements in real-time
  Stream<List<Map<String, dynamic>>> watchAnnouncements({
    required List<String> userRoles,
    int limit = 20,
  }) {
    print(
      '👁️ FirestoreService: Starting to watch announcements for roles: $userRoles',
    );

    return _firestore
        .collection('announcements')
        .where('status', isEqualTo: 'published')
        .where('targetAudience.roles', arrayContainsAny: [...userRoles, 'all'])
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        })
        .handleError((error) {
          print('❌ FirestoreService: Error watching announcements - $error');
          _handleError('watchAnnouncements', error);
        });
  }

  /// Duyuru oluştur (Admin/Staff için) / Create announcement (for Admin/Staff)
  Future<String> createAnnouncement(
    Map<String, dynamic> announcementData,
  ) async {
    try {
      if (!isAuthenticated) {
        throw FirestoreException(
          'User not authenticated',
          'auth/not-authenticated',
        );
      }

      print('📝 FirestoreService: Creating new announcement');

      // Zaman damgalarını ve yazar bilgilerini ekle / Add timestamps and author info
      announcementData['createdAt'] = FieldValue.serverTimestamp();
      announcementData['updatedAt'] = FieldValue.serverTimestamp();
      announcementData['createdBy'] = currentUserId;
      announcementData['viewCount'] = 0;
      announcementData['likeCount'] = 0;
      announcementData['commentCount'] = 0;
      announcementData['shareCount'] = 0;

      final docRef = await _firestore
          .collection('announcements')
          .add(announcementData);

      print('✅ FirestoreService: Announcement created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ FirestoreService: Failed to create announcement - $e');
      _handleError('createAnnouncement', e);
      rethrow;
    }
  }

  /// Duyuru görüntüleme sayısını artır / Increment announcement view count
  Future<void> incrementAnnouncementViews(String announcementId) async {
    try {
      await _firestore.collection('announcements').doc(announcementId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      // Sessizce hata ver / Silent error
      print('⚠️ FirestoreService: Failed to increment announcement views - $e');
    }
  }

  // ==========================================
  // CAFETERIA OPERATIONS / KAFETERYA İŞLEMLERİ
  // ==========================================

  /// Belirli tarih için kafeterya menüsünü getir / Get cafeteria menu for specific date
  Future<Map<String, dynamic>?> getCafeteriaMenu(String date) async {
    try {
      print('🍽️ FirestoreService: Fetching cafeteria menu for $date');

      // Önce cache'den kontrol et / Check cache first
      if (_cache.containsKey('menu_$date')) {
        print('📋 FirestoreService: Returning cached cafeteria menu for $date');
        return _cache['menu_$date'];
      }

      final menuDoc = await _firestore.collection('cafeteria').doc(date).get();

      if (!menuDoc.exists) {
        print('⚠️ FirestoreService: Cafeteria menu not found for $date');
        return null;
      }

      final menuData = menuDoc.data()!;
      menuData['id'] = menuDoc.id;

      // Cache'e kaydet / Save to cache
      _cache['menu_$date'] = menuData;

      print('✅ FirestoreService: Cafeteria menu retrieved successfully');
      return menuData;
    } catch (e) {
      print('❌ FirestoreService: Failed to get cafeteria menu - $e');
      _handleError('getCafeteriaMenu', e);
      return null;
    }
  }

  /// Haftalık kafeterya menülerini getir / Get weekly cafeteria menus
  Future<List<Map<String, dynamic>>> getWeeklyCafeteriaMenus(
    DateTime startDate,
  ) async {
    try {
      print(
        '📅 FirestoreService: Fetching weekly cafeteria menus starting from $startDate',
      );

      final List<Map<String, dynamic>> weeklyMenus = [];

      // 7 günlük menüleri getir / Get 7 days of menus
      for (int i = 0; i < 7; i++) {
        final date = startDate.add(Duration(days: i));
        final dateString =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        final menu = await getCafeteriaMenu(dateString);
        if (menu != null) {
          weeklyMenus.add(menu);
        }
      }

      print('✅ FirestoreService: Retrieved ${weeklyMenus.length} weekly menus');
      return weeklyMenus;
    } catch (e) {
      print('❌ FirestoreService: Failed to get weekly cafeteria menus - $e');
      _handleError('getWeeklyCafeteriaMenus', e);
      return [];
    }
  }

  /// Kafeterya menüsü değişikliklerini real-time dinle / Listen to cafeteria menu changes in real-time
  Stream<Map<String, dynamic>?> watchCafeteriaMenu(String date) {
    print('👁️ FirestoreService: Starting to watch cafeteria menu for $date');

    return _firestore
        .collection('cafeteria')
        .doc(date)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;

          final menuData = doc.data()!;
          menuData['id'] = doc.id;

          // Cache'i güncelle / Update cache
          _cache['menu_$date'] = menuData;

          return menuData;
        })
        .handleError((error) {
          print('❌ FirestoreService: Error watching cafeteria menu - $error');
          _handleError('watchCafeteriaMenu', error);
        });
  }

  // ==========================================
  // CALENDAR OPERATIONS / TAKVİM İŞLEMLERİ
  // ==========================================

  /// Etkinlikleri kullanıcı rolüne göre getir / Get events based on user role
  Future<List<Map<String, dynamic>>> getCalendarEvents({
    required List<String> userRoles,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? eventTypes,
    int limit = 50,
  }) async {
    try {
      print(
        '📅 FirestoreService: Fetching calendar events for roles: $userRoles',
      );

      Query query = _firestore
          .collection('calendar')
          .where(
            'targetAudience.roles',
            arrayContainsAny: [...userRoles, 'all'],
          );

      // Tarih aralığı filtresi / Date range filter
      if (startDate != null) {
        query = query.where(
          'startDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'startDate',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      // Etkinlik türü filtresi / Event type filter
      if (eventTypes != null && eventTypes.isNotEmpty) {
        query = query.where('type', whereIn: eventTypes);
      }

      query = query.orderBy('startDate').limit(limit);

      final querySnapshot = await query.get();

      final events = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      print('✅ FirestoreService: Retrieved ${events.length} calendar events');
      return events;
    } catch (e) {
      print('❌ FirestoreService: Failed to get calendar events - $e');
      _handleError('getCalendarEvents', e);
      return [];
    }
  }

  /// Takvim etkinliklerini real-time dinle / Listen to calendar events in real-time
  Stream<List<Map<String, dynamic>>> watchCalendarEvents({
    required List<String> userRoles,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
  }) {
    print(
      '👁️ FirestoreService: Starting to watch calendar events for roles: $userRoles',
    );

    Query query = _firestore
        .collection('calendar')
        .where('targetAudience.roles', arrayContainsAny: [...userRoles, 'all']);

    if (startDate != null) {
      query = query.where(
        'startDate',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'startDate',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    return query
        .orderBy('startDate')
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();
        })
        .handleError((error) {
          print('❌ FirestoreService: Error watching calendar events - $error');
          _handleError('watchCalendarEvents', error);
        });
  }

  // ==========================================
  // GRADES OPERATIONS / NOT İŞLEMLERİ
  // ==========================================

  /// Öğrenci notlarını getir / Get student grades
  Future<Map<String, dynamic>?> getStudentGrades(String userId) async {
    try {
      print('📊 FirestoreService: Fetching grades for student $userId');

      // Sadece kendi notlarını görme izni kontrolü / Permission check - only own grades
      if (currentUserId != userId) {
        throw FirestoreException(
          'Unauthorized access to grades',
          'auth/unauthorized',
        );
      }

      final gradesDoc = await _firestore.collection('grades').doc(userId).get();

      if (!gradesDoc.exists) {
        print('⚠️ FirestoreService: Grades not found for student $userId');
        return null;
      }

      final gradesData = gradesDoc.data()!;
      gradesData['id'] = gradesDoc.id;

      print('✅ FirestoreService: Student grades retrieved successfully');
      return gradesData;
    } catch (e) {
      print('❌ FirestoreService: Failed to get student grades - $e');
      _handleError('getStudentGrades', e);
      return null;
    }
  }

  /// Öğrenci notlarını real-time dinle / Listen to student grades in real-time
  Stream<Map<String, dynamic>?> watchStudentGrades(String userId) {
    print('👁️ FirestoreService: Starting to watch grades for student $userId');

    // Sadece kendi notlarını görme izni kontrolü / Permission check - only own grades
    if (currentUserId != userId) {
      return Stream.error(
        FirestoreException(
          'Unauthorized access to grades',
          'auth/unauthorized',
        ),
      );
    }

    return _firestore
        .collection('grades')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;

          final gradesData = doc.data()!;
          gradesData['id'] = doc.id;

          return gradesData;
        })
        .handleError((error) {
          print('❌ FirestoreService: Error watching student grades - $error');
          _handleError('watchStudentGrades', error);
        });
  }

  // ==========================================
  // BATCH OPERATIONS / TOPLU İŞLEMLER
  // ==========================================

  /// Toplu yazma işlemi / Batch write operation
  Future<void> performBatchWrite(List<BatchOperation> operations) async {
    try {
      print(
        '⚡ FirestoreService: Performing batch write with ${operations.length} operations',
      );

      final batch = _firestore.batch();

      for (final operation in operations) {
        switch (operation.type) {
          case BatchOperationType.create:
            batch.set(operation.reference, operation.data!);
            break;
          case BatchOperationType.update:
            batch.update(operation.reference, operation.data!);
            break;
          case BatchOperationType.delete:
            batch.delete(operation.reference);
            break;
        }
      }

      await batch.commit();

      print('✅ FirestoreService: Batch write completed successfully');
    } catch (e) {
      print('❌ FirestoreService: Failed to perform batch write - $e');
      _handleError('performBatchWrite', e);
      rethrow;
    }
  }

  // ==========================================
  // UTILITY METHODS / YARDIMCI METODLAR
  // ==========================================

  /// Cache'i temizle / Clear cache
  void clearCache() {
    _cache.clear();
    print('🧹 FirestoreService: Cache cleared');
  }

  /// Belirli cache anahtarını temizle / Clear specific cache key
  void clearCacheKey(String key) {
    _cache.remove(key);
    print('🧹 FirestoreService: Cache key cleared: $key');
  }

  /// Tüm stream subscription'ları iptal et / Cancel all stream subscriptions
  void cancelAllSubscriptions() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    print('🔌 FirestoreService: All subscriptions cancelled');
  }

  /// Hata işleme / Error handling
  void _handleError(String operation, dynamic error) {
    final firestoreError = FirestoreError(
      operation: operation,
      message: error.toString(),
      timestamp: DateTime.now(),
    );

    _errorController.add(firestoreError);
  }

  /// Servisi temizle / Dispose service
  void dispose() {
    cancelAllSubscriptions();
    _errorController.close();
    clearCache();
    print('🧹 FirestoreService: Service disposed');
  }
}

// ==========================================
// SUPPORTING CLASSES / DESTEKLEYICI SINIFLAR
// ==========================================

/// Toplu işlem türleri / Batch operation types
enum BatchOperationType { create, update, delete }

/// Toplu işlem sınıfı / Batch operation class
class BatchOperation {
  final BatchOperationType type;
  final DocumentReference reference;
  final Map<String, dynamic>? data;

  BatchOperation({required this.type, required this.reference, this.data});
}

/// Firestore hata sınıfı / Firestore error class
class FirestoreError {
  final String operation;
  final String message;
  final DateTime timestamp;

  FirestoreError({
    required this.operation,
    required this.message,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'FirestoreError[$operation]: $message at ${timestamp.toIso8601String()}';
  }
}

/// Firestore exception sınıfı / Firestore exception class
class FirestoreException implements Exception {
  final String message;
  final String code;

  FirestoreException(this.message, this.code);

  @override
  String toString() {
    return 'FirestoreException[$code]: $message';
  }
}
