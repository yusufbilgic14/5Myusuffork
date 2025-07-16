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
};
