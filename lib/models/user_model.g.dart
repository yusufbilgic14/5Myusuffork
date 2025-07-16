// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUser _$AppUserFromJson(Map<String, dynamic> json) => AppUser(
  id: json['id'] as String,
  displayName: json['displayName'] as String,
  userPrincipalName: json['userPrincipalName'] as String,
  email: json['mail'] as String?,
  firstName: json['givenName'] as String?,
  lastName: json['surname'] as String?,
  jobTitle: json['jobTitle'] as String?,
  department: json['department'] as String?,
  businessPhones: (json['businessPhones'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  mobilePhone: json['mobilePhone'] as String?,
  officeLocation: json['officeLocation'] as String?,
  preferredLanguage: json['preferredLanguage'] as String?,
  firebaseUid: json['firebaseUid'] as String?,
  firestoreDocId: json['firestoreDocId'] as String?,
  userRole: $enumDecodeNullable(_$UserRoleEnumMap, json['role']),
  permissions: (json['permissions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isActive: json['isActive'] as bool?,
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  lastLoginAt: const TimestampConverter().fromJson(json['lastLoginAt']),
);

Map<String, dynamic> _$AppUserToJson(AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'displayName': instance.displayName,
  'mail': instance.email,
  'userPrincipalName': instance.userPrincipalName,
  'givenName': instance.firstName,
  'surname': instance.lastName,
  'jobTitle': instance.jobTitle,
  'department': instance.department,
  'businessPhones': instance.businessPhones,
  'mobilePhone': instance.mobilePhone,
  'officeLocation': instance.officeLocation,
  'preferredLanguage': instance.preferredLanguage,
  'firebaseUid': instance.firebaseUid,
  'firestoreDocId': instance.firestoreDocId,
  if (_$UserRoleEnumMap[instance.userRole] case final value?) 'role': value,
  'permissions': instance.permissions,
  if (instance.isActive case final value?) 'isActive': value,
  if (const TimestampConverter().toJson(instance.createdAt) case final value?)
    'createdAt': value,
  if (const TimestampConverter().toJson(instance.updatedAt) case final value?)
    'updatedAt': value,
  if (const TimestampConverter().toJson(instance.lastLoginAt) case final value?)
    'lastLoginAt': value,
};

const _$UserRoleEnumMap = {
  UserRole.student: 'student',
  UserRole.staff: 'staff',
  UserRole.admin: 'admin',
  UserRole.guest: 'guest',
};
