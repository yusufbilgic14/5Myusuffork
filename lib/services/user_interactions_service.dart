import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../models/user_interaction_models.dart';
import 'firebase_auth_service.dart';

/// User interactions management service for comments, likes, and follows
/// Kullanıcı etkileşimleri yönetim servisi - yorumlar, beğeniler ve takipler
class UserInteractionsService {
  // Singleton pattern implementation
  static final UserInteractionsService _instance = UserInteractionsService._internal();
  factory UserInteractionsService() => _instance;
  UserInteractionsService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Stream subscriptions for memory management
  final Map<String, StreamSubscription> _subscriptions = {};

  // Cache for frequently accessed data
  final Map<String, List<EventComment>> _commentsCache = {};
  final Map<String, List<CommentLike>> _likesCache = {};
  Timer? _cacheExpireTimer;

  /// Get current user's Firebase UID
  String? get currentUserId => _authService.currentAppUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => _authService.isAuthenticated;

  // ==========================================
  // COMMENTS OPERATIONS / YORUM İŞLEMLERİ
  // ==========================================

  /// Get comments for an event / Etkinlik yorumlarını getir
  Future<List<EventComment>> getEventComments(String eventId, {
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      // Check cache first
      final cacheKey = '${eventId}_comments';
      if (_commentsCache.containsKey(cacheKey) && startAfter == null) {
        debugPrint('📋 UserInteractionsService: Returning cached comments for $eventId');
        return _commentsCache[cacheKey]!;
      }

      debugPrint('🔍 UserInteractionsService: Fetching comments for event $eventId');
      
      Query query = _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: false);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      final querySnapshot = await query.get();
      final comments = querySnapshot.docs.map((doc) {
        return EventComment.fromFirestoreData(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Cache the results if this is the first page
      if (startAfter == null) {
        _commentsCache[cacheKey] = comments;
        _startCacheExpireTimer();
      }

      debugPrint('✅ UserInteractionsService: Retrieved ${comments.length} comments');
      return comments;
    } catch (e) {
      debugPrint('❌ UserInteractionsService: Failed to get event comments - $e');
      return [];
    }
  }

  /// Get replies for a comment / Yorum için cevapları getir
  Future<List<EventComment>> getCommentReplies(String eventId, String parentCommentId, {
    int limit = 20,
  }) async {
    try {
      debugPrint('🔍 UserInteractionsService: Fetching replies for comment $parentCommentId');
      
      final querySnapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .where('parentCommentId', isEqualTo: parentCommentId)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: false)
          .limit(limit)
          .get();

      final replies = querySnapshot.docs.map((doc) {
        return EventComment.fromFirestoreData(doc.data(), doc.id);
      }).toList();

      debugPrint('✅ UserInteractionsService: Retrieved ${replies.length} replies');
      return replies;
    } catch (e) {
      debugPrint('❌ UserInteractionsService: Failed to get comment replies - $e');
      return [];
    }
  }

  /// Add a comment to an event / Etkinliğe yorum ekle
  Future<String?> addComment(String eventId, String content, {
    String? parentCommentId,
    List<String>? mediaUrls,
    String? userId,
  }) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('🔄 UserInteractionsService: Adding comment to event $eventId');

      final batch = _firestore.batch();
      
      // Get user information (you might want to implement a user service for this)
      final userDisplayName = _authService.currentAppUser?.displayName ?? 'Anonymous User';
      
      // Create comment document
      final commentRef = _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .doc();

      final replyLevel = parentCommentId != null ? 1 : 0; // Simple 2-level comment system
      
      final comment = EventComment(
        commentId: commentRef.id,
        eventId: eventId,
        content: content,
        contentType: mediaUrls != null && mediaUrls.isNotEmpty ? 'text_with_media' : 'text',
        mediaUrls: mediaUrls,
        authorId: uid,
        authorName: userDisplayName,
        parentCommentId: parentCommentId,
        replyLevel: replyLevel,
        replyCount: 0,
        likeCount: 0,
        status: CommentStatus.active,
        isEdited: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      batch.set(commentRef, comment.toFirestoreData());

      // Update event comment count
      final eventRef = _firestore.collection('events').doc(eventId);
      batch.update(eventRef, {
        'commentCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If this is a reply, update parent comment reply count
      if (parentCommentId != null) {
        final parentCommentRef = _firestore
            .collection('events')
            .doc(eventId)
            .collection('comments')
            .doc(parentCommentId);
        
        batch.update(parentCommentRef, {
          'replyCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Clear cache to force refresh
      _commentsCache.remove('${eventId}_comments');

      debugPrint('✅ UserInteractionsService: Comment added successfully with ID: ${commentRef.id}');
      return commentRef.id;
    } catch (e) {
      debugPrint('❌ UserInteractionsService: Failed to add comment - $e');
      rethrow;
    }
  }

  /// Edit a comment / Yorumu düzenle
  Future<void> editComment(String eventId, String commentId, String newContent, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('🔄 UserInteractionsService: Editing comment $commentId');

      final commentRef = _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .doc(commentId);

      // Check if user owns the comment
      final commentDoc = await commentRef.get();
      if (!commentDoc.exists) {
        throw Exception('Comment not found');
      }

      final commentData = commentDoc.data()!;
      if (commentData['authorId'] != uid) {
        throw Exception('Not authorized to edit this comment');
      }

      await commentRef.update({
        'content': newContent,
        'isEdited': true,
        'editedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Clear cache
      _commentsCache.remove('${eventId}_comments');

      debugPrint('✅ UserInteractionsService: Comment edited successfully');
    } catch (e) {
      debugPrint('❌ UserInteractionsService: Failed to edit comment - $e');
      rethrow;
    }
  }

  /// Delete a comment / Yorumu sil
  Future<void> deleteComment(String eventId, String commentId, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('🔄 UserInteractionsService: Deleting comment $commentId');

      final batch = _firestore.batch();
      
      final commentRef = _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .doc(commentId);

      // Check if user owns the comment
      final commentDoc = await commentRef.get();
      if (!commentDoc.exists) {
        throw Exception('Comment not found');
      }

      final commentData = commentDoc.data()!;
      if (commentData['authorId'] != uid) {
        throw Exception('Not authorized to delete this comment');
      }

      // Mark as deleted instead of actually deleting
      batch.update(commentRef, {
        'status': 'deleted',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update event comment count
      final eventRef = _firestore.collection('events').doc(eventId);
      batch.update(eventRef, {
        'commentCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If this comment has a parent, update parent reply count
      final parentCommentId = commentData['parentCommentId'];
      if (parentCommentId != null) {
        final parentCommentRef = _firestore
            .collection('events')
            .doc(eventId)
            .collection('comments')
            .doc(parentCommentId);
        
        batch.update(parentCommentRef, {
          'replyCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Clear cache
      _commentsCache.remove('${eventId}_comments');

      debugPrint('✅ UserInteractionsService: Comment deleted successfully');
    } catch (e) {
      debugPrint('❌ UserInteractionsService: Failed to delete comment - $e');
      rethrow;
    }
  }

  // ==========================================
  // COMMENT LIKES / YORUM BEĞENİLERİ
  // ==========================================

  /// Get likes for a comment / Yorum beğenilerini getir
  Future<List<CommentLike>> getCommentLikes(String eventId, String commentId, {
    int limit = 50,
  }) async {
    try {
      // Check cache first
      final cacheKey = '${eventId}_${commentId}_likes';
      if (_likesCache.containsKey(cacheKey)) {
        debugPrint('📋 UserInteractionsService: Returning cached likes for comment $commentId');
        return _likesCache[cacheKey]!;
      }

      debugPrint('🔍 UserInteractionsService: Fetching likes for comment $commentId');
      
      final querySnapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .doc(commentId)
          .collection('likes')
          .orderBy('likedAt', descending: true)
          .limit(limit)
          .get();

      final likes = querySnapshot.docs.map((doc) {
        return CommentLike.fromFirestoreData(doc.data(), doc.id);
      }).toList();

      // Cache the results
      _likesCache[cacheKey] = likes;
      _startCacheExpireTimer();

      debugPrint('✅ UserInteractionsService: Retrieved ${likes.length} likes');
      return likes;
    } catch (e) {
      debugPrint('❌ UserInteractionsService: Failed to get comment likes - $e');
      return [];
    }
  }

  /// Check if user has liked a comment / Kullanıcının yorumu beğenip beğenmediğini kontrol et
  Future<bool> hasUserLikedComment(String eventId, String commentId, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) return false;

      debugPrint('🔍 UserInteractionsService: Checking if user liked comment $commentId');
      
      final likeDoc = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .doc(commentId)
          .collection('likes')
          .doc(uid)
          .get();

      return likeDoc.exists;
    } catch (e) {
      debugPrint('❌ UserInteractionsService: Failed to check comment like - $e');
      return false;
    }
  }

  /// Toggle like on a comment / Yorum beğenisini değiştir
  Future<bool> toggleCommentLike(String eventId, String commentId, [String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('🔄 UserInteractionsService: Toggling like for comment $commentId');

      final batch = _firestore.batch();
      
      // Check if already liked
      final likeRef = _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .doc(commentId)
          .collection('likes')
          .doc(uid);

      final likeDoc = await likeRef.get();
      final isCurrentlyLiked = likeDoc.exists;

      if (isCurrentlyLiked) {
        // Unlike
        batch.delete(likeRef);
        
        // Update comment like count
        final commentRef = _firestore
            .collection('events')
            .doc(eventId)
            .collection('comments')
            .doc(commentId);
        
        batch.update(commentRef, {
          'likeCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Like
        final userDisplayName = _authService.currentAppUser?.displayName ?? 'Anonymous User';
        
        final commentLike = CommentLike(
          commentId: commentId,
          userId: uid,
          userName: userDisplayName,
          likedAt: DateTime.now(),
        );

        batch.set(likeRef, commentLike.toFirestoreData());
        
        // Update comment like count
        final commentRef = _firestore
            .collection('events')
            .doc(eventId)
            .collection('comments')
            .doc(commentId);
        
        batch.update(commentRef, {
          'likeCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Clear caches
      _likesCache.remove('${eventId}_${commentId}_likes');
      _commentsCache.remove('${eventId}_comments');

      debugPrint('✅ UserInteractionsService: Comment like toggled successfully');
      return !isCurrentlyLiked;
    } catch (e) {
      debugPrint('❌ UserInteractionsService: Failed to toggle comment like - $e');
      rethrow;
    }
  }

  // ==========================================
  // REAL-TIME OPERATIONS / GERÇEK ZAMANLI İŞLEMLER
  // ==========================================

  /// Watch comments for an event in real-time / Etkinlik yorumlarını gerçek zamanlı dinle
  Stream<List<EventComment>> watchEventComments(String eventId, {int limit = 50}) {
    debugPrint('👁️ UserInteractionsService: Starting to watch comments for event $eventId');
    
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final comments = snapshot.docs.map((doc) {
            return EventComment.fromFirestoreData(doc.data(), doc.id);
          }).toList();

          // Update cache
          _commentsCache['${eventId}_comments'] = comments;

          return comments;
        })
        .handleError((error) {
          debugPrint('❌ UserInteractionsService: Error watching comments - $error');
        });
  }

  /// Watch replies for a comment in real-time / Yorum cevaplarını gerçek zamanlı dinle
  Stream<List<EventComment>> watchCommentReplies(String eventId, String parentCommentId, {int limit = 20}) {
    debugPrint('👁️ UserInteractionsService: Starting to watch replies for comment $parentCommentId');
    
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .where('parentCommentId', isEqualTo: parentCommentId)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final replies = snapshot.docs.map((doc) {
            return EventComment.fromFirestoreData(doc.data(), doc.id);
          }).toList();

          return replies;
        })
        .handleError((error) {
          debugPrint('❌ UserInteractionsService: Error watching replies - $error');
        });
  }

  /// Watch comment likes in real-time / Yorum beğenilerini gerçek zamanlı dinle
  Stream<List<CommentLike>> watchCommentLikes(String eventId, String commentId, {int limit = 50}) {
    debugPrint('👁️ UserInteractionsService: Starting to watch likes for comment $commentId');
    
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .doc(commentId)
        .collection('likes')
        .orderBy('likedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final likes = snapshot.docs.map((doc) {
            return CommentLike.fromFirestoreData(doc.data(), doc.id);
          }).toList();

          // Update cache
          _likesCache['${eventId}_${commentId}_likes'] = likes;

          return likes;
        })
        .handleError((error) {
          debugPrint('❌ UserInteractionsService: Error watching likes - $error');
        });
  }

  // ==========================================
  // REAL-TIME COMMENT COUNTERS / GERÇEK ZAMANLI YORUM SAYAÇLARI
  // ==========================================

  /// Watch comment count for an event in real-time / Etkinlik yorum sayısını gerçek zamanlı dinle
  Stream<int> watchEventCommentCount(String eventId) {
    debugPrint('👁️ UserInteractionsService: Starting to watch comment count for event $eventId');
    
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((error) {
          debugPrint('❌ UserInteractionsService: Error watching comment count - $error');
        });
  }

  /// Watch comment like count for a comment in real-time / Yorum beğeni sayısını gerçek zamanlı dinle
  Stream<int> watchCommentLikeCount(String eventId, String commentId) {
    debugPrint('👁️ UserInteractionsService: Starting to watch like count for comment $commentId');
    
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .doc(commentId)
        .collection('likes')
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((error) {
          debugPrint('❌ UserInteractionsService: Error watching comment like count - $error');
        });
  }

  /// Watch multiple events comment counts / Birden fazla etkinlik yorum sayısını dinle
  Stream<Map<String, int>> watchMultipleEventCommentCounts(List<String> eventIds) {
    if (eventIds.isEmpty) {
      return Stream.value({});
    }

    debugPrint('👁️ UserInteractionsService: Starting to watch comment counts for ${eventIds.length} events');
    
    // Create a stream for each event and combine them
    final streams = eventIds.map((eventId) {
      return watchEventCommentCount(eventId).map((count) => MapEntry(eventId, count));
    }).toList();

    return Stream.fromIterable(streams)
        .asyncMap((stream) => stream.first)
        .fold<Map<String, int>>({}, (map, entry) {
          map[entry.key] = entry.value;
          return map;
        })
        .asStream();
  }

  /// Watch user's comment like status in real-time / Kullanıcının yorum beğeni durumunu gerçek zamanlı dinle
  Stream<bool> watchUserCommentLikeStatus(String eventId, String commentId, [String? userId]) {
    final uid = userId ?? currentUserId;
    if (uid == null) {
      debugPrint('❌ UserInteractionsService: Cannot watch like status - user not authenticated');
      return Stream.value(false);
    }

    debugPrint('👁️ UserInteractionsService: Starting to watch like status for comment $commentId');
    
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('comments')
        .doc(commentId)
        .collection('likes')
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.exists)
        .handleError((error) {
          debugPrint('❌ UserInteractionsService: Error watching like status - $error');
        });
  }

  // ==========================================
  // UTILITY METHODS / YARDIMCI METODLAR
  // ==========================================

  /// Get comment statistics / Yorum istatistiklerini getir
  Future<CommentStatistics> getCommentStatistics(String eventId) async {
    try {
      debugPrint('🔍 UserInteractionsService: Fetching comment statistics for event $eventId');
      
      final commentsSnapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('comments')
          .where('status', isEqualTo: 'active')
          .get();

      int totalComments = commentsSnapshot.docs.length;
      int topLevelComments = 0;
      int replies = 0;
      int totalLikes = 0;

      for (final doc in commentsSnapshot.docs) {
        final data = doc.data();
        final replyLevel = data['replyLevel'] ?? 0;
        final likeCount = data['likeCount'] ?? 0;
        
        if (replyLevel == 0) {
          topLevelComments++;
        } else {
          replies++;
        }
        
        totalLikes += likeCount as int;
      }

      final statistics = CommentStatistics(
        totalComments: totalComments,
        topLevelComments: topLevelComments,
        replies: replies,
        totalLikes: totalLikes,
      );

      debugPrint('✅ UserInteractionsService: Retrieved comment statistics');
      return statistics;
    } catch (e) {
      debugPrint('❌ UserInteractionsService: Failed to get comment statistics - $e');
      return const CommentStatistics(
        totalComments: 0,
        topLevelComments: 0,
        replies: 0,
        totalLikes: 0,
      );
    }
  }

  /// Search comments / Yorumları ara
  Future<List<EventComment>> searchComments(String eventId, String query, {int limit = 30}) async {
    try {
      if (query.isEmpty) return [];

      debugPrint('🔍 UserInteractionsService: Searching comments for: $query');
      
      // For simple implementation, get all comments and filter client-side
      // In production, you might want to use Algolia or similar service
      final comments = await getEventComments(eventId, limit: 100);
      
      final searchQuery = query.toLowerCase();
      final filteredComments = comments.where((comment) {
        return comment.content.toLowerCase().contains(searchQuery) ||
               comment.authorName.toLowerCase().contains(searchQuery);
      }).take(limit).toList();

      debugPrint('✅ UserInteractionsService: Found ${filteredComments.length} comments for query: $query');
      return filteredComments;
    } catch (e) {
      debugPrint('❌ UserInteractionsService: Failed to search comments - $e');
      return [];
    }
  }

  /// Clear cache / Cache'i temizle
  void clearCache() {
    _commentsCache.clear();
    _likesCache.clear();
    _cacheExpireTimer?.cancel();
    debugPrint('🧹 UserInteractionsService: Cache cleared');
  }

  /// Start cache expire timer / Cache süre dolumu timer'ını başlat
  void _startCacheExpireTimer() {
    _cacheExpireTimer?.cancel();
    _cacheExpireTimer = Timer(const Duration(minutes: 3), () {
      clearCache();
    });
  }

  /// Cancel all subscriptions / Tüm subscription'ları iptal et
  void cancelAllSubscriptions() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    debugPrint('🔌 UserInteractionsService: All subscriptions cancelled');
  }

  /// Dispose service / Servisi temizle
  void dispose() {
    cancelAllSubscriptions();
    clearCache();
    debugPrint('🧹 UserInteractionsService: Service disposed');
  }
}

/// Comment statistics model
/// Yorum istatistikleri modeli
class CommentStatistics {
  final int totalComments;
  final int topLevelComments;
  final int replies;
  final int totalLikes;

  const CommentStatistics({
    required this.totalComments,
    required this.topLevelComments,
    required this.replies,
    required this.totalLikes,
  });

  @override
  String toString() => 'CommentStatistics{totalComments: $totalComments, topLevelComments: $topLevelComments, replies: $replies, totalLikes: $totalLikes}';
}