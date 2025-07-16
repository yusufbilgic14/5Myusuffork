import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// Microsoft kullanıcı bilgileri modeli / Microsoft user information model
@JsonSerializable()
class AppUser {
  @JsonKey(name: 'id')
  final String id;
  
  @JsonKey(name: 'displayName')
  final String displayName;
  
  @JsonKey(name: 'mail')
  final String? email;
  
  @JsonKey(name: 'userPrincipalName')
  final String userPrincipalName;
  
  @JsonKey(name: 'givenName')
  final String? firstName;
  
  @JsonKey(name: 'surname')
  final String? lastName;
  
  @JsonKey(name: 'jobTitle')
  final String? jobTitle;
  
  @JsonKey(name: 'department')
  final String? department;
  
  @JsonKey(name: 'businessPhones')
  final List<String>? businessPhones;
  
  @JsonKey(name: 'mobilePhone')
  final String? mobilePhone;
  
  @JsonKey(name: 'officeLocation')
  final String? officeLocation;
  
  @JsonKey(name: 'preferredLanguage')
  final String? preferredLanguage;

  const AppUser({
    required this.id,
    required this.displayName,
    required this.userPrincipalName,
    this.email,
    this.firstName,
    this.lastName,
    this.jobTitle,
    this.department,
    this.businessPhones,
    this.mobilePhone,
    this.officeLocation,
    this.preferredLanguage,
  });

  /// JSON'dan AppUser oluştur / Create AppUser from JSON
  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  /// AppUser'ı JSON'a çevir / Convert AppUser to JSON
  Map<String, dynamic> toJson() => _$AppUserToJson(this);

  /// Kullanıcının tam adını getir / Get user's full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName;
  }

  /// Kullanıcının birincil email adresini getir / Get user's primary email
  String get primaryEmail {
    return email ?? userPrincipalName;
  }

  /// Kullanıcının öğrenci olup olmadığını kontrol et / Check if user is a student
  bool get isStudent {
    return userPrincipalName.toLowerCase().contains('student') ||
           userPrincipalName.toLowerCase().contains('ogrenci') ||
           (jobTitle?.toLowerCase().contains('student') ?? false) ||
           (department?.toLowerCase().contains('student') ?? false);
  }

  /// Kullanıcının personel olup olmadığını kontrol et / Check if user is staff
  bool get isStaff {
    return !isStudent &&
           (jobTitle != null && jobTitle!.isNotEmpty) ||
           (department != null && department!.isNotEmpty);
  }

  /// Kullanıcının rol bilgisini getir / Get user's role information
  String get role {
    if (isStudent) return 'Öğrenci';
    if (isStaff) return 'Personel';
    return 'Kullanıcı';
  }

  /// Kullanıcının profil fotoğrafı URL'sini getir / Get user's profile photo URL
  String? get profilePhotoUrl {
    // Microsoft Graph API'den profil fotoğrafı URL'si alınabilir
    // Can get profile photo URL from Microsoft Graph API
    return 'https://graph.microsoft.com/v1.0/me/photo/\$value';
  }

  /// Boş kullanıcı nesnesi / Empty user object
  static const AppUser empty = AppUser(
    id: '',
    displayName: '',
    userPrincipalName: '',
  );

  /// Kullanıcının boş olup olmadığını kontrol et / Check if user is empty
  bool get isEmpty => this == empty;

  /// Kullanıcının dolu olup olmadığını kontrol et / Check if user is not empty
  bool get isNotEmpty => this != empty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userPrincipalName == other.userPrincipalName;

  @override
  int get hashCode => id.hashCode ^ userPrincipalName.hashCode;

  @override
  String toString() {
    return 'AppUser{id: $id, displayName: $displayName, email: $email, role: $role}';
  }

  /// Kullanıcı kopyala / Copy user with new values
  AppUser copyWith({
    String? id,
    String? displayName,
    String? email,
    String? userPrincipalName,
    String? firstName,
    String? lastName,
    String? jobTitle,
    String? department,
    List<String>? businessPhones,
    String? mobilePhone,
    String? officeLocation,
    String? preferredLanguage,
  }) {
    return AppUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      userPrincipalName: userPrincipalName ?? this.userPrincipalName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      businessPhones: businessPhones ?? this.businessPhones,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      officeLocation: officeLocation ?? this.officeLocation,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }
} 