import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

part 'user_interaction_models.g.dart';

/// Event comment model
/// Etkinlik yorumu modeli
@JsonSerializable()
class EventComment {
  @JsonKey(name: 'commentId')
  final String commentId;

  @JsonKey(name: 'eventId')
  final String eventId;

  // Comment Content
  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'contentType')
  final String contentType; // 'text' or 'text_with_media'

  @JsonKey(name: 'mediaUrls')
  final List<String>? mediaUrls;

  // Author Information
  @JsonKey(name: 'authorId')
  final String authorId;

  @JsonKey(name: 'authorName')
  final String authorName;

  @JsonKey(name: 'authorAvatar')
  final String? authorAvatar;

  // Reply System
  @JsonKey(name: 'parentCommentId')
  final String? parentCommentId;

  @JsonKey(name: 'replyLevel')
  final int replyLevel; // 0 = top-level, 1 = reply, 2 = reply to reply, etc.

  @JsonKey(name: 'replyCount')
  final int replyCount;

  // Engagement
  @JsonKey(name: 'likeCount')
  final int likeCount;

  // Status & Moderation
  @JsonKey(name: 'status')
  final CommentStatus status;

  @JsonKey(name: 'isEdited')
  final bool isEdited;

  @JsonKey(name: 'editedAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? editedAt;

  // Metadata
  @JsonKey(name: 'createdAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? updatedAt;

  const EventComment({
    required this.commentId,
    required this.eventId,
    required this.content,
    this.contentType = 'text',
    this.mediaUrls,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.parentCommentId,
    this.replyLevel = 0,
    this.replyCount = 0,
    this.likeCount = 0,
    this.status = CommentStatus.active,
    this.isEdited = false,
    this.editedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory EventComment.fromJson(Map<String, dynamic> json) =>
      _$EventCommentFromJson(json);
  Map<String, dynamic> toJson() => _$EventCommentToJson(this);

  /// Create from Firestore data
  factory EventComment.fromFirestoreData(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final jsonData = Map<String, dynamic>.from(data);

    // Set comment ID if not present
    if (!jsonData.containsKey('commentId')) {
      jsonData['commentId'] = documentId;
    }

    // Convert Timestamps to DateTime strings
    _convertTimestampFields(jsonData, ['editedAt', 'createdAt', 'updatedAt']);

    return EventComment.fromJson(jsonData);
  }

  /// Create Firestore-compatible data
  Map<String, dynamic> toFirestoreData() {
    final data = toJson();

    // Convert DateTime fields to Timestamps
    _convertDateTimeToTimestamp(data, 'editedAt', editedAt);
    _convertDateTimeToTimestamp(data, 'createdAt', createdAt);
    _convertDateTimeToTimestamp(data, 'updatedAt', updatedAt);

    return data;
  }

  /// Check if this is a top-level comment
  bool get isTopLevel => replyLevel == 0;

  /// Check if this is a reply
  bool get isReply => replyLevel > 0;

  /// Check if comment has media
  bool get hasMedia => mediaUrls != null && mediaUrls!.isNotEmpty;

  /// Get time since creation
  String getTimeAgo() {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  EventComment copyWith({
    String? commentId,
    String? eventId,
    String? content,
    String? contentType,
    List<String>? mediaUrls,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? parentCommentId,
    int? replyLevel,
    int? replyCount,
    int? likeCount,
    CommentStatus? status,
    bool? isEdited,
    DateTime? editedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventComment(
      commentId: commentId ?? this.commentId,
      eventId: eventId ?? this.eventId,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replyLevel: replyLevel ?? this.replyLevel,
      replyCount: replyCount ?? this.replyCount,
      likeCount: likeCount ?? this.likeCount,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'EventComment{commentId: $commentId, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content}}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventComment &&
          runtimeType == other.runtimeType &&
          commentId == other.commentId;

  @override
  int get hashCode => commentId.hashCode;
}

/// Comment like model
/// Yorum beğenisi modeli
@JsonSerializable()
class CommentLike {
  @JsonKey(name: 'commentId')
  final String commentId;

  @JsonKey(name: 'userId')
  final String userId;

  @JsonKey(name: 'userName')
  final String userName;

  @JsonKey(name: 'likedAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? likedAt;

  const CommentLike({
    required this.commentId,
    required this.userId,
    required this.userName,
    this.likedAt,
  });

  factory CommentLike.fromJson(Map<String, dynamic> json) =>
      _$CommentLikeFromJson(json);
  Map<String, dynamic> toJson() => _$CommentLikeToJson(this);

  /// Create from Firestore data
  factory CommentLike.fromFirestoreData(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final jsonData = Map<String, dynamic>.from(data);

    // Set user ID if not present (document ID should be user ID)
    if (!jsonData.containsKey('userId')) {
      jsonData['userId'] = documentId;
    }

    // Convert Timestamps to DateTime strings
    _convertTimestampFields(jsonData, ['likedAt']);

    return CommentLike.fromJson(jsonData);
  }

  /// Create Firestore-compatible data
  Map<String, dynamic> toFirestoreData() {
    final data = toJson();

    // Convert DateTime fields to Timestamps
    _convertDateTimeToTimestamp(data, 'likedAt', likedAt);

    return data;
  }

  @override
  String toString() =>
      'CommentLike{commentId: $commentId, userId: $userId, userName: $userName}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentLike &&
          runtimeType == other.runtimeType &&
          commentId == other.commentId &&
          userId == other.userId;

  @override
  int get hashCode => Object.hash(commentId, userId);
}

/// User followed club model
/// Kullanıcı takip edilen kulüp modeli
@JsonSerializable()
class UserFollowedClub {
  @JsonKey(name: 'clubId')
  final String clubId;

  @JsonKey(name: 'clubName')
  final String clubName;

  @JsonKey(name: 'clubType')
  final String clubType; // 'student_club', 'department', 'university_organization'

  @JsonKey(name: 'clubAvatar')
  final String? clubAvatar;

  // Follow Details
  @JsonKey(name: 'followedAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? followedAt;

  @JsonKey(name: 'notificationsEnabled')
  final bool notificationsEnabled;

  // Engagement
  @JsonKey(name: 'eventCount')
  final int eventCount;

  @JsonKey(name: 'lastEventDate', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? lastEventDate;

  // Metadata
  @JsonKey(name: 'createdAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? updatedAt;

  const UserFollowedClub({
    required this.clubId,
    required this.clubName,
    required this.clubType,
    this.clubAvatar,
    this.followedAt,
    this.notificationsEnabled = true,
    this.eventCount = 0,
    this.lastEventDate,
    this.createdAt,
    this.updatedAt,
  });

  factory UserFollowedClub.fromJson(Map<String, dynamic> json) =>
      _$UserFollowedClubFromJson(json);
  Map<String, dynamic> toJson() => _$UserFollowedClubToJson(this);

  /// Create from Firestore data
  factory UserFollowedClub.fromFirestoreData(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final jsonData = Map<String, dynamic>.from(data);

    // Set club ID if not present
    if (!jsonData.containsKey('clubId')) {
      jsonData['clubId'] = documentId;
    }

    // Convert Timestamps to DateTime strings
    _convertTimestampFields(jsonData, [
      'followedAt',
      'lastEventDate',
      'createdAt',
      'updatedAt',
    ]);

    return UserFollowedClub.fromJson(jsonData);
  }

  /// Create Firestore-compatible data
  Map<String, dynamic> toFirestoreData() {
    final data = toJson();

    // Convert DateTime fields to Timestamps
    _convertDateTimeToTimestamp(data, 'followedAt', followedAt);
    _convertDateTimeToTimestamp(data, 'lastEventDate', lastEventDate);
    _convertDateTimeToTimestamp(data, 'createdAt', createdAt);
    _convertDateTimeToTimestamp(data, 'updatedAt', updatedAt);

    return data;
  }

  UserFollowedClub copyWith({
    String? clubId,
    String? clubName,
    String? clubType,
    String? clubAvatar,
    DateTime? followedAt,
    bool? notificationsEnabled,
    int? eventCount,
    DateTime? lastEventDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserFollowedClub(
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      clubType: clubType ?? this.clubType,
      clubAvatar: clubAvatar ?? this.clubAvatar,
      followedAt: followedAt ?? this.followedAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      eventCount: eventCount ?? this.eventCount,
      lastEventDate: lastEventDate ?? this.lastEventDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'UserFollowedClub{clubId: $clubId, clubName: $clubName}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserFollowedClub &&
          runtimeType == other.runtimeType &&
          clubId == other.clubId;

  @override
  int get hashCode => clubId.hashCode;
}

/// Club/Organization model
/// Kulüp/Organizasyon modeli
@JsonSerializable()
class Club {
  @JsonKey(name: 'clubId')
  final String clubId;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'displayName')
  final String displayName;

  @JsonKey(name: 'description')
  final String description;

  // Visual Identity
  @JsonKey(name: 'logoUrl')
  final String? logoUrl;

  @JsonKey(name: 'bannerUrl')
  final String? bannerUrl;

  @JsonKey(name: 'colors')
  final ClubColors colors;

  // Contact Information
  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'website')
  final String? website;

  @JsonKey(name: 'socialMedia')
  final SocialMedia socialMedia;

  // Club Details
  @JsonKey(name: 'category')
  final String category;

  @JsonKey(name: 'department')
  final String? department;

  @JsonKey(name: 'faculty')
  final String? faculty;

  @JsonKey(name: 'establishedYear')
  final int? establishedYear;

  // Membership
  @JsonKey(name: 'memberCount')
  final int memberCount;

  @JsonKey(name: 'followerCount')
  final int followerCount;

  @JsonKey(name: 'isActive')
  final bool isActive;

  // Management
  @JsonKey(name: 'adminIds')
  final List<String> adminIds;

  @JsonKey(name: 'moderatorIds')
  final List<String> moderatorIds;

  // Status
  @JsonKey(name: 'status')
  final ClubStatus status;

  @JsonKey(name: 'verificationStatus')
  final VerificationStatus verificationStatus;

  // Metadata
  @JsonKey(name: 'createdAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? updatedAt;

  @JsonKey(name: 'createdBy')
  final String createdBy;

  const Club({
    required this.clubId,
    required this.name,
    required this.displayName,
    required this.description,
    this.logoUrl,
    this.bannerUrl,
    this.colors = const ClubColors(),
    this.email,
    this.website,
    this.socialMedia = const SocialMedia(),
    required this.category,
    this.department,
    this.faculty,
    this.establishedYear,
    this.memberCount = 0,
    this.followerCount = 0,
    this.isActive = true,
    this.adminIds = const [],
    this.moderatorIds = const [],
    this.status = ClubStatus.active,
    this.verificationStatus = VerificationStatus.unverified,
    this.createdAt,
    this.updatedAt,
    required this.createdBy,
  });

  factory Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);
  Map<String, dynamic> toJson() => _$ClubToJson(this);

  /// Create from Firestore data
  factory Club.fromFirestoreData(Map<String, dynamic> data, String documentId) {
    final jsonData = Map<String, dynamic>.from(data);

    // Set club ID if not present
    if (!jsonData.containsKey('clubId')) {
      jsonData['clubId'] = documentId;
    }

    // Convert Timestamps to DateTime strings
    _convertTimestampFields(jsonData, ['createdAt', 'updatedAt']);

    return Club.fromJson(jsonData);
  }

  /// Create Firestore-compatible data
  Map<String, dynamic> toFirestoreData() {
    final data = toJson();

    // Convert DateTime fields to Timestamps
    _convertDateTimeToTimestamp(data, 'createdAt', createdAt);
    _convertDateTimeToTimestamp(data, 'updatedAt', updatedAt);

    return data;
  }

  @override
  String toString() => 'Club{clubId: $clubId, name: $name}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Club &&
          runtimeType == other.runtimeType &&
          clubId == other.clubId;

  @override
  int get hashCode => clubId.hashCode;
}

/// Club colors model
/// Kulüp renkleri modeli
@JsonSerializable()
class ClubColors {
  @JsonKey(name: 'primary')
  final String primary;

  @JsonKey(name: 'secondary')
  final String secondary;

  const ClubColors({this.primary = '#1E3A8A', this.secondary = '#3B82F6'});

  factory ClubColors.fromJson(Map<String, dynamic> json) =>
      _$ClubColorsFromJson(json);
  Map<String, dynamic> toJson() => _$ClubColorsToJson(this);

  /// Get primary color as Color object
  Color get primaryColor {
    try {
      return Color(int.parse(primary.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF1E3A8A);
    }
  }

  /// Get secondary color as Color object
  Color get secondaryColor {
    try {
      return Color(int.parse(secondary.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF3B82F6);
    }
  }
}

/// Social media model
/// Sosyal medya modeli
@JsonSerializable()
class SocialMedia {
  @JsonKey(name: 'instagram')
  final String? instagram;

  @JsonKey(name: 'twitter')
  final String? twitter;

  @JsonKey(name: 'facebook')
  final String? facebook;

  @JsonKey(name: 'linkedin')
  final String? linkedin;

  const SocialMedia({
    this.instagram,
    this.twitter,
    this.facebook,
    this.linkedin,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) =>
      _$SocialMediaFromJson(json);
  Map<String, dynamic> toJson() => _$SocialMediaToJson(this);

  /// Check if any social media links are available
  bool get hasAnyLinks =>
      instagram != null ||
      twitter != null ||
      facebook != null ||
      linkedin != null;
}

/// Comment status enum
/// Yorum durumu enum'u
enum CommentStatus {
  @JsonValue('active')
  active,
  @JsonValue('hidden')
  hidden,
  @JsonValue('deleted')
  deleted,
  @JsonValue('flagged')
  flagged,
}

/// Club status enum
/// Kulüp durumu enum'u
enum ClubStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('suspended')
  suspended,
}

/// Verification status enum
/// Doğrulama durumu enum'u
enum VerificationStatus {
  @JsonValue('verified')
  verified,
  @JsonValue('pending')
  pending,
  @JsonValue('unverified')
  unverified,
}

/// Nullable Firestore Timestamp converter
/// Nullable Firestore Timestamp dönüştürücüsü
class NullableTimestampConverter implements JsonConverter<DateTime?, Object?> {
  const NullableTimestampConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.tryParse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return null;
  }

  @override
  Object? toJson(DateTime? dateTime) {
    if (dateTime == null) return null;
    return dateTime.toIso8601String();
  }
}

/// Helper function to convert timestamp fields
/// Timestamp alanlarını dönüştürme yardımcı fonksiyonu
void _convertTimestampFields(Map<String, dynamic> data, List<String> fields) {
  for (final field in fields) {
    if (data[field] is Timestamp) {
      data[field] = (data[field] as Timestamp).toDate().toIso8601String();
    }
  }
}

/// Helper function to convert DateTime to Timestamp
/// DateTime'ı Timestamp'a dönüştürme yardımcı fonksiyonu
void _convertDateTimeToTimestamp(
  Map<String, dynamic> data,
  String field,
  DateTime? dateTime,
) {
  if (dateTime != null) {
    data[field] = Timestamp.fromDate(dateTime);
  }
}
