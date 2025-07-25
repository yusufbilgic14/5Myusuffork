import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'club_chat_models.g.dart';

/// Media attachment model for chat messages
/// Sohbet mesajları için medya eki modeli
@JsonSerializable()
class MediaAttachment {
  @JsonKey(name: 'attachmentId')
  final String attachmentId;

  @JsonKey(name: 'fileName')
  final String fileName;

  @JsonKey(name: 'originalFileName')
  final String originalFileName;

  @JsonKey(name: 'fileType')
  final String fileType; // 'image', 'document', 'voice', 'video'

  @JsonKey(name: 'mimeType')
  final String mimeType;

  @JsonKey(name: 'fileSize')
  final int fileSize; // in bytes

  @JsonKey(name: 'fileUrl')
  final String fileUrl;

  @JsonKey(name: 'thumbnailUrl')
  final String? thumbnailUrl; // for images and videos

  // Media-specific properties
  @JsonKey(name: 'width')
  final int? width; // for images and videos

  @JsonKey(name: 'height')
  final int? height; // for images and videos

  @JsonKey(name: 'duration')
  final int? duration; // for voice and video (in seconds)

  @JsonKey(name: 'uploadedAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime uploadedAt;

  const MediaAttachment({
    required this.attachmentId,
    required this.fileName,
    required this.originalFileName,
    required this.fileType,
    required this.mimeType,
    required this.fileSize,
    required this.fileUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.duration,
    required this.uploadedAt,
  });

  factory MediaAttachment.fromJson(Map<String, dynamic> json) => _$MediaAttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$MediaAttachmentToJson(this);

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static dynamic _timestampToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}

/// Message reaction model for emoji reactions
/// Emoji tepkileri için mesaj reaksiyonu modeli
@JsonSerializable()
class MessageReaction {
  @JsonKey(name: 'reactionId')
  final String reactionId;

  @JsonKey(name: 'messageId')
  final String messageId;

  @JsonKey(name: 'userId')
  final String userId;

  @JsonKey(name: 'userName')
  final String userName;

  @JsonKey(name: 'emoji')
  final String emoji; // The emoji reaction (👍, ❤️, 😂, etc.)

  @JsonKey(name: 'createdAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  const MessageReaction({
    required this.reactionId,
    required this.messageId,
    required this.userId,
    required this.userName,
    required this.emoji,
    required this.createdAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) => _$MessageReactionFromJson(json);
  Map<String, dynamic> toJson() => _$MessageReactionToJson(this);

  factory MessageReaction.create({
    required String messageId,
    required String userId,
    required String userName,
    required String emoji,
  }) {
    return MessageReaction(
      reactionId: '${messageId}_${userId}_${emoji.hashCode}',
      messageId: messageId,
      userId: userId,
      userName: userName,
      emoji: emoji,
      createdAt: DateTime.now(),
    );
  }

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static dynamic _timestampToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}

/// User presence model for online status tracking
/// Çevrimiçi durum takibi için kullanıcı varlık modeli
@JsonSerializable()
class UserPresence {
  @JsonKey(name: 'userId')
  final String userId;

  @JsonKey(name: 'userName')
  final String userName;

  @JsonKey(name: 'chatRoomId')
  final String chatRoomId;

  @JsonKey(name: 'isOnline')
  final bool isOnline;

  @JsonKey(name: 'isTyping')
  final bool isTyping;

