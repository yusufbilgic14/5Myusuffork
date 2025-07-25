import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../models/club_chat_models.dart';
import '../models/user_interaction_models.dart';
import 'firebase_auth_service.dart';
import 'notification_service.dart';
import 'user_profile_service.dart';

/// Club chat service with approval workflow
/// Onay iş akışı ile kulüp sohbet servisi
class ClubChatService {
  // Singleton pattern implementation
  static final ClubChatService _instance = ClubChatService._internal();
  factory ClubChatService() => _instance;
  ClubChatService._internal();

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserProfileService _profileService = UserProfileService();
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
    bool requiresApproval = true,
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
  // MEDIA UPLOAD & MANAGEMENT / MEDYA YÜKLEMİ VE YÖNETİMİ
  // ==========================================

  /// Upload media file to Firebase Storage
  /// Medya dosyasını Firebase Storage'a yükle
  Future<MediaAttachment?> uploadMediaFile({
    required File file,
    required String clubId,
    required String messageId,
    required String fileType, // 'image', 'document', 'voice', 'video'
    String? originalFileName,
  }) async {
    try {
      if (!isAuthenticated || currentUserId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('📤 ClubChatService: Uploading media file for club $clubId');

      // Generate unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last;
      final fileName = '${timestamp}_${messageId}_$currentUserId.$extension';
      
      // Create storage reference - match Firebase Storage rules path
      final storageRef = _storage.ref().child('club_chat/$clubId/media/$messageId/$fileName');
      
      // Upload file
      final uploadTask = storageRef.putFile(file);
      final taskSnapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
      // Get file stats
      final fileSize = await file.length();
      final mimeType = _getMimeType(extension);
      
      // Create media attachment
      final attachment = MediaAttachment(
        attachmentId: '${messageId}_${timestamp}',
        fileName: fileName,
        originalFileName: originalFileName ?? fileName,
        fileType: fileType,
        mimeType: mimeType,
        fileSize: fileSize,
        fileUrl: downloadUrl,
        thumbnailUrl: fileType == 'image' ? downloadUrl : null, // Use original for images
        uploadedAt: DateTime.now(),
      );

      debugPrint('✅ ClubChatService: Media file uploaded successfully');
      return attachment;
    } catch (e) {
      debugPrint('❌ ClubChatService: Error uploading media file: $e');
      return null;
    }
  }

  /// Get MIME type from file extension
  /// Dosya uzantısından MIME tipini al
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }

  // ==========================================
  // MESSAGE REACTIONS / MESAJ REAKSİYONLARI
  // ==========================================

  /// Add reaction to message
  /// Mesaja reaksiyon ekle
  Future<bool> addReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      if (!isAuthenticated || currentUserId == null) {
        throw Exception('User not authenticated');
      }

      final currentUser = _authService.currentAppUser!;
      debugPrint('😊 ClubChatService: Adding reaction $emoji to message $messageId');

      // Create reaction
      final reaction = MessageReaction.create(
        messageId: messageId,
        userId: currentUserId!,
        userName: currentUser.displayName,
        emoji: emoji,
      );

      // Add reaction to collection
      await _firestore
          .collection('message_reactions')
          .doc(reaction.reactionId)
          .set(reaction.toJson());

      // Update message reaction count
      await _updateMessageReactionCounts(messageId);

