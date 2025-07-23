import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'club_chat_service.dart';

/// Service for automatic cleanup of expired data
/// Süresi dolmuş verilerin otomatik temizliği için servis
class CleanupService {
  // Singleton pattern implementation
  static final CleanupService _instance = CleanupService._internal();
  factory CleanupService() => _instance;
  CleanupService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ClubChatService _chatService = ClubChatService();

  // Cleanup timer
  Timer? _cleanupTimer;
  static const Duration _cleanupInterval = Duration(hours: 6); // Run every 6 hours

  // Batch size for cleanup operations to avoid performance issues
  static const int _batchSize = 100;

  /// Start automatic cleanup service
  /// Otomatik temizlik servisini başlat
  void startCleanupService() {
    // Clean up immediately on start
    performCleanup();

    // Schedule periodic cleanup
    _cleanupTimer = Timer.periodic(_cleanupInterval, (timer) {
      performCleanup();
    });

    debugPrint('🧹 CleanupService: Automatic cleanup service started');
  }

  /// Stop automatic cleanup service
  /// Otomatik temizlik servisini durdur
  void stopCleanupService() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    debugPrint('🛑 CleanupService: Automatic cleanup service stopped');
  }

  /// Perform all cleanup operations
  /// Tüm temizlik işlemlerini gerçekleştir
  Future<void> performCleanup() async {
    try {
      debugPrint('🧹 CleanupService: Starting cleanup operations');

      // Run cleanup operations in parallel for better performance
      await Future.wait([
        cleanupExpiredChatMessages(),
        cleanupExpiredApprovalRequests(),
        cleanupExpiredNotifications(),
        cleanupOrphanedData(),
      ]);

      debugPrint('✅ CleanupService: All cleanup operations completed');
    } catch (e) {
      debugPrint('❌ CleanupService: Error during cleanup: $e');
    }
  }

  /// Clean up expired chat messages (7-day retention)
  /// Süresi dolmuş sohbet mesajlarını temizle (7 günlük saklama)
  Future<void> cleanupExpiredChatMessages() async {
    try {
      debugPrint('🧹 CleanupService: Cleaning expired chat messages');

      final now = DateTime.now();
      int totalCleaned = 0;
      bool hasMore = true;

      while (hasMore) {
        // Query expired messages in batches
        final expiredMessages = await _firestore
            .collection('chat_messages')
            .where('expiresAt', isLessThan: Timestamp.fromDate(now))
            .limit(_batchSize)
            .get();

        if (expiredMessages.docs.isEmpty) {
          hasMore = false;
          break;
        }

        // Delete batch
        final batch = _firestore.batch();
        for (final doc in expiredMessages.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        totalCleaned += expiredMessages.docs.length;

        // Add small delay to avoid overwhelming Firestore
        await Future.delayed(const Duration(milliseconds: 100));
      }

      debugPrint('✅ CleanupService: Cleaned $totalCleaned expired chat messages');
    } catch (e) {
      debugPrint('❌ CleanupService: Error cleaning chat messages: $e');
    }
  }

  /// Clean up expired approval requests (30-day retention)
  /// Süresi dolmuş onay taleplerini temizle (30 günlük saklama)
  Future<void> cleanupExpiredApprovalRequests() async {
    try {
      debugPrint('🧹 CleanupService: Cleaning expired approval requests');

      final now = DateTime.now();
      int totalCleaned = 0;
      bool hasMore = true;

      while (hasMore) {
        // Query expired approvals in batches
        final expiredApprovals = await _firestore
            .collection('pending_approvals')
            .where('expiresAt', isLessThan: Timestamp.fromDate(now))
            .limit(_batchSize)
            .get();

        if (expiredApprovals.docs.isEmpty) {
          hasMore = false;
          break;
        }

        // Delete batch
        final batch = _firestore.batch();
        for (final doc in expiredApprovals.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        totalCleaned += expiredApprovals.docs.length;

        // Add small delay to avoid overwhelming Firestore
        await Future.delayed(const Duration(milliseconds: 100));
      }

      debugPrint('✅ CleanupService: Cleaned $totalCleaned expired approval requests');
    } catch (e) {
      debugPrint('❌ CleanupService: Error cleaning approval requests: $e');
    }
  }

  /// Clean up expired notifications (30-day retention)
  /// Süresi dolmuş bildirimleri temizle (30 günlük saklama)
  Future<void> cleanupExpiredNotifications() async {
    try {
      debugPrint('🧹 CleanupService: Cleaning expired notifications');

      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      int totalCleaned = 0;
      bool hasMore = true;

      while (hasMore) {
        // Query old notifications in batches
        final oldNotifications = await _firestore
            .collection('notifications')
            .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
            .limit(_batchSize)
            .get();

        if (oldNotifications.docs.isEmpty) {
          hasMore = false;
          break;
        }

        // Delete batch
        final batch = _firestore.batch();
        for (final doc in oldNotifications.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        totalCleaned += oldNotifications.docs.length;

        // Add small delay
        await Future.delayed(const Duration(milliseconds: 100));
      }

      debugPrint('✅ CleanupService: Cleaned $totalCleaned expired notifications');
    } catch (e) {
      debugPrint('❌ CleanupService: Error cleaning notifications: $e');
    }
  }

  /// Clean up orphaned data (data without valid references)
  /// Yetim verileri temizle (geçerli referansları olmayan veriler)
  Future<void> cleanupOrphanedData() async {
    try {
      debugPrint('🧹 CleanupService: Cleaning orphaned data');

      await Future.wait([
        _cleanupOrphanedChatParticipants(),
        _cleanupOrphanedComments(),
        _cleanupOrphanedInteractions(),
      ]);

      debugPrint('✅ CleanupService: Orphaned data cleanup completed');
    } catch (e) {
      debugPrint('❌ CleanupService: Error cleaning orphaned data: $e');
    }
  }

  /// Clean up chat participants for non-existent chat rooms
  /// Mevcut olmayan sohbet odaları için sohbet katılımcılarını temizle
  Future<void> _cleanupOrphanedChatParticipants() async {
    try {
      // Get all chat participants
      final participants = await _firestore
          .collection('chat_participants')
          .limit(_batchSize)
          .get();

      if (participants.docs.isEmpty) return;

      final batch = _firestore.batch();
      int toDelete = 0;

      for (final participantDoc in participants.docs) {
        final data = participantDoc.data();
        final chatRoomId = data['chatRoomId'] as String?;

        if (chatRoomId == null) {
          batch.delete(participantDoc.reference);
          toDelete++;
          continue;
        }

        // Check if chat room exists
        final chatRoom = await _firestore
            .collection('chat_rooms')
            .doc(chatRoomId)
            .get();

        if (!chatRoom.exists) {
          batch.delete(participantDoc.reference);
          toDelete++;
        }
      }

      if (toDelete > 0) {
        await batch.commit();
        debugPrint('✅ CleanupService: Cleaned $toDelete orphaned chat participants');
      }
    } catch (e) {
      debugPrint('❌ CleanupService: Error cleaning orphaned chat participants: $e');
    }
  }

  /// Clean up comments for non-existent events
  /// Mevcut olmayan etkinlikler için yorumları temizle
  Future<void> _cleanupOrphanedComments() async {
    try {
      // Get all comments
      final comments = await _firestore
          .collection('event_comments')
          .limit(_batchSize)
          .get();

      if (comments.docs.isEmpty) return;

      final batch = _firestore.batch();
      int toDelete = 0;

      for (final commentDoc in comments.docs) {
        final data = commentDoc.data();
        final eventId = data['eventId'] as String?;

        if (eventId == null) {
          batch.delete(commentDoc.reference);
          toDelete++;
          continue;
        }

        // Check if event exists
        final event = await _firestore
            .collection('events')
            .doc(eventId)
            .get();

        if (!event.exists) {
          batch.delete(commentDoc.reference);
          toDelete++;
        }
      }

      if (toDelete > 0) {
        await batch.commit();
        debugPrint('✅ CleanupService: Cleaned $toDelete orphaned comments');
      }
    } catch (e) {
      debugPrint('❌ CleanupService: Error cleaning orphaned comments: $e');
    }
  }

  /// Clean up interactions for non-existent events
  /// Mevcut olmayan etkinlikler için etkileşimleri temizle
  Future<void> _cleanupOrphanedInteractions() async {
    try {
      // Get all user interactions
      final interactions = await _firestore
          .collection('user_event_interactions')
          .limit(_batchSize)
          .get();

      if (interactions.docs.isEmpty) return;

      final batch = _firestore.batch();
      int toDelete = 0;

      for (final interactionDoc in interactions.docs) {
        final data = interactionDoc.data();
        final eventId = data['eventId'] as String?;

        if (eventId == null) {
          batch.delete(interactionDoc.reference);
          toDelete++;
          continue;
        }

        // Check if event exists
        final event = await _firestore
            .collection('events')
            .doc(eventId)
            .get();

        if (!event.exists) {
          batch.delete(interactionDoc.reference);
          toDelete++;
        }
      }

      if (toDelete > 0) {
        await batch.commit();
        debugPrint('✅ CleanupService: Cleaned $toDelete orphaned interactions');
      }
    } catch (e) {
      debugPrint('❌ CleanupService: Error cleaning orphaned interactions: $e');
    }
  }

  /// Manual cleanup for specific club
  /// Belirli kulüp için manuel temizlik
  Future<void> cleanupClubData(String clubId) async {
    try {
      debugPrint('🧹 CleanupService: Manual cleanup for club $clubId');

      await Future.wait([
        _cleanupClubChatMessages(clubId),
        _cleanupClubApprovals(clubId),
        _cleanupClubParticipants(clubId),
      ]);

      debugPrint('✅ CleanupService: Manual cleanup completed for club $clubId');
    } catch (e) {
      debugPrint('❌ CleanupService: Error during manual cleanup: $e');
    }
  }

  /// Clean up all chat messages for a specific club
  /// Belirli kulüp için tüm sohbet mesajlarını temizle
  Future<void> _cleanupClubChatMessages(String clubId) async {
    try {
      bool hasMore = true;
      int totalCleaned = 0;

      while (hasMore) {
        final messages = await _firestore
            .collection('chat_messages')
            .where('clubId', isEqualTo: clubId)
            .limit(_batchSize)
            .get();

        if (messages.docs.isEmpty) {
          hasMore = false;
          break;
        }

        final batch = _firestore.batch();
        for (final doc in messages.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        totalCleaned += messages.docs.length;
      }

      if (totalCleaned > 0) {
        debugPrint('✅ CleanupService: Cleaned $totalCleaned messages for club $clubId');
      }
    } catch (e) {
      debugPrint('❌ CleanupService: Error cleaning club messages: $e');
    }
  }

  /// Clean up all approvals for a specific club
  /// Belirli kulüp için tüm onayları temizle
  Future<void> _cleanupClubApprovals(String clubId) async {
    try {
      bool hasMore = true;
      int totalCleaned = 0;

      while (hasMore) {
        final approvals = await _firestore
            .collection('pending_approvals')
            .where('clubId', isEqualTo: clubId)
            .limit(_batchSize)
            .get();

        if (approvals.docs.isEmpty) {
          hasMore = false;
          break;
        }

        final batch = _firestore.batch();
        for (final doc in approvals.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        totalCleaned += approvals.docs.length;
      }

      if (totalCleaned > 0) {
        debugPrint('✅ CleanupService: Cleaned $totalCleaned approvals for club $clubId');
      }
    } catch (e) {
      debugPrint('❌ CleanupService: Error cleaning club approvals: $e');
    }
  }

  /// Clean up all participants for a specific club
  /// Belirli kulüp için tüm katılımcıları temizle
  Future<void> _cleanupClubParticipants(String clubId) async {
    try {
      bool hasMore = true;
      int totalCleaned = 0;

      while (hasMore) {
        final participants = await _firestore
            .collection('chat_participants')
            .where('clubId', isEqualTo: clubId)
            .limit(_batchSize)
            .get();

        if (participants.docs.isEmpty) {
          hasMore = false;
          break;
        }

        final batch = _firestore.batch();
        for (final doc in participants.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        totalCleaned += participants.docs.length;
      }

      if (totalCleaned > 0) {
        debugPrint('✅ CleanupService: Cleaned $totalCleaned participants for club $clubId');
      }
    } catch (e) {
      debugPrint('❌ CleanupService: Error cleaning club participants: $e');
    }
  }

  /// Get cleanup statistics
  /// Temizlik istatistiklerini al
  Future<Map<String, int>> getCleanupStatistics() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final futures = await Future.wait([
        // Expired messages count
        _firestore
            .collection('chat_messages')
            .where('expiresAt', isLessThan: Timestamp.fromDate(now))
            .count()
            .get(),
        
        // Expired approvals count
        _firestore
            .collection('pending_approvals')
            .where('expiresAt', isLessThan: Timestamp.fromDate(now))
            .count()
            .get(),
        
        // Old notifications count
        _firestore
            .collection('notifications')
            .where('createdAt', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
            .count()
            .get(),
      ]);

      return {
        'expiredMessages': futures[0].count ?? 0,
        'expiredApprovals': futures[1].count ?? 0,
        'oldNotifications': futures[2].count ?? 0,
      };
    } catch (e) {
      debugPrint('❌ CleanupService: Error getting cleanup statistics: $e');
      return {};
    }
  }

  /// Check if cleanup service is running
  /// Temizlik servisinin çalışıp çalışmadığını kontrol et
  bool get isRunning => _cleanupTimer?.isActive ?? false;

  /// Get time until next cleanup
  /// Bir sonraki temizliğe kalan süreyi al
  Duration? get timeUntilNextCleanup {
    if (_cleanupTimer == null) return null;
    
    // This is an approximation since we can't get exact timer remaining time
    return _cleanupInterval;
  }

  /// Dispose service and stop cleanup
  /// Servisi kapat ve temizliği durdur
  void dispose() {
    stopCleanupService();
    debugPrint('🔥 CleanupService: Service disposed');
  }
}