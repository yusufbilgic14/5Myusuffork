// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_interaction_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventComment _$EventCommentFromJson(Map<String, dynamic> json) => EventComment(
  commentId: json['commentId'] as String,
  eventId: json['eventId'] as String,
  content: json['content'] as String,
  contentType: json['contentType'] as String? ?? 'text',
  mediaUrls: (json['mediaUrls'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  authorId: json['authorId'] as String,
  authorName: json['authorName'] as String,
  authorAvatar: json['authorAvatar'] as String?,
  parentCommentId: json['parentCommentId'] as String?,
  replyLevel: (json['replyLevel'] as num?)?.toInt() ?? 0,
  replyCount: (json['replyCount'] as num?)?.toInt() ?? 0,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  status:
      $enumDecodeNullable(_$CommentStatusEnumMap, json['status']) ??
      CommentStatus.active,
  isEdited: json['isEdited'] as bool? ?? false,
  editedAt: const NullableTimestampConverter().fromJson(json['editedAt']),
  createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
  updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$EventCommentToJson(
  EventComment instance,
) => <String, dynamic>{
  'commentId': instance.commentId,
  'eventId': instance.eventId,
  'content': instance.content,
  'contentType': instance.contentType,
  'mediaUrls': instance.mediaUrls,
  'authorId': instance.authorId,
  'authorName': instance.authorName,
  'authorAvatar': instance.authorAvatar,
  'parentCommentId': instance.parentCommentId,
  'replyLevel': instance.replyLevel,
  'replyCount': instance.replyCount,
  'likeCount': instance.likeCount,
  'status': _$CommentStatusEnumMap[instance.status]!,
  'isEdited': instance.isEdited,
  'editedAt': ?const NullableTimestampConverter().toJson(instance.editedAt),
  'createdAt': ?const NullableTimestampConverter().toJson(instance.createdAt),
  'updatedAt': ?const NullableTimestampConverter().toJson(instance.updatedAt),
};

const _$CommentStatusEnumMap = {
  CommentStatus.active: 'active',
  CommentStatus.hidden: 'hidden',
  CommentStatus.deleted: 'deleted',
  CommentStatus.flagged: 'flagged',
};

CommentLike _$CommentLikeFromJson(Map<String, dynamic> json) => CommentLike(
  commentId: json['commentId'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  likedAt: const NullableTimestampConverter().fromJson(json['likedAt']),
);

Map<String, dynamic> _$CommentLikeToJson(CommentLike instance) =>
    <String, dynamic>{
      'commentId': instance.commentId,
      'userId': instance.userId,
      'userName': instance.userName,
      'likedAt': ?const NullableTimestampConverter().toJson(instance.likedAt),
    };

UserFollowedClub _$UserFollowedClubFromJson(Map<String, dynamic> json) =>
    UserFollowedClub(
      clubId: json['clubId'] as String,
      clubName: json['clubName'] as String,
      clubType: json['clubType'] as String,
      clubAvatar: json['clubAvatar'] as String?,
      followedAt: const NullableTimestampConverter().fromJson(
        json['followedAt'],
      ),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      eventCount: (json['eventCount'] as num?)?.toInt() ?? 0,
      lastEventDate: const NullableTimestampConverter().fromJson(
        json['lastEventDate'],
      ),
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
      updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$UserFollowedClubToJson(
  UserFollowedClub instance,
) => <String, dynamic>{
  'clubId': instance.clubId,
  'clubName': instance.clubName,
  'clubType': instance.clubType,
  'clubAvatar': instance.clubAvatar,
  'followedAt': ?const NullableTimestampConverter().toJson(instance.followedAt),
  'notificationsEnabled': instance.notificationsEnabled,
  'eventCount': instance.eventCount,
  'lastEventDate': ?const NullableTimestampConverter().toJson(
    instance.lastEventDate,
  ),
  'createdAt': ?const NullableTimestampConverter().toJson(instance.createdAt),
  'updatedAt': ?const NullableTimestampConverter().toJson(instance.updatedAt),
};

Club _$ClubFromJson(Map<String, dynamic> json) => Club(
  clubId: json['clubId'] as String,
  name: json['name'] as String,
  displayName: json['displayName'] as String,
  description: json['description'] as String,
  logoUrl: json['logoUrl'] as String?,
  bannerUrl: json['bannerUrl'] as String?,
  colors: json['colors'] == null
      ? const ClubColors()
      : ClubColors.fromJson(json['colors'] as Map<String, dynamic>),
  email: json['email'] as String?,
  website: json['website'] as String?,
  socialMedia: json['socialMedia'] == null
      ? const SocialMedia()
      : SocialMedia.fromJson(json['socialMedia'] as Map<String, dynamic>),
  category: json['category'] as String,
  department: json['department'] as String?,
  faculty: json['faculty'] as String?,
  establishedYear: (json['establishedYear'] as num?)?.toInt(),
  memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
  followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
  adminIds:
      (json['adminIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  moderatorIds:
      (json['moderatorIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  status:
      $enumDecodeNullable(_$ClubStatusEnumMap, json['status']) ??
      ClubStatus.active,
  verificationStatus:
      $enumDecodeNullable(
        _$VerificationStatusEnumMap,
        json['verificationStatus'],
      ) ??
      VerificationStatus.unverified,
  createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
  updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
  createdBy: json['createdBy'] as String,
);

Map<String, dynamic> _$ClubToJson(Club instance) => <String, dynamic>{
  'clubId': instance.clubId,
  'name': instance.name,
  'displayName': instance.displayName,
  'description': instance.description,
  'logoUrl': instance.logoUrl,
  'bannerUrl': instance.bannerUrl,
  'colors': instance.colors,
  'email': instance.email,
  'website': instance.website,
  'socialMedia': instance.socialMedia,
  'category': instance.category,
  'department': instance.department,
  'faculty': instance.faculty,
  'establishedYear': instance.establishedYear,
  'memberCount': instance.memberCount,
  'followerCount': instance.followerCount,
  'isActive': instance.isActive,
  'adminIds': instance.adminIds,
  'moderatorIds': instance.moderatorIds,
  'status': _$ClubStatusEnumMap[instance.status]!,
  'verificationStatus':
      _$VerificationStatusEnumMap[instance.verificationStatus]!,
  'createdAt': ?const NullableTimestampConverter().toJson(instance.createdAt),
  'updatedAt': ?const NullableTimestampConverter().toJson(instance.updatedAt),
  'createdBy': instance.createdBy,
};

const _$ClubStatusEnumMap = {
  ClubStatus.active: 'active',
  ClubStatus.inactive: 'inactive',
  ClubStatus.suspended: 'suspended',
};

const _$VerificationStatusEnumMap = {
  VerificationStatus.verified: 'verified',
  VerificationStatus.pending: 'pending',
  VerificationStatus.unverified: 'unverified',
};

ClubColors _$ClubColorsFromJson(Map<String, dynamic> json) => ClubColors(
  primary: json['primary'] as String? ?? '#1E3A8A',
  secondary: json['secondary'] as String? ?? '#3B82F6',
);

Map<String, dynamic> _$ClubColorsToJson(ClubColors instance) =>
    <String, dynamic>{
      'primary': instance.primary,
      'secondary': instance.secondary,
    };

SocialMedia _$SocialMediaFromJson(Map<String, dynamic> json) => SocialMedia(
  instagram: json['instagram'] as String?,
  twitter: json['twitter'] as String?,
  facebook: json['facebook'] as String?,
  linkedin: json['linkedin'] as String?,
);

Map<String, dynamic> _$SocialMediaToJson(SocialMedia instance) =>
    <String, dynamic>{
      'instagram': instance.instagram,
      'twitter': instance.twitter,
      'facebook': instance.facebook,
      'linkedin': instance.linkedin,
    };
