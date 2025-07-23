import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'club_chat_models.g.dart';

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
  }) {
    return ChatMessage(
      messageId: messageId,
      chatRoomId: chatRoomId,
      clubId: clubId,
      content: newContent,
      messageType: messageType,
      mediaUrls: newMediaUrls ?? mediaUrls,
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