// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MediaAttachment _$MediaAttachmentFromJson(Map<String, dynamic> json) =>
    MediaAttachment(
      attachmentId: json['attachmentId'] as String,
      fileName: json['fileName'] as String,
      originalFileName: json['originalFileName'] as String,
      fileType: json['fileType'] as String,
      mimeType: json['mimeType'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      fileUrl: json['fileUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      uploadedAt: MediaAttachment._timestampFromJson(json['uploadedAt']),
    );

Map<String, dynamic> _$MediaAttachmentToJson(MediaAttachment instance) =>
    <String, dynamic>{
      'attachmentId': instance.attachmentId,
      'fileName': instance.fileName,
      'originalFileName': instance.originalFileName,
      'fileType': instance.fileType,
      'mimeType': instance.mimeType,
      'fileSize': instance.fileSize,
      'fileUrl': instance.fileUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'width': instance.width,
      'height': instance.height,
      'duration': instance.duration,
      'uploadedAt': MediaAttachment._timestampToJson(instance.uploadedAt),
    };

MessageReaction _$MessageReactionFromJson(Map<String, dynamic> json) =>
    MessageReaction(
      reactionId: json['reactionId'] as String,
      messageId: json['messageId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      emoji: json['emoji'] as String,
      createdAt: MessageReaction._timestampFromJson(json['createdAt']),
    );

Map<String, dynamic> _$MessageReactionToJson(MessageReaction instance) =>
    <String, dynamic>{
      'reactionId': instance.reactionId,
      'messageId': instance.messageId,
      'userId': instance.userId,
      'userName': instance.userName,
      'emoji': instance.emoji,
      'createdAt': MessageReaction._timestampToJson(instance.createdAt),
    };

UserPresence _$UserPresenceFromJson(Map<String, dynamic> json) => UserPresence(
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  chatRoomId: json['chatRoomId'] as String,
  isOnline: json['isOnline'] as bool? ?? false,
  isTyping: json['isTyping'] as bool? ?? false,
  lastSeen: UserPresence._timestampFromJson(json['lastSeen']),
  updatedAt: UserPresence._timestampFromJson(json['updatedAt']),
);

Map<String, dynamic> _$UserPresenceToJson(UserPresence instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'chatRoomId': instance.chatRoomId,
      'isOnline': instance.isOnline,
      'isTyping': instance.isTyping,
      'lastSeen': UserPresence._timestampToJson(instance.lastSeen),
      'updatedAt': UserPresence._timestampToJson(instance.updatedAt),
    };

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  messageId: json['messageId'] as String,
  chatRoomId: json['chatRoomId'] as String,
  clubId: json['clubId'] as String,
  content: json['content'] as String,
  messageType: json['messageType'] as String? ?? 'text',
  mediaUrls: (json['mediaUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  mediaAttachments: ChatMessage._mediaAttachmentsFromJson(
    json['mediaAttachments'],
  ),
  isPinned: json['isPinned'] as bool? ?? false,
  pinnedAt: ChatMessage._timestampFromJson(json['pinnedAt']),
  pinnedBy: json['pinnedBy'] as String?,
  reactionCount: (json['reactionCount'] as num?)?.toInt() ?? 0,
  reactions: (json['reactions'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, (e as num).toInt()),
  ),
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
      'mediaAttachments': ChatMessage._mediaAttachmentsToJson(
        instance.mediaAttachments,
      ),
      'isPinned': instance.isPinned,
      'pinnedAt': ChatMessage._timestampToJson(instance.pinnedAt),
      'pinnedBy': instance.pinnedBy,
      'reactionCount': instance.reactionCount,
      'reactions': instance.reactions,
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
