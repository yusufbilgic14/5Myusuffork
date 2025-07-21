// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserCourse _$UserCourseFromJson(Map<String, dynamic> json) => UserCourse(
  courseId: json['courseId'] as String,
  courseCode: json['courseCode'] as String,
  courseName: json['courseName'] as String,
  courseNameEn: json['courseNameEn'] as String?,
  courseNameTr: json['courseNameTr'] as String?,
  instructor: CourseInstructor.fromJson(
    json['instructor'] as Map<String, dynamic>,
  ),
  schedule: (json['schedule'] as List<dynamic>)
      .map((e) => CourseSchedule.fromJson(e as Map<String, dynamic>))
      .toList(),
  credits: (json['credits'] as num).toInt(),
  semester: json['semester'] as String,
  year: (json['year'] as num).toInt(),
  semesterNumber: (json['semesterNumber'] as num).toInt(),
  department: json['department'] as String,
  faculty: json['faculty'] as String,
  level: json['level'] as String,
  prerequisite: (json['prerequisite'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  color: json['color'] as String,
  alias: json['alias'] as String?,
  notes: json['notes'] as String?,
  priority: json['priority'] as String? ?? 'medium',
  favorited: json['favorited'] as bool? ?? false,
  isActive: json['isActive'] as bool? ?? true,
  isCompleted: json['isCompleted'] as bool? ?? false,
  grade: json['grade'] as String?,
  attendance: json['attendance'] == null
      ? null
      : CourseAttendance.fromJson(json['attendance'] as Map<String, dynamic>),
  notifications: CourseNotifications.fromJson(
    json['notifications'] as Map<String, dynamic>,
  ),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  enrolledAt: const TimestampConverter().fromJson(json['enrolledAt']),
);

Map<String, dynamic> _$UserCourseToJson(UserCourse instance) =>
    <String, dynamic>{
      'courseId': instance.courseId,
      'courseCode': instance.courseCode,
      'courseName': instance.courseName,
      'courseNameEn': instance.courseNameEn,
      'courseNameTr': instance.courseNameTr,
      'instructor': instance.instructor,
      'schedule': instance.schedule,
      'credits': instance.credits,
      'semester': instance.semester,
      'year': instance.year,
      'semesterNumber': instance.semesterNumber,
      'department': instance.department,
      'faculty': instance.faculty,
      'level': instance.level,
      'prerequisite': instance.prerequisite,
      'color': instance.color,
      'alias': instance.alias,
      'notes': instance.notes,
      'priority': instance.priority,
      'favorited': instance.favorited,
      'isActive': instance.isActive,
      'isCompleted': instance.isCompleted,
      'grade': instance.grade,
      'attendance': instance.attendance,
      'notifications': instance.notifications,
      'createdAt': ?const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': ?const TimestampConverter().toJson(instance.updatedAt),
      'enrolledAt': ?const TimestampConverter().toJson(instance.enrolledAt),
    };

CourseInstructor _$CourseInstructorFromJson(Map<String, dynamic> json) =>
    CourseInstructor(
      name: json['name'] as String,
      email: json['email'] as String?,
      office: json['office'] as String?,
      officeHours: json['officeHours'] as String?,
    );

Map<String, dynamic> _$CourseInstructorToJson(CourseInstructor instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'office': instance.office,
      'officeHours': instance.officeHours,
    };

CourseSchedule _$CourseScheduleFromJson(Map<String, dynamic> json) =>
    CourseSchedule(
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      startHour: (json['startHour'] as num).toInt(),
      duration: (json['duration'] as num).toDouble(),
      room: json['room'] as String,
      building: json['building'] as String?,
      floor: (json['floor'] as num?)?.toInt(),
      classType: json['classType'] as String? ?? 'lecture',
    );

Map<String, dynamic> _$CourseScheduleToJson(CourseSchedule instance) =>
    <String, dynamic>{
      'dayOfWeek': instance.dayOfWeek,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'startHour': instance.startHour,
      'duration': instance.duration,
      'room': instance.room,
      'building': instance.building,
      'floor': instance.floor,
      'classType': instance.classType,
    };

CourseAttendance _$CourseAttendanceFromJson(Map<String, dynamic> json) =>
    CourseAttendance(
      attended: (json['attended'] as num).toInt(),
      total: (json['total'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$CourseAttendanceToJson(CourseAttendance instance) =>
    <String, dynamic>{
      'attended': instance.attended,
      'total': instance.total,
      'percentage': instance.percentage,
    };

CourseNotifications _$CourseNotificationsFromJson(Map<String, dynamic> json) =>
    CourseNotifications(
      beforeClass: (json['beforeClass'] as num?)?.toInt() ?? 15,
      classReminder: json['classReminder'] as bool? ?? true,
      examReminder: json['examReminder'] as bool? ?? true,
      assignmentReminder: json['assignmentReminder'] as bool? ?? true,
    );

Map<String, dynamic> _$CourseNotificationsToJson(
  CourseNotifications instance,
) => <String, dynamic>{
  'beforeClass': instance.beforeClass,
  'classReminder': instance.classReminder,
  'examReminder': instance.examReminder,
  'assignmentReminder': instance.assignmentReminder,
};