      debugPrint('✅ ClubChatService: Reaction added successfully');
      return true;
    } catch (e) {
      debugPrint('❌ ClubChatService: Error adding reaction: $e');
      return false;
    }
  }

  /// Remove reaction from message
  /// Mesajdan reaksiyonu kaldır
  Future<bool> removeReaction({
    required String messageId,
    required String emoji,
  }) async {
    try {
      if (!isAuthenticated || currentUserId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('🚫 ClubChatService: Removing reaction $emoji from message $messageId');

      final reactionId = '${messageId}_${currentUserId}_${emoji.hashCode}';

      // Remove reaction from collection
      await _firestore
          .collection('message_reactions')
          .doc(reactionId)
          .delete();

      // Update message reaction count
      await _updateMessageReactionCounts(messageId);

      debugPrint('✅ ClubChatService: Reaction removed successfully');
      return true;
    } catch (e) {
      debugPrint('❌ ClubChatService: Error removing reaction: $e');
      return false;
    }
  }

  /// Get reactions for message
  /// Mesaj için reaksiyonları getir
  Stream<List<MessageReaction>> streamMessageReactions(String messageId) {
    debugPrint('😊 ClubChatService: Streaming reactions for message $messageId');

    return _firestore
        .collection('message_reactions')
        .where('messageId', isEqualTo: messageId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageReaction.fromJson(doc.data());
      }).toList();
    });
  }

  /// Update message reaction counts in the message document
  /// Mesaj belgesindeki reaksiyon sayılarını güncelle
  Future<void> _updateMessageReactionCounts(String messageId) async {
    try {
      // Get all reactions for this message
      final reactionsSnapshot = await _firestore
          .collection('message_reactions')
          .where('messageId', isEqualTo: messageId)
          .get();

      // Count reactions by emoji
      final Map<String, int> reactionCounts = {};
      int totalReactions = 0;

      for (final doc in reactionsSnapshot.docs) {
        final reaction = MessageReaction.fromJson(doc.data());
        reactionCounts[reaction.emoji] = (reactionCounts[reaction.emoji] ?? 0) + 1;
        totalReactions++;
      }

      // Update the message with new reaction counts
      // messageId is the document ID in Firestore
      await _firestore
          .collection('chat_messages')
          .doc(messageId)
          .update({
        'reactions': reactionCounts.isEmpty ? null : reactionCounts,
        'reactionCount': totalReactions,
      });

      debugPrint('✅ ClubChatService: Updated reaction counts for message $messageId');
    } catch (e) {
      debugPrint('❌ ClubChatService: Error updating reaction counts: $e');
    }
  }

  // ==========================================
  // MESSAGE PINNING / MESAJ SABİTLEME
  // ==========================================

  /// Pin/Unpin message
  /// Mesajı sabitle/sabitlmeyi kaldır
  Future<bool> toggleMessagePin({
    required String messageId,
    required String clubId,
  }) async {
    try {
      if (!isAuthenticated || currentUserId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('📌 ClubChatService: Toggling pin for message $messageId');

      // Get the message
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

      // Toggle pin status
      final updatedMessage = message.copyWithPin(
        pinned: !message.isPinned,
        pinnedBy: currentUserId!,
      );

      await _firestore
          .collection('chat_messages')
          .doc(messageId)
          .update({
        'isPinned': updatedMessage.isPinned,
        'pinnedAt': updatedMessage.pinnedAt?.toIso8601String(),
        'pinnedBy': updatedMessage.pinnedBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ ClubChatService: Message pin toggled successfully');
      return true;
    } catch (e) {
      debugPrint('❌ ClubChatService: Error toggling message pin: $e');
      return false;
    }
  }

  /// Get pinned messages for club
  /// Kulüp için sabitlenmiş mesajları getir
  Stream<List<ChatMessage>> streamPinnedMessages(String clubId) {
    debugPrint('📌 ClubChatService: Streaming pinned messages for club $clubId');

    return _firestore
        .collection('chat_messages')
        .where('clubId', isEqualTo: clubId)
        .where('isPinned', isEqualTo: true)
        .where('isDeleted', isEqualTo: false)
        .orderBy('pinnedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['messageId'] = doc.id;
        return ChatMessage.fromJson(data);
      }).toList();
    });
  }

  // ==========================================
  // USER PRESENCE & TYPING / KULLANICI VARLIĞI VE YAZMA
  // ==========================================

  /// Update typing status
  /// Yazma durumunu güncelle
  Future<void> updateTypingStatus({
    required String clubId,
    required bool isTyping,
  }) async {
    try {
      if (!isAuthenticated || currentUserId == null) return;

      await _firestore
          .collection('user_presence')
          .doc('${clubId}_$currentUserId')
          .update({
        'isTyping': isTyping,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Auto-clear typing status after 3 seconds
      if (isTyping) {
        Timer(const Duration(seconds: 3), () {
          updateTypingStatus(clubId: clubId, isTyping: false);
        });
      }

      debugPrint('✅ ClubChatService: Typing status updated - typing: $isTyping');
    } catch (e) {
      debugPrint('❌ ClubChatService: Error updating typing status: $e');
    }
  }

  /// Stream user presence for chat room
  /// Sohbet odası için kullanıcı varlığını akışla getir
  Stream<List<UserPresence>> streamUserPresence(String clubId) {
    debugPrint('👥 ClubChatService: Streaming user presence for club $clubId');

    return _firestore
        .collection('user_presence')
        .where('chatRoomId', isEqualTo: clubId)
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserPresence.fromJson(doc.data());
      }).toList();
    });
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

      // Get actual profile picture URL from UserProfile
      final userProfile = await _profileService.getUserProfile();
      final actualProfilePhotoUrl = userProfile?.profilePhotoUrl;

      // Create approval request
      final approval = PendingApproval.create(
        chatRoomId: clubId,
        clubId: clubId,
        userId: currentUserId!,
        userName: currentUser.displayName,
        userAvatar: actualProfilePhotoUrl,
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
        // Check if user is the club creator - if so, auto-add them as participant
        final clubDoc = await _firestore
            .collection('clubs')
            .doc(clubId)
            .get();
            
        if (clubDoc.exists) {
          final clubData = clubDoc.data()!;
          final clubCreatedBy = clubData['createdBy'] as String?;
          
          if (clubCreatedBy == currentUserId) {
            // Auto-add club creator as participant
            final currentUser = _authService.currentAppUser!;
            
            // Get actual profile picture URL from UserProfile
            final userProfile = await _profileService.getUserProfile();
            final actualProfilePhotoUrl = userProfile?.profilePhotoUrl;
            
            await _addChatParticipant(
              chatRoomId: clubId,
              clubId: clubId,
              userId: currentUserId!,
              userName: currentUser.displayName,
              userAvatar: actualProfilePhotoUrl,
              role: 'creator',
            );
            debugPrint('✅ ClubChatService: Club creator auto-added as participant');
            return true;
          }
        }
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
    List<MediaAttachment>? mediaAttachments,
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

      // Get actual profile picture URL from UserProfile
      debugPrint('🔍 ClubChatService: Fetching user profile for avatar...');
      final userProfile = await _profileService.getUserProfile();
      final actualProfilePhotoUrl = userProfile?.profilePhotoUrl;
      
      debugPrint('👤 ClubChatService: User profile data:');
      debugPrint('  - User ID: ${currentUserId}');
      debugPrint('  - Display Name: ${currentUser.displayName}');
      debugPrint('  - Profile loaded: ${userProfile != null}');
      debugPrint('  - Profile photo URL: ${actualProfilePhotoUrl}');
      debugPrint('  - Old Graph API URL: ${currentUser.profilePhotoUrl}');
      
      // Create chat message
      final message = ChatMessage.create(
        chatRoomId: clubId,
        clubId: clubId,
        content: content,
        messageType: messageType,
        mediaUrls: mediaUrls,
        mediaAttachments: mediaAttachments,
        senderId: currentUserId!,
        senderName: currentUser.displayName,
        senderAvatar: actualProfilePhotoUrl,
        replyToMessageId: replyToMessageId,
        replyToContent: replyToContent,
        replyToSenderName: replyToSenderName,
      );

      debugPrint('📝 ClubChatService: ChatMessage created:');
      debugPrint('  - Message ID: ${message.messageId}');
      debugPrint('  - Sender ID: ${message.senderId}');
      debugPrint('  - Sender Name: ${message.senderName}');
      debugPrint('  - Sender Avatar: ${message.senderAvatar}');
      debugPrint('  - Content: ${message.content}');

      // Add message to Firestore
      final messageRef = await _firestore
          .collection('chat_messages')
          .add(message.toJson());

      // Update the message with the correct messageId
      await messageRef.update({'messageId': messageRef.id});

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