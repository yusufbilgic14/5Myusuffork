import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.g.dart';

/// Kullanıcı rolleri enum'u / User roles enum
enum UserRole {
  @JsonValue('student')
  student,
  @JsonValue('staff')
  staff,
  @JsonValue('admin')
  admin,
  @JsonValue('guest')
  guest,
}

/// Firestore Timestamp converter for JSON serialization
/// Firestore Timestamp'i JSON serileştirme için dönüştürücü
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

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
    // For JSON serialization, use ISO string format instead of Timestamp
    return dateTime.toIso8601String();
  }
}

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

  // Firebase-specific fields / Firebase'e özel alanlar
  
  @JsonKey(name: 'firebaseUid')
  final String? firebaseUid;
  
  @JsonKey(name: 'firestoreDocId')
  final String? firestoreDocId;
  
  @JsonKey(name: 'role', includeIfNull: false)
  final UserRole? userRole;
  
  @JsonKey(name: 'permissions')
  final List<String>? permissions;
  
  @JsonKey(name: 'isActive', includeIfNull: false)
  final bool? isActive;
  
  @JsonKey(name: 'createdAt', includeIfNull: false)
  @TimestampConverter()
  final DateTime? createdAt;
  
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  @TimestampConverter()
  final DateTime? updatedAt;
  
  @JsonKey(name: 'lastLoginAt', includeIfNull: false)
  @TimestampConverter()
  final DateTime? lastLoginAt;

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
    // Firebase-specific fields / Firebase'e özel alanlar
    this.firebaseUid,
    this.firestoreDocId,
    this.userRole,
    this.permissions,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
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
    // Önce Firebase userRole'ü kontrol et / First check Firebase userRole
    if (userRole != null) {
      switch (userRole!) {
        case UserRole.student:
          return 'Öğrenci';
        case UserRole.staff:
          return 'Personel';
        case UserRole.admin:
          return 'Yönetici';
        case UserRole.guest:
          return 'Misafir';
      }
    }
    // Fallback to Microsoft OAuth based role detection
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

  // Firebase-specific methods / Firebase'e özel metodlar

  /// Firebase'e bağlı olup olmadığını kontrol et / Check if connected to Firebase
  bool get isConnectedToFirebase => firebaseUid != null && firebaseUid!.isNotEmpty;

  /// Firestore dokümanı mevcut mu kontrol et / Check if Firestore document exists
  bool get hasFirestoreDocument => firestoreDocId != null && firestoreDocId!.isNotEmpty;

  /// Kullanıcının aktif olup olmadığını kontrol et / Check if user is active
  bool get isUserActive => isActive ?? true;

  /// Kullanıcının yönetici olup olmadığını kontrol et / Check if user is admin
  bool get isAdmin => userRole == UserRole.admin;

  /// Kullanıcının belirli bir yetkiye sahip olup olmadığını kontrol et / Check if user has specific permission
  bool hasPermission(String permission) {
    return permissions?.contains(permission) ?? false;
  }

  /// Kullanıcının herhangi bir yetkiye sahip olup olmadığını kontrol et / Check if user has any of the permissions
  bool hasAnyPermission(List<String> permissionList) {
    if (permissions == null || permissions!.isEmpty) return false;
    return permissionList.any((permission) => permissions!.contains(permission));
  }

  /// Kullanıcının tüm yetkilere sahip olup olmadığını kontrol et / Check if user has all permissions
  bool hasAllPermissions(List<String> permissionList) {
    if (permissions == null || permissions!.isEmpty) return false;
    return permissionList.every((permission) => permissions!.contains(permission));
  }

  /// Firebase Firestore doküman referansı getir / Get Firebase Firestore document reference
  DocumentReference? get firestoreReference {
    if (!hasFirestoreDocument) return null;
    return FirebaseFirestore.instance.collection('users').doc(firestoreDocId);
  }

  /// Firebase'e uygun kullanıcı verisi oluştur / Create Firebase-compatible user data
  Map<String, dynamic> toFirestoreData() {
    final data = toJson();
    
    // Remove Microsoft-specific fields that shouldn't be stored in Firebase
    data.remove('businessPhones');
    data.remove('mobilePhone');
    data.remove('officeLocation');
    
    // Ensure timestamps are properly converted
    if (createdAt != null) {
      data['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    if (updatedAt != null) {
      data['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }
    if (lastLoginAt != null) {
      data['lastLoginAt'] = Timestamp.fromDate(lastLoginAt!);
    }
    
    return data;
  }

  /// Firebase verilerinden AppUser oluştur / Create AppUser from Firebase data
  factory AppUser.fromFirestoreData(Map<String, dynamic> data, String documentId) {
    // Convert Firestore data to standard JSON format
    final jsonData = Map<String, dynamic>.from(data);
    
    // Set Firestore document ID
    jsonData['firestoreDocId'] = documentId;
    
    // Convert Timestamps to DateTime strings for JSON parsing
    if (data['createdAt'] is Timestamp) {
      jsonData['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      jsonData['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['lastLoginAt'] is Timestamp) {
      jsonData['lastLoginAt'] = (data['lastLoginAt'] as Timestamp).toDate().toIso8601String();
    }
    
    return AppUser.fromJson(jsonData);
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
    // Firebase-specific fields / Firebase'e özel alanlar
    String? firebaseUid,
    String? firestoreDocId,
    UserRole? userRole,
    List<String>? permissions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
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
      // Firebase-specific fields / Firebase'e özel alanlar
      firebaseUid: firebaseUid ?? this.firebaseUid,
      firestoreDocId: firestoreDocId ?? this.firestoreDocId,
      userRole: userRole ?? this.userRole,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
} 