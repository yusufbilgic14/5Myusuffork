import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../models/club_chat_models.dart';
import '../models/user_interaction_models.dart';
import 'firebase_auth_service.dart';
import 'notification_service.dart';

/// Club chat service with approval workflow
/// Onay iş akışı ile kulüp sohbet servisi
class ClubChatService {
  // Singleton pattern implementation
  static final ClubChatService _instance = ClubChatService._internal();
  factory ClubChatService() => _instance;
  ClubChatService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  NotificationService? _notificationService;

  // Stream subscriptions for memory management
  final Map<String, StreamSubscription> _subscriptions = {};

  // Cache for frequently accessed data
  final Map<String, ChatRoom> _chatRoomsCache = {};
  final Map<String, List<ChatMessage>> _messagesCache = {};
  Timer? _cacheExpireTimer;

  /// Get current user's Firebase UID
  String? get currentUserId => _authService.currentAppUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => _authService.isAuthenticated;

  // ==========================================
  // CHAT ROOM OPERATIONS / SOHBET ODASI İŞLEMLERİ
  // ==========================================

  /// Create or get chat room for club
  /// Kulüp için sohbet odası oluştur veya getir
  Future<ChatRoom> createOrGetChatRoom({
    required String clubId,
    required String clubName,
    bool requiresApproval = false, // TEMPORARY: Disabled approval workflow
    int? maxParticipants,
  }) async {
    try {
      debugPrint('🏠 ClubChatService: Creating/getting chat room for club $clubId');

      // Check if chat room already exists
      final chatRoomDoc = await _firestore
          .collection('chat_rooms')
          .doc(clubId)
          .get();

      if (chatRoomDoc.exists) {
        final chatRoom = ChatRoom.fromJson(chatRoomDoc.data()!);
        _chatRoomsCache[clubId] = chatRoom;
        return chatRoom;
      }

      // Create new chat room
      final chatRoom = ChatRoom.create(
        clubId: clubId,
        clubName: clubName,
        requiresApproval: requiresApproval,
        maxParticipants: maxParticipants,
      );

      await _firestore
          .collection('chat_rooms')
          .doc(clubId)
          .set(chatRoom.toJson());

      _chatRoomsCache[clubId] = chatRoom;
      debugPrint('✅ ClubChatService: Chat room created for club $clubId');
      return chatRoom;
    } catch (e) {
      debugPrint('❌ ClubChatService: Error creating chat room: $e');
      rethrow;
    }
  }

  /// Get chat room by club ID
  /// Kulüp ID'sine göre sohbet odasını getir
  Future<ChatRoom?> getChatRoom(String clubId) async {
    try {
      // Check cache first
      if (_chatRoomsCache.containsKey(clubId)) {
        return _chatRoomsCache[clubId];
      }

      final chatRoomDoc = await _firestore
          .collection('chat_rooms')
          .doc(clubId)
          .get();

      if (!chatRoomDoc.exists) return null;

      final chatRoom = ChatRoom.fromJson(chatRoomDoc.data()!);
      _chatRoomsCache[clubId] = chatRoom;
      return chatRoom;
    } catch (e) {
      debugPrint('❌ ClubChatService: Error getting chat room: $e');
      return null;
    }
  }

  // ==========================================
  // APPROVAL WORKFLOW / ONAY İŞ AKIŞI
  // ==========================================

