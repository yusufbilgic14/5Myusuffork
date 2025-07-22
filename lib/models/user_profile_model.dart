import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_profile_model.g.dart';

/// Firestore Timestamp converter for JSON serialization
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
    return dateTime.toIso8601String();
  }
}

/// Kullanıcı profil istatistikleri modeli / User profile statistics model
@JsonSerializable(fieldRename: FieldRename.snake)
class UserProfileStats {
  final int eventsCount;
  final double gpa;
  final int complaintsCount;
  final int assignmentsCount;

  const UserProfileStats({
    this.eventsCount = 0,
    this.gpa = 0.0,
    this.complaintsCount = 0,
    this.assignmentsCount = 0,
  });

  factory UserProfileStats.fromJson(Map<String, dynamic> json) =>
      _$UserProfileStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileStatsToJson(this);

  /// Firestore verilerinden oluştur / Create from Firestore data
  factory UserProfileStats.fromFirestoreData(Map<String, dynamic> data) {
    return UserProfileStats.fromJson(data);
  }

  /// Firestore'a uygun format / Firestore-compatible format
  Map<String, dynamic> toFirestoreData() => toJson();

  UserProfileStats copyWith({
    int? eventsCount,
    double? gpa,
    int? complaintsCount,
    int? assignmentsCount,
  }) {
    return UserProfileStats(
      eventsCount: eventsCount ?? this.eventsCount,
      gpa: gpa ?? this.gpa,
      complaintsCount: complaintsCount ?? this.complaintsCount,
      assignmentsCount: assignmentsCount ?? this.assignmentsCount,
    );
  }
}

/// Kullanıcı akademik bilgileri modeli / User academic information model
@JsonSerializable(fieldRename: FieldRename.snake)
class UserAcademicInfo {
  final String? studentId;
  final String? department;
  final String? faculty;
  final String? academicYear;
  final String? grade;
  final double? gpa;
  final int? totalCredits;
  final int? completedCredits;

  @JsonKey(name: 'enrollment_date')
  @TimestampConverter()
  final DateTime? enrollmentDate;

  @JsonKey(name: 'expected_graduation_date')
  @TimestampConverter()
  final DateTime? expectedGraduationDate;

  const UserAcademicInfo({
    this.studentId,
    this.department,
    this.faculty,
    this.academicYear,
    this.grade,
    this.gpa,
    this.totalCredits,
    this.completedCredits,
    this.enrollmentDate,
    this.expectedGraduationDate,
  });

  factory UserAcademicInfo.fromJson(Map<String, dynamic> json) =>
      _$UserAcademicInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UserAcademicInfoToJson(this);

  /// Firestore verilerinden oluştur / Create from Firestore data
  factory UserAcademicInfo.fromFirestoreData(Map<String, dynamic> data) {
    final jsonData = Map<String, dynamic>.from(data);
    
    // Convert Timestamps to DateTime strings for JSON parsing
    if (data['enrollment_date'] is Timestamp) {
      jsonData['enrollment_date'] = (data['enrollment_date'] as Timestamp)
          .toDate()
          .toIso8601String();
    }
    if (data['expected_graduation_date'] is Timestamp) {
      jsonData['expected_graduation_date'] = (data['expected_graduation_date'] as Timestamp)
          .toDate()
          .toIso8601String();
    }

    return UserAcademicInfo.fromJson(jsonData);
  }

  /// Firestore'a uygun format / Firestore-compatible format
  Map<String, dynamic> toFirestoreData() {
    final data = toJson();

    // Convert DateTime strings back to Timestamps for Firestore
    if (enrollmentDate != null) {
      data['enrollment_date'] = Timestamp.fromDate(enrollmentDate!);
    }
    if (expectedGraduationDate != null) {
      data['expected_graduation_date'] = Timestamp.fromDate(expectedGraduationDate!);
    }

    return data;
  }

  UserAcademicInfo copyWith({
    String? studentId,
    String? department,
    String? faculty,
    String? academicYear,
    String? grade,
    double? gpa,
    int? totalCredits,
    int? completedCredits,
    DateTime? enrollmentDate,
    DateTime? expectedGraduationDate,
  }) {
    return UserAcademicInfo(
      studentId: studentId ?? this.studentId,
      department: department ?? this.department,
      faculty: faculty ?? this.faculty,
      academicYear: academicYear ?? this.academicYear,
      grade: grade ?? this.grade,
      gpa: gpa ?? this.gpa,
      totalCredits: totalCredits ?? this.totalCredits,
      completedCredits: completedCredits ?? this.completedCredits,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      expectedGraduationDate: expectedGraduationDate ?? this.expectedGraduationDate,
    );
  }
}

