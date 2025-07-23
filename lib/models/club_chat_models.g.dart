// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  messageId: json['messageId'] as String,
  chatRoomId: json['chatRoomId'] as String,
  clubId: json['clubId'] as String,
  content: json['content'] as String,
  messageType: json['messageType'] as String? ?? 'text',
  mediaUrls: (json['mediaUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  senderAvatar: json['senderAvatar'] as String?,
  replyToMessageId: json['replyToMessageId'] as String?,
  replyToContent: json['replyToContent'] as String?,
  replyToSenderName: json['replyToSenderName'] as String?,
  createdAt: ChatMessage._timestampFromJson(json['createdAt']),
  updatedAt: ChatMessage._timestampFromJson(json['updatedAt']),
  isEdited: json['isEdited'] as bool? ?? false,
  isDeleted: json['isDeleted'] as bool? ?? false,
  deletedAt: ChatMessage._timestampFromJson(json['deletedAt']),
  expiresAt: ChatMessage._timestampFromJson(json['expiresAt']),
);

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'messageId': instance.messageId,
      'chatRoomId': instance.chatRoomId,
      'clubId': instance.clubId,
      'content': instance.content,
      'messageType': instance.messageType,
      'mediaUrls': instance.mediaUrls,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderAvatar': instance.senderAvatar,
      'replyToMessageId': instance.replyToMessageId,
      'replyToContent': instance.replyToContent,
      'replyToSenderName': instance.replyToSenderName,
      'createdAt': ChatMessage._timestampToJson(instance.createdAt),
      'updatedAt': ChatMessage._timestampToJson(instance.updatedAt),
      'isEdited': instance.isEdited,
      'isDeleted': instance.isDeleted,
      'deletedAt': ChatMessage._timestampToJson(instance.deletedAt),
      'expiresAt': ChatMessage._timestampToJson(instance.expiresAt),
    };

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => ChatRoom(
  chatRoomId: json['chatRoomId'] as String,
  clubId: json['clubId'] as String,
  clubName: json['clubName'] as String,
  isActive: json['isActive'] as bool? ?? true,
  requiresApproval: json['requiresApproval'] as bool? ?? true,
  participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
  maxParticipants: (json['maxParticipants'] as num?)?.toInt(),
  lastMessageId: json['lastMessageId'] as String?,
  lastMessageContent: json['lastMessageContent'] as String?,
  lastMessageSenderName: json['lastMessageSenderName'] as String?,
  lastMessageAt: ChatRoom._timestampFromJson(json['lastMessageAt']),
  createdAt: ChatRoom._timestampFromJson(json['createdAt']),
  updatedAt: ChatRoom._timestampFromJson(json['updatedAt']),
);

Map<String, dynamic> _$ChatRoomToJson(ChatRoom instance) => <String, dynamic>{
  'chatRoomId': instance.chatRoomId,
  'clubId': instance.clubId,
  'clubName': instance.clubName,
  'isActive': instance.isActive,
  'requiresApproval': instance.requiresApproval,
  'participantCount': instance.participantCount,
  'maxParticipants': instance.maxParticipants,
  'lastMessageId': instance.lastMessageId,
  'lastMessageContent': instance.lastMessageContent,
  'lastMessageSenderName': instance.lastMessageSenderName,
  'lastMessageAt': ChatRoom._timestampToJson(instance.lastMessageAt),
  'createdAt': ChatRoom._timestampToJson(instance.createdAt),
  'updatedAt': ChatRoom._timestampToJson(instance.updatedAt),
};

PendingApproval _$PendingApprovalFromJson(Map<String, dynamic> json) =>
    PendingApproval(
      approvalId: json['approvalId'] as String,
      chatRoomId: json['chatRoomId'] as String,
      clubId: json['clubId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      userEmail: json['userEmail'] as String?,
      requestMessage: json['requestMessage'] as String?,
      status: json['status'] as String? ?? 'pending',
      decidedBy: json['decidedBy'] as String?,
      decisionMessage: json['decisionMessage'] as String?,
      decidedAt: PendingApproval._timestampFromJson(json['decidedAt']),
      requestedAt: PendingApproval._timestampFromJson(json['requestedAt']),
      expiresAt: PendingApproval._timestampFromJson(json['expiresAt']),
    );

Map<String, dynamic> _$PendingApprovalToJson(PendingApproval instance) =>
    <String, dynamic>{
      'approvalId': instance.approvalId,
      'chatRoomId': instance.chatRoomId,
      'clubId': instance.clubId,
      'userId': instance.userId,
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
      'userEmail': instance.userEmail,
      'requestMessage': instance.requestMessage,
      'status': instance.status,
      'decidedBy': instance.decidedBy,
      'decisionMessage': instance.decisionMessage,
      'decidedAt': PendingApproval._timestampToJson(instance.decidedAt),
      'requestedAt': PendingApproval._timestampToJson(instance.requestedAt),
      'expiresAt': PendingApproval._timestampToJson(instance.expiresAt),
    };

ChatParticipant _$ChatParticipantFromJson(Map<String, dynamic> json) =>
    ChatParticipant(
      participantId: json['participantId'] as String,
      chatRoomId: json['chatRoomId'] as String,
      clubId: json['clubId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      role: json['role'] as String? ?? 'member',
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['send_messages'],
      isActive: json['isActive'] as bool? ?? true,
      isMuted: json['isMuted'] as bool? ?? false,
      mutedUntil: ChatParticipant._timestampFromJson(json['mutedUntil']),
      lastSeenAt: ChatParticipant._timestampFromJson(json['lastSeenAt']),
      lastMessageAt: ChatParticipant._timestampFromJson(json['lastMessageAt']),
      joinedAt: ChatParticipant._timestampFromJson(json['joinedAt']),
      updatedAt: ChatParticipant._timestampFromJson(json['updatedAt']),
    );

Map<String, dynamic> _$ChatParticipantToJson(ChatParticipant instance) =>
    <String, dynamic>{
      'participantId': instance.participantId,
      'chatRoomId': instance.chatRoomId,
      'clubId': instance.clubId,
      'userId': instance.userId,
      'userName': instance.userName,
      'userAvatar': instance.userAvatar,
      'role': instance.role,
      'permissions': instance.permissions,
      'isActive': instance.isActive,
      'isMuted': instance.isMuted,
      'mutedUntil': ChatParticipant._timestampToJson(instance.mutedUntil),
      'lastSeenAt': ChatParticipant._timestampToJson(instance.lastSeenAt),
      'lastMessageAt': ChatParticipant._timestampToJson(instance.lastMessageAt),
      'joinedAt': ChatParticipant._timestampToJson(instance.joinedAt),
      'updatedAt': ChatParticipant._timestampToJson(instance.updatedAt),
    };
