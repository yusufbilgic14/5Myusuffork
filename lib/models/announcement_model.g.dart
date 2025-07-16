// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'announcement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnnouncementModel _$AnnouncementModelFromJson(Map<String, dynamic> json) =>
    AnnouncementModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      summary: json['summary'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      targetAudience: TargetAudienceModel.fromJson(
        json['targetAudience'] as Map<String, dynamic>,
      ),
      category: $enumDecode(_$AnnouncementCategoryEnumMap, json['category']),
      priority: $enumDecode(_$AnnouncementPriorityEnumMap, json['priority']),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      status: $enumDecode(_$AnnouncementStatusEnumMap, json['status']),
      publishAt: const TimestampConverter().fromJson(json['publishAt']),
      expiresAt: const TimestampConverter().fromJson(json['expiresAt']),
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
      createdBy: json['createdBy'] as String,
      authorName: json['authorName'] as String,
      authorRole: json['authorRole'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      searchKeywords: (json['searchKeywords'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      slug: json['slug'] as String?,
    );

Map<String, dynamic> _$AnnouncementModelToJson(
  AnnouncementModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'summary': instance.summary,
  'images': instance.images,
  'attachments': instance.attachments,
  'targetAudience': instance.targetAudience,
  'category': _$AnnouncementCategoryEnumMap[instance.category]!,
  'priority': _$AnnouncementPriorityEnumMap[instance.priority]!,
  'tags': instance.tags,
  'status': _$AnnouncementStatusEnumMap[instance.status]!,
  if (const TimestampConverter().toJson(instance.publishAt) case final value?)
    'publishAt': value,
  if (const TimestampConverter().toJson(instance.expiresAt) case final value?)
    'expiresAt': value,
  'viewCount': instance.viewCount,
  'likeCount': instance.likeCount,
  'commentCount': instance.commentCount,
  'shareCount': instance.shareCount,
  'createdBy': instance.createdBy,
  'authorName': instance.authorName,
  'authorRole': instance.authorRole,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'searchKeywords': instance.searchKeywords,
  'slug': instance.slug,
};

const _$AnnouncementCategoryEnumMap = {
  AnnouncementCategory.general: 'general',
  AnnouncementCategory.academic: 'academic',
  AnnouncementCategory.administrative: 'administrative',
  AnnouncementCategory.social: 'social',
  AnnouncementCategory.urgent: 'urgent',
  AnnouncementCategory.event: 'event',
};

const _$AnnouncementPriorityEnumMap = {
  AnnouncementPriority.low: 'low',
  AnnouncementPriority.medium: 'medium',
  AnnouncementPriority.high: 'high',
  AnnouncementPriority.critical: 'critical',
};

const _$AnnouncementStatusEnumMap = {
  AnnouncementStatus.draft: 'draft',
  AnnouncementStatus.published: 'published',
  AnnouncementStatus.archived: 'archived',
  AnnouncementStatus.scheduled: 'scheduled',
};

AttachmentModel _$AttachmentModelFromJson(Map<String, dynamic> json) =>
    AttachmentModel(
      name: json['name'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$AttachmentModelToJson(AttachmentModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
      'type': instance.type,
      'size': instance.size,
    };

TargetAudienceModel _$TargetAudienceModelFromJson(Map<String, dynamic> json) =>
    TargetAudienceModel(
      roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
      departments: (json['departments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      faculties: (json['faculties'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      years: (json['years'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      userIds: (json['userIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$TargetAudienceModelToJson(
  TargetAudienceModel instance,
) => <String, dynamic>{
  'roles': instance.roles,
  'departments': instance.departments,
  'faculties': instance.faculties,
  'years': instance.years,
  'userIds': instance.userIds,
};