/// Ana kullanıcı profil modeli / Main user profile model
@JsonSerializable(fieldRename: FieldRename.snake)
class UserProfile {
  final String userId;
  
  // Temel bilgiler / Basic information
  final String? profilePhotoUrl;
  final String? bio;
  final String? phoneNumber;
  final String? address;
  
  // Akademik bilgiler / Academic information
  @JsonKey(name: 'academic_info')
  final UserAcademicInfo? academicInfo;
  
  // İstatistikler / Statistics
  @JsonKey(name: 'stats')
  final UserProfileStats? stats;
  
  // Tercihler / Preferences
  final Map<String, dynamic>? preferences;
  final List<String>? interests;
  
  // Sistem alanları / System fields
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  final DateTime? createdAt;
  
  @JsonKey(name: 'updated_at')
  @TimestampConverter()
  final DateTime? updatedAt;
  
  @JsonKey(name: 'is_profile_complete')
  final bool? isProfileComplete;
  
  @JsonKey(name: 'visibility_settings')
  final Map<String, bool>? visibilitySettings;

  const UserProfile({
    required this.userId,
    this.profilePhotoUrl,
    this.bio,
    this.phoneNumber,
    this.address,
    this.academicInfo,
    this.stats,
    this.preferences,
    this.interests,
    this.createdAt,
    this.updatedAt,
    this.isProfileComplete,
    this.visibilitySettings,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  /// Firestore verilerinden oluştur / Create from Firestore data
  factory UserProfile.fromFirestoreData(Map<String, dynamic> data, String documentId) {
    final jsonData = Map<String, dynamic>.from(data);
    jsonData['user_id'] = documentId;
    
    // Convert Timestamps to DateTime strings for JSON parsing
    if (data['created_at'] is Timestamp) {
      jsonData['created_at'] = (data['created_at'] as Timestamp)
          .toDate()
          .toIso8601String();
    }
    if (data['updated_at'] is Timestamp) {
      jsonData['updated_at'] = (data['updated_at'] as Timestamp)
          .toDate()
          .toIso8601String();
    }

    return UserProfile.fromJson(jsonData);
  }

  /// Firestore'a uygun format / Firestore-compatible format
  Map<String, dynamic> toFirestoreData() {
    final data = toJson();
    data.remove('user_id'); // Remove userId from Firestore data

    // Explicitly serialize nested objects
    if (academicInfo != null) {
      data['academic_info'] = academicInfo!.toFirestoreData();
    }
    if (stats != null) {
      data['stats'] = stats!.toFirestoreData();
    }

    // Convert DateTime strings back to Timestamps for Firestore
    if (createdAt != null) {
      data['created_at'] = Timestamp.fromDate(createdAt!);
    }
    if (updatedAt != null) {
      data['updated_at'] = Timestamp.fromDate(updatedAt!);
    }

    return data;
  }

  /// Boş profil oluştur / Create empty profile
  factory UserProfile.empty(String userId) {
    return UserProfile(
      userId: userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isProfileComplete: false,
      stats: const UserProfileStats(),
      visibilitySettings: const {
        'email': true,
        'phone': false,
        'address': false,
        'academic_info': true,
      },
    );
  }

  /// Profilin tamamlanmış olup olmadığını kontrol et / Check if profile is complete
  bool get isComplete {
    if (isProfileComplete != null) return isProfileComplete!;
    
    // Basic completion check
    return academicInfo?.studentId != null &&
           academicInfo?.department != null &&
           academicInfo?.grade != null;
  }

  /// Eksik alanları getir / Get missing fields
  List<String> get missingFields {
    List<String> missing = [];
    
    if (academicInfo?.studentId == null || academicInfo!.studentId!.isEmpty) {
      missing.add('student_id');
    }
    if (academicInfo?.department == null || academicInfo!.department!.isEmpty) {
      missing.add('department');
    }
    if (academicInfo?.grade == null || academicInfo!.grade!.isEmpty) {
      missing.add('grade');
    }
    if (academicInfo?.faculty == null || academicInfo!.faculty!.isEmpty) {
      missing.add('faculty');
    }

    return missing;
  }

  UserProfile copyWith({
    String? userId,
    String? profilePhotoUrl,
    String? bio,
    String? phoneNumber,
    String? address,
    UserAcademicInfo? academicInfo,
    UserProfileStats? stats,
    Map<String, dynamic>? preferences,
    List<String>? interests,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isProfileComplete,
    Map<String, bool>? visibilitySettings,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      academicInfo: academicInfo ?? this.academicInfo,
      stats: stats ?? this.stats,
      preferences: preferences ?? this.preferences,
      interests: interests ?? this.interests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      visibilitySettings: visibilitySettings ?? this.visibilitySettings,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'UserProfile{userId: $userId, isComplete: $isComplete}';
  }
}