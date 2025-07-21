// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarEventModel _$CalendarEventModelFromJson(
  Map<String, dynamic> json,
) => CalendarEventModel(
  id: json['id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String?,
  location: json['location'] as String?,
  locationDetails: json['locationDetails'] == null
      ? null
      : LocationDetailsModel.fromJson(
          json['locationDetails'] as Map<String, dynamic>,
        ),
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  isAllDay: json['isAllDay'] as bool? ?? false,
  timezone: json['timezone'] as String? ?? 'Europe/Istanbul',
  recurrence: json['recurrence'] == null
      ? null
      : RecurrenceModel.fromJson(json['recurrence'] as Map<String, dynamic>),
  type: $enumDecode(_$EventTypeEnumMap, json['type']),
  category: $enumDecode(_$EventCategoryEnumMap, json['category']),
  targetAudience: TargetAudienceModel.fromJson(
    json['targetAudience'] as Map<String, dynamic>,
  ),
  priority:
      $enumDecodeNullable(_$EventPriorityEnumMap, json['priority']) ??
      EventPriority.medium,
  color: json['color'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  examDetails: json['examDetails'] == null
      ? null
      : ExamDetailsModel.fromJson(json['examDetails'] as Map<String, dynamic>),
  reminders: (json['reminders'] as List<dynamic>?)
      ?.map((e) => ReminderModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  status:
      $enumDecodeNullable(_$EventStatusEnumMap, json['status']) ??
      EventStatus.scheduled,
  attendeeCount: (json['attendeeCount'] as num?)?.toInt(),
  maxAttendees: (json['maxAttendees'] as num?)?.toInt(),
  registrationRequired: json['registrationRequired'] as bool? ?? false,
  registrationDeadline: const TimestampConverter().fromJson(
    json['registrationDeadline'],
  ),
  createdBy: json['createdBy'] as String,
  authorName: json['authorName'] as String,
  authorRole: json['authorRole'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CalendarEventModelToJson(CalendarEventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'location': instance.location,
      'locationDetails': instance.locationDetails,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'isAllDay': instance.isAllDay,
      'timezone': instance.timezone,
      'recurrence': instance.recurrence,
      'type': _$EventTypeEnumMap[instance.type]!,
      'category': _$EventCategoryEnumMap[instance.category]!,
      'targetAudience': instance.targetAudience,
      'priority': _$EventPriorityEnumMap[instance.priority]!,
      'color': instance.color,
      'tags': instance.tags,
      'examDetails': instance.examDetails,
      'reminders': instance.reminders,
      'status': _$EventStatusEnumMap[instance.status]!,
      'attendeeCount': instance.attendeeCount,
      'maxAttendees': instance.maxAttendees,
      'registrationRequired': instance.registrationRequired,
      'registrationDeadline': ?const TimestampConverter().toJson(
        instance.registrationDeadline,
      ),
      'createdBy': instance.createdBy,
      'authorName': instance.authorName,
      'authorRole': instance.authorRole,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$EventTypeEnumMap = {
  EventType.exam: 'exam',
  EventType.lecture: 'lecture',
  EventType.seminar: 'seminar',
  EventType.meeting: 'meeting',
  EventType.holiday: 'holiday',
  EventType.deadline: 'deadline',
  EventType.social: 'social',
  EventType.academic: 'academic',
};

const _$EventCategoryEnumMap = {
  EventCategory.academic: 'academic',
  EventCategory.administrative: 'administrative',
  EventCategory.social: 'social',
  EventCategory.deadline: 'deadline',
  EventCategory.exam: 'exam',
};

const _$EventPriorityEnumMap = {
  EventPriority.low: 'low',
  EventPriority.medium: 'medium',
  EventPriority.high: 'high',
};

const _$EventStatusEnumMap = {
  EventStatus.scheduled: 'scheduled',
  EventStatus.ongoing: 'ongoing',
  EventStatus.completed: 'completed',
  EventStatus.cancelled: 'cancelled',
  EventStatus.postponed: 'postponed',
};

LocationDetailsModel _$LocationDetailsModelFromJson(
  Map<String, dynamic> json,
) => LocationDetailsModel(
  building: json['building'] as String?,
  room: json['room'] as String?,
  campus: json['campus'] as String?,
  coordinates: json['coordinates'] == null
      ? null
      : CoordinatesModel.fromJson(json['coordinates'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LocationDetailsModelToJson(
  LocationDetailsModel instance,
) => <String, dynamic>{
  'building': instance.building,
  'room': instance.room,
  'campus': instance.campus,
  'coordinates': instance.coordinates,
};

CoordinatesModel _$CoordinatesModelFromJson(Map<String, dynamic> json) =>
    CoordinatesModel(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$CoordinatesModelToJson(CoordinatesModel instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

RecurrenceModel _$RecurrenceModelFromJson(Map<String, dynamic> json) =>
    RecurrenceModel(
      type: $enumDecode(_$RecurrenceTypeEnumMap, json['type']),
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      endDate: const TimestampConverter().fromJson(json['endDate']),
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      exceptions: const TimestampListConverter().fromJson(
        json['exceptions'] as List?,
      ),
    );

Map<String, dynamic> _$RecurrenceModelToJson(RecurrenceModel instance) =>
    <String, dynamic>{
      'type': _$RecurrenceTypeEnumMap[instance.type]!,
      'interval': instance.interval,
      'endDate': ?const TimestampConverter().toJson(instance.endDate),
      'daysOfWeek': instance.daysOfWeek,
      'exceptions': const TimestampListConverter().toJson(instance.exceptions),
    };

const _$RecurrenceTypeEnumMap = {
  RecurrenceType.daily: 'daily',
  RecurrenceType.weekly: 'weekly',
  RecurrenceType.monthly: 'monthly',
  RecurrenceType.yearly: 'yearly',
};

ExamDetailsModel _$ExamDetailsModelFromJson(Map<String, dynamic> json) =>
    ExamDetailsModel(
      courseCode: json['courseCode'] as String,
      courseName: json['courseName'] as String,
      examType: $enumDecode(_$ExamTypeEnumMap, json['examType']),
      duration: (json['duration'] as num).toInt(),
      instructions: json['instructions'] as String?,
      materials: (json['materials'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ExamDetailsModelToJson(ExamDetailsModel instance) =>
    <String, dynamic>{
      'courseCode': instance.courseCode,
      'courseName': instance.courseName,
      'examType': _$ExamTypeEnumMap[instance.examType]!,
      'duration': instance.duration,
      'instructions': instance.instructions,
      'materials': instance.materials,
    };

const _$ExamTypeEnumMap = {
  ExamType.midterm: 'midterm',
  ExamType.finalExam: 'final',
  ExamType.quiz: 'quiz',
  ExamType.makeup: 'makeup',
};

ReminderModel _$ReminderModelFromJson(Map<String, dynamic> json) =>
    ReminderModel(
      time: (json['time'] as num).toInt(),
      method: $enumDecode(_$ReminderMethodEnumMap, json['method']),
    );

Map<String, dynamic> _$ReminderModelToJson(ReminderModel instance) =>
    <String, dynamic>{
      'time': instance.time,
      'method': _$ReminderMethodEnumMap[instance.method]!,
    };

const _$ReminderMethodEnumMap = {
  ReminderMethod.push: 'push',
  ReminderMethod.email: 'email',
  ReminderMethod.both: 'both',
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
      courseIds: (json['courseIds'] as List<dynamic>?)
          ?.map((e) => e as String)
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
  'courseIds': instance.courseIds,
  'userIds': instance.userIds,
};
