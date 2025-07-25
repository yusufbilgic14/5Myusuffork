// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_event_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  eventId: json['eventId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  imageUrl: json['imageUrl'] as String?,
  eventType: json['eventType'] as String,
  category: json['category'] as String,
  location: json['location'] as String,
  building: json['building'] as String?,
  room: json['room'] as String?,
  startDateTime: const RequiredTimestampConverter().fromJson(
    json['startDateTime'],
  ),
  endDateTime: const RequiredTimestampConverter().fromJson(json['endDateTime']),
  timezone: json['timezone'] as String? ?? 'Europe/Istanbul',
  maxCapacity: (json['maxCapacity'] as num?)?.toInt(),
  requiresRegistration: json['requiresRegistration'] as bool? ?? false,
  registrationDeadline: const NullableTimestampConverter().fromJson(
    json['registrationDeadline'],
  ),
  organizerId: json['organizerId'] as String,
  organizerName: json['organizerName'] as String,
  organizerType: json['organizerType'] as String,
  clubId: json['clubId'] as String?,
  status: json['status'] as String? ?? 'published',
  isVisible: json['isVisible'] as bool? ?? true,
  isFeatured: json['isFeatured'] as bool? ?? false,
  likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  joinCount: (json['joinCount'] as num?)?.toInt() ?? 0,
  shareCount: (json['shareCount'] as num?)?.toInt() ?? 0,
  createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
  updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
  createdBy: json['createdBy'] as String,
  updatedBy: json['updatedBy'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  keywords:
      (json['keywords'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'eventId': instance.eventId,
  'title': instance.title,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'eventType': instance.eventType,
  'category': instance.category,
  'location': instance.location,
  'building': instance.building,
  'room': instance.room,
  'startDateTime': ?const RequiredTimestampConverter().toJson(
    instance.startDateTime,
  ),
  'endDateTime': ?const RequiredTimestampConverter().toJson(
    instance.endDateTime,
  ),
  'timezone': instance.timezone,
  'maxCapacity': instance.maxCapacity,
  'requiresRegistration': instance.requiresRegistration,
  'registrationDeadline': ?const NullableTimestampConverter().toJson(
    instance.registrationDeadline,
  ),
  'organizerId': instance.organizerId,
  'organizerName': instance.organizerName,
  'organizerType': instance.organizerType,
  'clubId': instance.clubId,
  'status': instance.status,
  'isVisible': instance.isVisible,
  'isFeatured': instance.isFeatured,
  'likeCount': instance.likeCount,
  'commentCount': instance.commentCount,
  'joinCount': instance.joinCount,
  'shareCount': instance.shareCount,
  'createdAt': ?const NullableTimestampConverter().toJson(instance.createdAt),
  'updatedAt': ?const NullableTimestampConverter().toJson(instance.updatedAt),
  'createdBy': instance.createdBy,
  'updatedBy': instance.updatedBy,
  'tags': instance.tags,
  'keywords': instance.keywords,
};

UserEventInteraction _$UserEventInteractionFromJson(
  Map<String, dynamic> json,
) => UserEventInteraction(
  eventId: json['eventId'] as String,
  userId: json['userId'] as String,
  hasLiked: json['hasLiked'] as bool? ?? false,
  hasJoined: json['hasJoined'] as bool? ?? false,
  hasShared: json['hasShared'] as bool? ?? false,
  isFavorited: json['isFavorited'] as bool? ?? false,
  joinedAt: const NullableTimestampConverter().fromJson(json['joinedAt']),
  leftAt: const NullableTimestampConverter().fromJson(json['leftAt']),
  joinStatus:
      $enumDecodeNullable(_$JoinStatusEnumMap, json['joinStatus']) ??
      JoinStatus.notJoined,
  notifyBeforeEvent: json['notifyBeforeEvent'] as bool? ?? true,
  notifyDayBefore: json['notifyDayBefore'] as bool? ?? true,
  notifyHourBefore: json['notifyHourBefore'] as bool? ?? true,
  likedAt: const NullableTimestampConverter().fromJson(json['likedAt']),
  unlikedAt: const NullableTimestampConverter().fromJson(json['unlikedAt']),
  createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
  updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$UserEventInteractionToJson(
  UserEventInteraction instance,
) => <String, dynamic>{
  'eventId': instance.eventId,
  'userId': instance.userId,
  'hasLiked': instance.hasLiked,
  'hasJoined': instance.hasJoined,
  'hasShared': instance.hasShared,
  'isFavorited': instance.isFavorited,
  'joinedAt': ?const NullableTimestampConverter().toJson(instance.joinedAt),
  'leftAt': ?const NullableTimestampConverter().toJson(instance.leftAt),
  'joinStatus': _$JoinStatusEnumMap[instance.joinStatus]!,
  'notifyBeforeEvent': instance.notifyBeforeEvent,
  'notifyDayBefore': instance.notifyDayBefore,
  'notifyHourBefore': instance.notifyHourBefore,
  'likedAt': ?const NullableTimestampConverter().toJson(instance.likedAt),
  'unlikedAt': ?const NullableTimestampConverter().toJson(instance.unlikedAt),
  'createdAt': ?const NullableTimestampConverter().toJson(instance.createdAt),
  'updatedAt': ?const NullableTimestampConverter().toJson(instance.updatedAt),
};

const _$JoinStatusEnumMap = {
  JoinStatus.notJoined: 'not_joined',
  JoinStatus.joined: 'joined',
  JoinStatus.waitlisted: 'waitlisted',
  JoinStatus.cancelled: 'cancelled',
};

UserMyEvent _$UserMyEventFromJson(Map<String, dynamic> json) => UserMyEvent(
  eventId: json['eventId'] as String,
  userId: json['userId'] as String,
  eventTitle: json['eventTitle'] as String,
  eventStartDate: const RequiredTimestampConverter().fromJson(
    json['eventStartDate'],
  ),
  eventEndDate: const RequiredTimestampConverter().fromJson(
    json['eventEndDate'],
  ),
  eventLocation: json['eventLocation'] as String,
  organizerName: json['organizerName'] as String,
  joinedAt: const RequiredTimestampConverter().fromJson(json['joinedAt']),
  joinMethod:
      $enumDecodeNullable(_$JoinMethodEnumMap, json['joinMethod']) ??
      JoinMethod.direct,
  participationStatus:
      $enumDecodeNullable(
        _$ParticipationStatusEnumMap,
        json['participationStatus'],
      ) ??
      ParticipationStatus.confirmed,
  personalNotes: json['personalNotes'] as String?,
  customReminders: json['customReminders'] == null
      ? const CustomReminders()
      : CustomReminders.fromJson(
          json['customReminders'] as Map<String, dynamic>,
        ),
  addedToCalendar: json['addedToCalendar'] as bool? ?? false,
  calendarEventId: json['calendarEventId'] as String?,
  createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
  updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$UserMyEventToJson(
  UserMyEvent instance,
) => <String, dynamic>{
  'eventId': instance.eventId,
  'userId': instance.userId,
  'eventTitle': instance.eventTitle,
  'eventStartDate': ?const RequiredTimestampConverter().toJson(
    instance.eventStartDate,
  ),
  'eventEndDate': ?const RequiredTimestampConverter().toJson(
    instance.eventEndDate,
  ),
  'eventLocation': instance.eventLocation,
  'organizerName': instance.organizerName,
  'joinedAt': ?const RequiredTimestampConverter().toJson(instance.joinedAt),
  'joinMethod': _$JoinMethodEnumMap[instance.joinMethod]!,
  'participationStatus':
      _$ParticipationStatusEnumMap[instance.participationStatus]!,
  'personalNotes': instance.personalNotes,
  'customReminders': instance.customReminders,
  'addedToCalendar': instance.addedToCalendar,
  'calendarEventId': instance.calendarEventId,
  'createdAt': ?const NullableTimestampConverter().toJson(instance.createdAt),
  'updatedAt': ?const NullableTimestampConverter().toJson(instance.updatedAt),
};

const _$JoinMethodEnumMap = {
  JoinMethod.direct: 'direct',
  JoinMethod.invitation: 'invitation',
  JoinMethod.import: 'import',
};

const _$ParticipationStatusEnumMap = {
  ParticipationStatus.confirmed: 'confirmed',
  ParticipationStatus.maybe: 'maybe',
  ParticipationStatus.cancelled: 'cancelled',
};

CustomReminders _$CustomRemindersFromJson(Map<String, dynamic> json) =>
    CustomReminders(
      enabled: json['enabled'] as bool? ?? true,
      beforeMinutes:
          (json['beforeMinutes'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [15, 60],
    );

Map<String, dynamic> _$CustomRemindersToJson(CustomReminders instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'beforeMinutes': instance.beforeMinutes,
    };
