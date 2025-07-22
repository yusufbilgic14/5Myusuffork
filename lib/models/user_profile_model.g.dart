// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileStats _$UserProfileStatsFromJson(Map<String, dynamic> json) =>
    UserProfileStats(
      eventsCount: (json['events_count'] as num?)?.toInt() ?? 0,
      gpa: (json['gpa'] as num?)?.toDouble() ?? 0.0,
      complaintsCount: (json['complaints_count'] as num?)?.toInt() ?? 0,
      assignmentsCount: (json['assignments_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$UserProfileStatsToJson(UserProfileStats instance) =>
    <String, dynamic>{
      'events_count': instance.eventsCount,
      'gpa': instance.gpa,
      'complaints_count': instance.complaintsCount,
      'assignments_count': instance.assignmentsCount,
    };

UserAcademicInfo _$UserAcademicInfoFromJson(Map<String, dynamic> json) =>
    UserAcademicInfo(
      studentId: json['student_id'] as String?,
      department: json['department'] as String?,
      faculty: json['faculty'] as String?,
      academicYear: json['academic_year'] as String?,
      grade: json['grade'] as String?,
      gpa: (json['gpa'] as num?)?.toDouble(),
      totalCredits: (json['total_credits'] as num?)?.toInt(),
      completedCredits: (json['completed_credits'] as num?)?.toInt(),
      enrollmentDate: const TimestampConverter().fromJson(
        json['enrollment_date'],
      ),
      expectedGraduationDate: const TimestampConverter().fromJson(
        json['expected_graduation_date'],
      ),
    );

Map<String, dynamic> _$UserAcademicInfoToJson(
  UserAcademicInfo instance,
) => <String, dynamic>{
  'student_id': instance.studentId,
  'department': instance.department,
  'faculty': instance.faculty,
  'academic_year': instance.academicYear,
  'grade': instance.grade,
  'gpa': instance.gpa,
  'total_credits': instance.totalCredits,
  'completed_credits': instance.completedCredits,
  'enrollment_date': const TimestampConverter().toJson(instance.enrollmentDate),
  'expected_graduation_date': const TimestampConverter().toJson(
    instance.expectedGraduationDate,
  ),
};

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  userId: json['user_id'] as String,
  profilePhotoUrl: json['profile_photo_url'] as String?,
  bio: json['bio'] as String?,
  phoneNumber: json['phone_number'] as String?,
  address: json['address'] as String?,
  academicInfo: json['academic_info'] == null
      ? null
      : UserAcademicInfo.fromJson(
          json['academic_info'] as Map<String, dynamic>,
        ),
  stats: json['stats'] == null
      ? null
      : UserProfileStats.fromJson(json['stats'] as Map<String, dynamic>),
  preferences: json['preferences'] as Map<String, dynamic>?,
  interests: (json['interests'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  createdAt: const TimestampConverter().fromJson(json['created_at']),
  updatedAt: const TimestampConverter().fromJson(json['updated_at']),
  isProfileComplete: json['is_profile_complete'] as bool?,
  visibilitySettings: (json['visibility_settings'] as Map<String, dynamic>?)
      ?.map((k, e) => MapEntry(k, e as bool)),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'profile_photo_url': instance.profilePhotoUrl,
      'bio': instance.bio,
      'phone_number': instance.phoneNumber,
      'address': instance.address,
      'academic_info': instance.academicInfo,
      'stats': instance.stats,
      'preferences': instance.preferences,
      'interests': instance.interests,
      'created_at': const TimestampConverter().toJson(instance.createdAt),
      'updated_at': const TimestampConverter().toJson(instance.updatedAt),
      'is_profile_complete': instance.isProfileComplete,
      'visibility_settings': instance.visibilitySettings,
    };