  @JsonKey(name: 'lastSeen', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime lastSeen;

  @JsonKey(name: 'updatedAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime updatedAt;

  const UserPresence({
    required this.userId,
    required this.userName,
    required this.chatRoomId,
    this.isOnline = false,
    this.isTyping = false,
    required this.lastSeen,
    required this.updatedAt,
  });

  factory UserPresence.fromJson(Map<String, dynamic> json) => _$UserPresenceFromJson(json);
  Map<String, dynamic> toJson() => _$UserPresenceToJson(this);

  factory UserPresence.create({
    required String userId,
    required String userName,
    required String chatRoomId,
    bool isOnline = true,
  }) {
    final now = DateTime.now();
    return UserPresence(
      userId: userId,
      userName: userName,
      chatRoomId: chatRoomId,
      isOnline: isOnline,
      lastSeen: now,
      updatedAt: now,
    );
  }

  UserPresence copyWith({
    bool? isOnline,
    bool? isTyping,
    DateTime? lastSeen,
  }) {
    return UserPresence(
      userId: userId,
      userName: userName,
      chatRoomId: chatRoomId,
      isOnline: isOnline ?? this.isOnline,
      isTyping: isTyping ?? this.isTyping,
      lastSeen: lastSeen ?? this.lastSeen,
      updatedAt: DateTime.now(),
    );
  }

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static dynamic _timestampToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}

/// Chat message model for club conversations
/// Kulüp konuşmaları için sohbet mesajı modeli
@JsonSerializable()
class ChatMessage {
  @JsonKey(name: 'messageId')
  final String messageId;

  @JsonKey(name: 'chatRoomId')
  final String chatRoomId;

  @JsonKey(name: 'clubId')
  final String clubId;

  // Message Content
  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'messageType')
  final String messageType; // 'text', 'image', 'file', 'system'

  @JsonKey(name: 'mediaUrls')
  final List<String>? mediaUrls;

  @JsonKey(name: 'mediaAttachments', fromJson: _mediaAttachmentsFromJson, toJson: _mediaAttachmentsToJson)
  final List<MediaAttachment>? mediaAttachments;

  // Message interactions
  @JsonKey(name: 'isPinned')
  final bool isPinned;

  @JsonKey(name: 'pinnedAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? pinnedAt;

  @JsonKey(name: 'pinnedBy')
  final String? pinnedBy;

  @JsonKey(name: 'reactionCount')
  final int reactionCount;

  @JsonKey(name: 'reactions')
  final Map<String, int>? reactions; // emoji -> count mapping

  // Author Information
  @JsonKey(name: 'senderId')
  final String senderId;

  @JsonKey(name: 'senderName')
  final String senderName;

  @JsonKey(name: 'senderAvatar')
  final String? senderAvatar;

  // Reply System
  @JsonKey(name: 'replyToMessageId')
  final String? replyToMessageId;

  @JsonKey(name: 'replyToContent')
  final String? replyToContent;

  @JsonKey(name: 'replyToSenderName')
  final String? replyToSenderName;

  // Timestamps
  @JsonKey(name: 'createdAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  @JsonKey(name: 'updatedAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? updatedAt;

  // Message Status
  @JsonKey(name: 'isEdited')
  final bool isEdited;

  @JsonKey(name: 'isDeleted')
  final bool isDeleted;

  @JsonKey(name: 'deletedAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? deletedAt;

  // Auto-cleanup (for 7-day retention)
  @JsonKey(name: 'expiresAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime expiresAt;

  const ChatMessage({
    required this.messageId,
    required this.chatRoomId,
    required this.clubId,
    required this.content,
    this.messageType = 'text',
    this.mediaUrls,
    this.mediaAttachments,
    this.isPinned = false,
    this.pinnedAt,
    this.pinnedBy,
    this.reactionCount = 0,
    this.reactions,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    this.replyToMessageId,
    this.replyToContent,
    this.replyToSenderName,
    required this.createdAt,
    this.updatedAt,
    this.isEdited = false,
    this.isDeleted = false,
    this.deletedAt,
    required this.expiresAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  /// Create a new chat message
  /// Yeni sohbet mesajı oluştur
  factory ChatMessage.create({
    required String chatRoomId,
    required String clubId,
    required String content,
    String messageType = 'text',
    List<String>? mediaUrls,
    List<MediaAttachment>? mediaAttachments,
    required String senderId,
    required String senderName,
    String? senderAvatar,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSenderName,
  }) {
    final now = DateTime.now();
    final expiry = now.add(const Duration(days: 7)); // 7-day retention
    
    return ChatMessage(
      messageId: '', // Will be set by Firestore
      chatRoomId: chatRoomId,
      clubId: clubId,
      content: content,
      messageType: messageType,
      mediaUrls: mediaUrls,
      mediaAttachments: mediaAttachments,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      replyToMessageId: replyToMessageId,
      replyToContent: replyToContent,
      replyToSenderName: replyToSenderName,
      createdAt: now,
      expiresAt: expiry,
    );
  }

  /// Create copy of message with updated fields
  /// Güncellenmiş alanlarla mesajın kopyasını oluştur
  ChatMessage copyWith({
    String? messageId,
    String? chatRoomId,
    String? clubId,
    String? content,
    String? messageType,
    List<String>? mediaUrls,
    List<MediaAttachment>? mediaAttachments,
    bool? isPinned,
    DateTime? pinnedAt,
    String? pinnedBy,
    int? reactionCount,
    Map<String, int>? reactions,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? replyToMessageId,
    String? replyToContent,
    String? replyToSenderName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEdited,
    bool? isDeleted,
    DateTime? deletedAt,
    DateTime? expiresAt,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      clubId: clubId ?? this.clubId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaAttachments: mediaAttachments ?? this.mediaAttachments,
      isPinned: isPinned ?? this.isPinned,
      pinnedAt: pinnedAt ?? this.pinnedAt,
      pinnedBy: pinnedBy ?? this.pinnedBy,
      reactionCount: reactionCount ?? this.reactionCount,
      reactions: reactions ?? this.reactions,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Create edited version of message
  /// Mesajın düzenlenmiş versiyonunu oluştur
  ChatMessage copyWithEdit({
    required String newContent,
    List<String>? newMediaUrls,
    List<MediaAttachment>? newMediaAttachments,
  }) {
    return ChatMessage(
      messageId: messageId,
      chatRoomId: chatRoomId,
      clubId: clubId,
      content: newContent,
      messageType: messageType,
      mediaUrls: newMediaUrls ?? mediaUrls,
      mediaAttachments: newMediaAttachments ?? mediaAttachments,
      isPinned: isPinned,
      pinnedAt: pinnedAt,
      pinnedBy: pinnedBy,
      reactionCount: reactionCount,
      reactions: reactions,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      replyToMessageId: replyToMessageId,
      replyToContent: replyToContent,
      replyToSenderName: replyToSenderName,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isEdited: true,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      expiresAt: expiresAt,
    );
  }

  /// Create deleted version of message
  /// Mesajın silinmiş versiyonunu oluştur
  ChatMessage copyWithDelete() {
    return ChatMessage(
      messageId: messageId,
      chatRoomId: chatRoomId,
      clubId: clubId,
      content: '[Bu mesaj silindi]',
      messageType: 'system',
      mediaUrls: null,
      mediaAttachments: null,
      isPinned: false, // Remove pin when deleting
      pinnedAt: null,
      pinnedBy: null,
      reactionCount: 0, // Clear reactions when deleting
      reactions: null,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      replyToMessageId: replyToMessageId,
      replyToContent: replyToContent,
      replyToSenderName: replyToSenderName,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isEdited: isEdited,
      isDeleted: true,
      deletedAt: DateTime.now(),
      expiresAt: expiresAt,
    );
  }

  /// Pin/Unpin message
  /// Mesajı sabitle/sabitlmeyi kaldır
  ChatMessage copyWithPin({
    required bool pinned,
    required String pinnedBy,
  }) {
    return ChatMessage(
      messageId: messageId,
      chatRoomId: chatRoomId,
      clubId: clubId,
      content: content,
      messageType: messageType,
      mediaUrls: mediaUrls,
      mediaAttachments: mediaAttachments,
      isPinned: pinned,
      pinnedAt: pinned ? DateTime.now() : null,
      pinnedBy: pinned ? pinnedBy : null,
      reactionCount: reactionCount,
      reactions: reactions,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      replyToMessageId: replyToMessageId,
      replyToContent: replyToContent,
      replyToSenderName: replyToSenderName,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      isEdited: isEdited,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      expiresAt: expiresAt,
    );
  }

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static dynamic _timestampToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }

  // MediaAttachment list serialization helpers
  static List<MediaAttachment>? _mediaAttachmentsFromJson(dynamic json) {
    if (json == null) return null;
    if (json is List) {
      return json.map((item) => MediaAttachment.fromJson(item as Map<String, dynamic>)).toList();
    }
    return null;
  }

  static dynamic _mediaAttachmentsToJson(List<MediaAttachment>? attachments) {
    if (attachments == null) return null;
    return attachments.map((attachment) => attachment.toJson()).toList();
  }
}

/// Chat room model for club conversations
/// Kulüp konuşmaları için sohbet odası modeli
@JsonSerializable()
class ChatRoom {
  @JsonKey(name: 'chatRoomId')
  final String chatRoomId;

  @JsonKey(name: 'clubId')
  final String clubId;

  @JsonKey(name: 'clubName')
  final String clubName;

  // Room Settings
  @JsonKey(name: 'isActive')
  final bool isActive;

  @JsonKey(name: 'requiresApproval')
  final bool requiresApproval;

  // Participants
  @JsonKey(name: 'participantCount')
  final int participantCount;

  @JsonKey(name: 'maxParticipants')
  final int? maxParticipants;

  // Last Message Info
  @JsonKey(name: 'lastMessageId')
  final String? lastMessageId;

  @JsonKey(name: 'lastMessageContent')
  final String? lastMessageContent;

  @JsonKey(name: 'lastMessageSenderName')
  final String? lastMessageSenderName;

  @JsonKey(name: 'lastMessageAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? lastMessageAt;

  // Timestamps
  @JsonKey(name: 'createdAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  @JsonKey(name: 'updatedAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? updatedAt;

  const ChatRoom({
    required this.chatRoomId,
    required this.clubId,
    required this.clubName,
    this.isActive = true,
    this.requiresApproval = true,
    this.participantCount = 0,
    this.maxParticipants,
    this.lastMessageId,
    this.lastMessageContent,
    this.lastMessageSenderName,
    this.lastMessageAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) => _$ChatRoomFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRoomToJson(this);

  /// Create a new chat room for club
  /// Kulüp için yeni sohbet odası oluştur
  factory ChatRoom.create({
    required String clubId,
    required String clubName,
    bool requiresApproval = true,
    int? maxParticipants,
  }) {
    return ChatRoom(
      chatRoomId: clubId, // Use clubId as chatRoomId for simplicity
      clubId: clubId,
      clubName: clubName,
      requiresApproval: requiresApproval,
      maxParticipants: maxParticipants,
      createdAt: DateTime.now(),
    );
  }

  /// Update last message info
  /// Son mesaj bilgilerini güncelle
  ChatRoom updateLastMessage({
    required String messageId,
    required String content,
    required String senderName,
  }) {
    return ChatRoom(
      chatRoomId: chatRoomId,
      clubId: clubId,
      clubName: clubName,
      isActive: isActive,
      requiresApproval: requiresApproval,
      participantCount: participantCount,
      maxParticipants: maxParticipants,
      lastMessageId: messageId,
      lastMessageContent: content,
      lastMessageSenderName: senderName,
      lastMessageAt: DateTime.now(),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static dynamic _timestampToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}

/// Pending approval model for chat room access
/// Sohbet odası erişimi için bekleyen onay modeli
@JsonSerializable()
class PendingApproval {
  @JsonKey(name: 'approvalId')
  final String approvalId;

  @JsonKey(name: 'chatRoomId')
  final String chatRoomId;

  @JsonKey(name: 'clubId')
  final String clubId;

  // User requesting access
  @JsonKey(name: 'userId')
  final String userId;

  @JsonKey(name: 'userName')
  final String userName;

  @JsonKey(name: 'userAvatar')
  final String? userAvatar;

  @JsonKey(name: 'userEmail')
  final String? userEmail;

  // Request details
  @JsonKey(name: 'requestMessage')
  final String? requestMessage;

  @JsonKey(name: 'status')
  final String status; // 'pending', 'approved', 'rejected'

  // Decision details
  @JsonKey(name: 'decidedBy')
  final String? decidedBy; // Club creator/admin ID

  @JsonKey(name: 'decisionMessage')
  final String? decisionMessage;

  @JsonKey(name: 'decidedAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? decidedAt;

  // Timestamps
  @JsonKey(name: 'requestedAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime requestedAt;

  @JsonKey(name: 'expiresAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime expiresAt; // Auto-expire after 30 days

  const PendingApproval({
    required this.approvalId,
    required this.chatRoomId,
    required this.clubId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.userEmail,
    this.requestMessage,
    this.status = 'pending',
    this.decidedBy,
    this.decisionMessage,
    this.decidedAt,
    required this.requestedAt,
    required this.expiresAt,
  });

  factory PendingApproval.fromJson(Map<String, dynamic> json) => _$PendingApprovalFromJson(json);
  Map<String, dynamic> toJson() => _$PendingApprovalToJson(this);

  /// Create a new approval request
  /// Yeni onay talebi oluştur
  factory PendingApproval.create({
    required String chatRoomId,
    required String clubId,
    required String userId,
    required String userName,
    String? userAvatar,
    String? userEmail,
    String? requestMessage,
  }) {
    final now = DateTime.now();
    final expiry = now.add(const Duration(days: 30)); // 30-day expiry
    
    return PendingApproval(
      approvalId: '', // Will be set by Firestore
      chatRoomId: chatRoomId,
      clubId: clubId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      userEmail: userEmail,
      requestMessage: requestMessage,
      requestedAt: now,
      expiresAt: expiry,
    );
  }

  /// Approve the request
  /// Talebi onayla
  PendingApproval approve({
    required String decidedBy,
    String? decisionMessage,
  }) {
    return PendingApproval(
      approvalId: approvalId,
      chatRoomId: chatRoomId,
      clubId: clubId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      userEmail: userEmail,
      requestMessage: requestMessage,
      status: 'approved',
      decidedBy: decidedBy,
      decisionMessage: decisionMessage,
      decidedAt: DateTime.now(),
      requestedAt: requestedAt,
      expiresAt: expiresAt,
    );
  }

  /// Reject the request
  /// Talebi reddet
  PendingApproval reject({
    required String decidedBy,
    String? decisionMessage,
  }) {
    return PendingApproval(
      approvalId: approvalId,
      chatRoomId: chatRoomId,
      clubId: clubId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      userEmail: userEmail,
      requestMessage: requestMessage,
      status: 'rejected',
      decidedBy: decidedBy,
      decisionMessage: decisionMessage,
      decidedAt: DateTime.now(),
      requestedAt: requestedAt,
      expiresAt: expiresAt,
    );
  }

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static dynamic _timestampToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}

/// Chat participant model to track who can access chat
/// Sohbete kimlerin erişebileceğini takip etmek için sohbet katılımcısı modeli
@JsonSerializable()
class ChatParticipant {
  @JsonKey(name: 'participantId')
  final String participantId;

  @JsonKey(name: 'chatRoomId')
  final String chatRoomId;

  @JsonKey(name: 'clubId')
  final String clubId;

  @JsonKey(name: 'userId')
  final String userId;

  @JsonKey(name: 'userName')
  final String userName;

  @JsonKey(name: 'userAvatar')
  final String? userAvatar;

  // Participant role and permissions
  @JsonKey(name: 'role')
  final String role; // 'creator', 'admin', 'member'

  @JsonKey(name: 'permissions')
  final List<String> permissions; // ['send_messages', 'delete_messages', 'moderate', etc.]

  // Status
  @JsonKey(name: 'isActive')
  final bool isActive;

  @JsonKey(name: 'isMuted')
  final bool isMuted;

  @JsonKey(name: 'mutedUntil', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? mutedUntil;

  // Activity tracking
  @JsonKey(name: 'lastSeenAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? lastSeenAt;

  @JsonKey(name: 'lastMessageAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? lastMessageAt;

  // Timestamps
  @JsonKey(name: 'joinedAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime joinedAt;

  @JsonKey(name: 'updatedAt', fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime? updatedAt;

  const ChatParticipant({
    required this.participantId,
    required this.chatRoomId,
    required this.clubId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.role = 'member',
    this.permissions = const ['send_messages'],
    this.isActive = true,
    this.isMuted = false,
    this.mutedUntil,
    this.lastSeenAt,
    this.lastMessageAt,
    required this.joinedAt,
    this.updatedAt,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) => _$ChatParticipantFromJson(json);
  Map<String, dynamic> toJson() => _$ChatParticipantToJson(this);

  /// Create a new chat participant
  /// Yeni sohbet katılımcısı oluştur
  factory ChatParticipant.create({
    required String chatRoomId,
    required String clubId,
    required String userId,
    required String userName,
    String? userAvatar,
    String role = 'member',
    List<String> permissions = const ['send_messages'],
  }) {
    return ChatParticipant(
      participantId: userId, // Use userId as participantId
      chatRoomId: chatRoomId,
      clubId: clubId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      role: role,
      permissions: permissions,
      joinedAt: DateTime.now(),
    );
  }

  /// Update last seen timestamp
  /// Son görülme zamanını güncelle
  ChatParticipant updateLastSeen() {
    return ChatParticipant(
      participantId: participantId,
      chatRoomId: chatRoomId,
      clubId: clubId,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      role: role,
      permissions: permissions,
      isActive: isActive,
      isMuted: isMuted,
      mutedUntil: mutedUntil,
      lastSeenAt: DateTime.now(),
      lastMessageAt: lastMessageAt,
      joinedAt: joinedAt,
      updatedAt: DateTime.now(),
    );
  }

  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static dynamic _timestampToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}