  /// Request access to club chat
  /// Kulüp sohbetine erişim talebi
  Future<bool> requestChatAccess({
    required String clubId,
    String? requestMessage,
  }) async {
    try {
      if (!isAuthenticated || currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final currentUser = _authService.currentAppUser!;
      debugPrint('📝 ClubChatService: Requesting chat access for club $clubId');

      // Check if user already has access
      final hasAccess = await checkChatAccess(clubId);
      if (hasAccess) {
        debugPrint('✅ ClubChatService: User already has access');
        return true;
      }

      // Check if there's already a pending request
      final existingRequest = await _firestore
          .collection('pending_approvals')
          .where('clubId', isEqualTo: clubId)
          .where('userId', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        debugPrint('⏳ ClubChatService: Request already pending');
        return false;
      }

      // Create approval request
      final approval = PendingApproval.create(
        chatRoomId: clubId,
        clubId: clubId,
        userId: currentUserId!,
        userName: currentUser.displayName,
        userAvatar: currentUser.profilePhotoUrl,
        userEmail: currentUser.email,
        requestMessage: requestMessage,
      );

      await _firestore
          .collection('pending_approvals')
          .add(approval.toJson());

      debugPrint('✅ ClubChatService: Chat access request submitted');
      return true;
    } catch (e) {
      debugPrint('❌ ClubChatService: Error requesting chat access: $e');
      return false;
    }
  }

  /// Get pending approvals for club (creator only)
  /// Kulüp için bekleyen onayları getir (sadece oluşturucu)
  Stream<List<PendingApproval>> streamPendingApprovals(String clubId) {
    debugPrint('📋 ClubChatService: Streaming pending approvals for club $clubId');

    return _firestore
        .collection('pending_approvals')
        .where('clubId', isEqualTo: clubId)
        .where('status', isEqualTo: 'pending')
        .orderBy('requestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['approvalId'] = doc.id;
        return PendingApproval.fromJson(data);
      }).toList();
    });
  }

  /// Approve chat access request
  /// Sohbet erişim talebini onayla
  Future<bool> approveChatRequest({
    required String approvalId,
    String? decisionMessage,
  }) async {
    try {
      if (!isAuthenticated || currentUserId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('✅ ClubChatService: Approving chat request $approvalId');

      // Get the approval request
      final approvalDoc = await _firestore
          .collection('pending_approvals')
          .doc(approvalId)
          .get();

      if (!approvalDoc.exists) {
        throw Exception('Approval request not found');
      }

      final approval = PendingApproval.fromJson({
        ...approvalDoc.data()!,
        'approvalId': approvalDoc.id,
      });

      // Update approval status
      final approvedRequest = approval.approve(
        decidedBy: currentUserId!,
        decisionMessage: decisionMessage,
      );

      await _firestore
          .collection('pending_approvals')
          .doc(approvalId)
          .update(approvedRequest.toJson());

      // Add user as chat participant
      await _addChatParticipant(
        chatRoomId: approval.chatRoomId,
        clubId: approval.clubId,
        userId: approval.userId,
        userName: approval.userName,
        userAvatar: approval.userAvatar,
      );

      debugPrint('✅ ClubChatService: Chat request approved');
      return true;
    } catch (e) {
      debugPrint('❌ ClubChatService: Error approving chat request: $e');
      return false;
    }
  }

  /// Reject chat access request
  /// Sohbet erişim talebini reddet
  Future<bool> rejectChatRequest({
    required String approvalId,
    String? decisionMessage,
  }) async {
    try {
      if (!isAuthenticated || currentUserId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('❌ ClubChatService: Rejecting chat request $approvalId');

      // Get the approval request
      final approvalDoc = await _firestore
          .collection('pending_approvals')
          .doc(approvalId)
          .get();

      if (!approvalDoc.exists) {
        throw Exception('Approval request not found');
      }

      final approval = PendingApproval.fromJson({
        ...approvalDoc.data()!,
        'approvalId': approvalDoc.id,
      });

      // Update approval status
      final rejectedRequest = approval.reject(
        decidedBy: currentUserId!,
        decisionMessage: decisionMessage,
      );

      await _firestore
          .collection('pending_approvals')
          .doc(approvalId)
          .update(rejectedRequest.toJson());

      debugPrint('✅ ClubChatService: Chat request rejected');
      return true;
    } catch (e) {
      debugPrint('❌ ClubChatService: Error rejecting chat request: $e');
      return false;
    }
  }

  // ==========================================
  // CHAT PARTICIPANTS / SOHBET KATILIMCILARI
  // ==========================================

  /// Add chat participant
  /// Sohbet katılımcısı ekle
  Future<void> _addChatParticipant({
    required String chatRoomId,
    required String clubId,
    required String userId,
    required String userName,
    String? userAvatar,
    String role = 'member',
  }) async {
    try {
      final participant = ChatParticipant.create(
        chatRoomId: chatRoomId,
        clubId: clubId,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
        role: role,
      );

      await _firestore
          .collection('chat_participants')
          .doc('${chatRoomId}_$userId')
          .set(participant.toJson());

      // Update chat room participant count
      await _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .update({
        'participantCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ ClubChatService: Participant added to chat');
    } catch (e) {
      debugPrint('❌ ClubChatService: Error adding participant: $e');
      rethrow;
    }
  }

  /// Check if user has chat access
  /// Kullanıcının sohbet erişimi olup olmadığını kontrol et
  Future<bool> checkChatAccess(String clubId) async {
    try {
      if (!isAuthenticated || currentUserId == null) return false;

      final participantDoc = await _firestore
          .collection('chat_participants')
          .doc('${clubId}_$currentUserId')
          .get();

      if (!participantDoc.exists) {
        // TEMPORARY: Disabled approval workflow - auto-add anyone who follows the club
        // Check if user follows the club or is the creator
        bool shouldAddAsParticipant = false;
        String userRole = 'member';
        
        // Check if user is the club creator
        final clubDoc = await _firestore
            .collection('clubs')
            .doc(clubId)
            .get();
            
        if (clubDoc.exists) {
          final clubData = clubDoc.data()!;
          final clubCreatedBy = clubData['createdBy'] as String?;
          
          if (clubCreatedBy == currentUserId) {
            shouldAddAsParticipant = true;
            userRole = 'creator';
            debugPrint('🔑 ClubChatService: User is club creator - granting access');
          }
        }
        
        // If not creator, check if user follows the club
        if (!shouldAddAsParticipant) {
          final followDoc = await _firestore
              .collection('users')
              .doc(currentUserId)
              .collection('followedClubs')
              .doc(clubId)
              .get();
              
          if (followDoc.exists) {
            final followData = followDoc.data()!;
            final isFollowing = followData['isFollowing'] as bool? ?? false;
            
            if (isFollowing) {
              shouldAddAsParticipant = true;
              userRole = 'member';
              debugPrint('👥 ClubChatService: User follows club - granting access');
            }
          }
        }
        
        // Auto-add as participant if they should have access
        if (shouldAddAsParticipant) {
          final currentUser = _authService.currentAppUser!;
          await _addChatParticipant(
            chatRoomId: clubId,
            clubId: clubId,
            userId: currentUserId!,
            userName: currentUser.displayName,
            userAvatar: currentUser.profilePhotoUrl,
            role: userRole,
          );
          debugPrint('✅ ClubChatService: User auto-added as chat participant with role: $userRole');
          return true;
        }
        
        debugPrint('❌ ClubChatService: User does not follow club - access denied');
        return false;
      }

      final participant = ChatParticipant.fromJson(participantDoc.data()!);
      return participant.isActive;
    } catch (e) {
      debugPrint('❌ ClubChatService: Error checking chat access: $e');
      return false;
    }
  }

  /// Get chat participants
  /// Sohbet katılımcılarını getir
  Stream<List<ChatParticipant>> streamChatParticipants(String clubId) {
    debugPrint('👥 ClubChatService: Streaming chat participants for club $clubId');

    return _firestore
        .collection('chat_participants')
        .where('clubId', isEqualTo: clubId)
        .where('isActive', isEqualTo: true)
        .orderBy('joinedAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatParticipant.fromJson(doc.data());
      }).toList();
    });
  }

  // ==========================================
  // CHAT MESSAGES / SOHBET MESAJLARI
  // ==========================================

  /// Send chat message
  /// Sohbet mesajı gönder
  Future<bool> sendMessage({
    required String clubId,
    required String content,
    String messageType = 'text',
    List<String>? mediaUrls,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSenderName,
  }) async {
    try {
      if (!isAuthenticated || currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Check if user has chat access
      final hasAccess = await checkChatAccess(clubId);
      if (!hasAccess) {
        throw Exception('User does not have chat access');
      }

      final currentUser = _authService.currentAppUser!;
      debugPrint('💬 ClubChatService: Sending message to club $clubId');

      // Create chat message
      final message = ChatMessage.create(
        chatRoomId: clubId,
        clubId: clubId,
        content: content,
        messageType: messageType,
        mediaUrls: mediaUrls,
        senderId: currentUserId!,
        senderName: currentUser.displayName,
        senderAvatar: currentUser.profilePhotoUrl,
        replyToMessageId: replyToMessageId,
        replyToContent: replyToContent,
        replyToSenderName: replyToSenderName,
      );

      // Add message to Firestore
      final messageRef = await _firestore
          .collection('chat_messages')
          .add(message.toJson());

      // Update chat room's last message
      await _firestore
          .collection('chat_rooms')
          .doc(clubId)
          .update({
        'lastMessageId': messageRef.id,
        'lastMessageContent': content,
        'lastMessageSenderName': currentUser.displayName,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update participant's last message timestamp
      await _firestore
          .collection('chat_participants')
          .doc('${clubId}_$currentUserId')
          .update({
        'lastMessageAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send push notification to club participants
      // Kulüp katılımcılarına push bildirimi gönder
      try {
        final chatRoom = await getChatRoom(clubId);
        if (chatRoom != null) {
          // Lazy initialize notification service to avoid circular dependency
          _notificationService ??= NotificationService();
          
          final finalMessage = message.copyWith(messageId: messageRef.id);
          await _notificationService!.sendChatMessageNotification(
            clubId: clubId,
            clubName: chatRoom.clubName,
            message: finalMessage,
          );
          debugPrint('📱 ClubChatService: Push notification sent for message');
        }
      } catch (notificationError) {
        debugPrint('⚠️ ClubChatService: Notification sending failed: $notificationError');
        // Don't fail the message sending if notification fails
        // Bildirim başarısız olursa mesaj gönderimini başarısız sayma
      }

      debugPrint('✅ ClubChatService: Message sent successfully');
      return true;
    } catch (e) {
      debugPrint('❌ ClubChatService: Error sending message: $e');
      return false;
    }
  }

  /// Stream chat messages
  /// Sohbet mesajlarını akışla getir
  Stream<List<ChatMessage>> streamChatMessages(String clubId, {int limit = 50}) {
    debugPrint('💬 ClubChatService: Streaming messages for club $clubId');

    return _firestore
        .collection('chat_messages')
        .where('clubId', isEqualTo: clubId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs.map((doc) {
        final data = doc.data();
        data['messageId'] = doc.id;
        return ChatMessage.fromJson(data);
      }).toList();
      
      // Cache messages
      _messagesCache[clubId] = messages;
      return messages.reversed.toList(); // Reverse to show oldest first
    });
  }

  /// Edit chat message
  /// Sohbet mesajını düzenle
  Future<bool> editMessage({
    required String messageId,
    required String newContent,
    List<String>? newMediaUrls,
  }) async {
    try {
      if (!isAuthenticated || currentUserId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('✏️ ClubChatService: Editing message $messageId');

      // Get the message to verify ownership
      final messageDoc = await _firestore
          .collection('chat_messages')
          .doc(messageId)
          .get();

      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      final message = ChatMessage.fromJson({
        ...messageDoc.data()!,
        'messageId': messageDoc.id,
      });

      // Check if user owns the message
      if (message.senderId != currentUserId) {
        throw Exception('User can only edit their own messages');
      }

      // Update message
      final editedMessage = message.copyWithEdit(
        newContent: newContent,
        newMediaUrls: newMediaUrls,
      );

      await _firestore
          .collection('chat_messages')
          .doc(messageId)
          .update(editedMessage.toJson());

      debugPrint('✅ ClubChatService: Message edited successfully');
      return true;
    } catch (e) {
      debugPrint('❌ ClubChatService: Error editing message: $e');
      return false;
    }
  }

  /// Delete chat message
  /// Sohbet mesajını sil
  Future<bool> deleteMessage(String messageId) async {
    try {
      if (!isAuthenticated || currentUserId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('🗑️ ClubChatService: Deleting message $messageId');

      // Get the message to verify ownership
      final messageDoc = await _firestore
          .collection('chat_messages')
          .doc(messageId)
          .get();

      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      final message = ChatMessage.fromJson({
        ...messageDoc.data()!,
        'messageId': messageDoc.id,
      });

      // Check if user owns the message or has moderation permissions
      if (message.senderId != currentUserId) {
        // TODO: Check if user has moderation permissions
        throw Exception('User can only delete their own messages');
      }

      // Soft delete message
      final deletedMessage = message.copyWithDelete();

      await _firestore
          .collection('chat_messages')
          .doc(messageId)
          .update(deletedMessage.toJson());

      debugPrint('✅ ClubChatService: Message deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ ClubChatService: Error deleting message: $e');
      return false;
    }
  }

  // ==========================================
  // MESSAGE CLEANUP / MESAJ TEMİZLİĞİ
  // ==========================================

  /// Clean up expired messages (7-day retention)
  /// Süresi dolmuş mesajları temizle (7 günlük saklama)
  Future<void> cleanupExpiredMessages() async {
    try {
      debugPrint('🧹 ClubChatService: Starting message cleanup');

      final now = DateTime.now();
      final expiredMessages = await _firestore
          .collection('chat_messages')
          .where('expiresAt', isLessThan: Timestamp.fromDate(now))
          .limit(100) // Process in batches
          .get();

      if (expiredMessages.docs.isEmpty) {
        debugPrint('✅ ClubChatService: No expired messages to clean');
        return;
      }

      final batch = _firestore.batch();
      for (final doc in expiredMessages.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('✅ ClubChatService: Cleaned ${expiredMessages.docs.length} expired messages');
    } catch (e) {
      debugPrint('❌ ClubChatService: Error cleaning expired messages: $e');
    }
  }

  /// Clean up expired approval requests (30-day retention)
  /// Süresi dolmuş onay taleplerini temizle (30 günlük saklama)
  Future<void> cleanupExpiredApprovals() async {
    try {
      debugPrint('🧹 ClubChatService: Starting approval cleanup');

      final now = DateTime.now();
      final expiredApprovals = await _firestore
          .collection('pending_approvals')
          .where('expiresAt', isLessThan: Timestamp.fromDate(now))
          .limit(100) // Process in batches
          .get();

      if (expiredApprovals.docs.isEmpty) {
        debugPrint('✅ ClubChatService: No expired approvals to clean');
        return;
      }

      final batch = _firestore.batch();
      for (final doc in expiredApprovals.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      debugPrint('✅ ClubChatService: Cleaned ${expiredApprovals.docs.length} expired approvals');
    } catch (e) {
      debugPrint('❌ ClubChatService: Error cleaning expired approvals: $e');
    }
  }

  // ==========================================
  // UTILITY METHODS / YARDIMCI METODLAR
  // ==========================================

  /// Update participant's last seen timestamp
  /// Katılımcının son görülme zamanını güncelle
  Future<void> updateLastSeen(String clubId) async {
    try {
      if (!isAuthenticated || currentUserId == null) return;

      await _firestore
          .collection('chat_participants')
          .doc('${clubId}_$currentUserId')
          .update({
        'lastSeenAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ ClubChatService: Error updating last seen: $e');
    }
  }

  /// Clear cache
  /// Önbelleği temizle
  void clearCache() {
    _chatRoomsCache.clear();
    _messagesCache.clear();
    debugPrint('🧹 ClubChatService: Cache cleared');
  }

  /// Dispose service and cancel subscriptions
  /// Servisi kapat ve abonelikleri iptal et
  void dispose() {
    _subscriptions.forEach((key, subscription) {
      subscription.cancel();
    });
    _subscriptions.clear();
    _cacheExpireTimer?.cancel();
    clearCache();
    debugPrint('🔥 ClubChatService: Service disposed');
  }
}