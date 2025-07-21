import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

part 'user_course_model.g.dart';

/// Kullanıcının ders programındaki bir dersi temsil eden model
/// Model representing a course in the user's schedule
@JsonSerializable()
class UserCourse {
  @JsonKey(name: 'courseId')
  final String courseId;
  
  @JsonKey(name: 'courseCode')
  final String courseCode;
  
  @JsonKey(name: 'courseName')
  final String courseName;
  
  @JsonKey(name: 'courseNameEn')
  final String? courseNameEn;
  
  @JsonKey(name: 'courseNameTr')
  final String? courseNameTr;
  
  @JsonKey(name: 'instructor')
  final CourseInstructor instructor;
  
  @JsonKey(name: 'schedule')
  final List<CourseSchedule> schedule;
  
  @JsonKey(name: 'credits')
  final int credits;
  
  @JsonKey(name: 'semester')
  final String semester;
  
  @JsonKey(name: 'year')
  final int year;
  
  @JsonKey(name: 'semesterNumber')
  final int semesterNumber; // 1=Fall, 2=Spring, 3=Summer
  
  @JsonKey(name: 'department')
  final String department;
  
  @JsonKey(name: 'faculty')
  final String faculty;
  
  @JsonKey(name: 'level')
  final String level; // 'undergraduate', 'graduate', 'phd'
  
  @JsonKey(name: 'prerequisite')
  final List<String>? prerequisite;
  
  // User Customization
  @JsonKey(name: 'color')
  final String color; // Hex color
  
  @JsonKey(name: 'alias')
  final String? alias;
  
  @JsonKey(name: 'notes')
  final String? notes;
  
  @JsonKey(name: 'priority')
  final String priority; // 'high', 'medium', 'low'
  
  @JsonKey(name: 'favorited')
  final bool favorited;
  
  // Status & Settings
  @JsonKey(name: 'isActive')
  final bool isActive;
  
  @JsonKey(name: 'isCompleted')
  final bool isCompleted;
  
  @JsonKey(name: 'grade')
  final String? grade;
  
  @JsonKey(name: 'attendance')
  final CourseAttendance? attendance;
  
  @JsonKey(name: 'notifications')
  final CourseNotifications notifications;
  
  // Timestamps
  @JsonKey(name: 'createdAt', includeIfNull: false)
  @TimestampConverter()
  final DateTime? createdAt;
  
  @JsonKey(name: 'updatedAt', includeIfNull: false)
  @TimestampConverter()
  final DateTime? updatedAt;
  
  @JsonKey(name: 'enrolledAt', includeIfNull: false)
  @TimestampConverter()
  final DateTime? enrolledAt;

  const UserCourse({
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    this.courseNameEn,
    this.courseNameTr,
    required this.instructor,
    required this.schedule,
    required this.credits,
    required this.semester,
    required this.year,
    required this.semesterNumber,
    required this.department,
    required this.faculty,
    required this.level,
    this.prerequisite,
    required this.color,
    this.alias,
    this.notes,
    this.priority = 'medium',
    this.favorited = false,
    this.isActive = true,
    this.isCompleted = false,
    this.grade,
    this.attendance,
    required this.notifications,
    this.createdAt,
    this.updatedAt,
    this.enrolledAt,
  });

  /// JSON'dan UserCourse oluştur / Create UserCourse from JSON
  factory UserCourse.fromJson(Map<String, dynamic> json) => _$UserCourseFromJson(json);

  /// UserCourse'u JSON'a çevir / Convert UserCourse to JSON
  Map<String, dynamic> toJson() => _$UserCourseToJson(this);

  /// Firebase'e uygun veri oluştur / Create Firebase-compatible data
  Map<String, dynamic> toFirestoreData() {
    final data = toJson();
    
    // Manually handle complex objects to ensure proper serialization
    data['instructor'] = instructor.toJson();
    data['schedule'] = schedule.map((s) => s.toJson()).toList();
    data['notifications'] = notifications.toJson();
    if (attendance != null) {
      data['attendance'] = attendance!.toJson();
    }
    
    // Ensure timestamps are properly converted
    if (createdAt != null) {
      data['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    if (updatedAt != null) {
      data['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }
    if (enrolledAt != null) {
      data['enrolledAt'] = Timestamp.fromDate(enrolledAt!);
    }
    
    return data;
  }

  /// Firebase verilerinden UserCourse oluştur / Create UserCourse from Firebase data
  factory UserCourse.fromFirestoreData(Map<String, dynamic> data, String documentId) {
    final jsonData = Map<String, dynamic>.from(data);
    
    // Set course ID if not present
    if (!jsonData.containsKey('courseId')) {
      jsonData['courseId'] = documentId;
    }
    
    // Convert Timestamps to DateTime strings for JSON parsing
    if (data['createdAt'] is Timestamp) {
      jsonData['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['updatedAt'] is Timestamp) {
      jsonData['updatedAt'] = (data['updatedAt'] as Timestamp).toDate().toIso8601String();
    }
    if (data['enrolledAt'] is Timestamp) {
      jsonData['enrolledAt'] = (data['enrolledAt'] as Timestamp).toDate().toIso8601String();
    }
    
    return UserCourse.fromJson(jsonData);
  }

  /// Dersin görünen adını getir / Get display name for the course
  String get displayName {
    if (alias != null && alias!.isNotEmpty) {
      return alias!;
    }
    return courseName;
  }

  /// Kurs rengini Color nesnesine çevir / Convert course color to Color object
  Color get colorAsColor {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF1E3A8A); // Default blue
    }
  }

  /// Bugün bu ders var mı? / Does this course have classes today?
  bool hasClassToday() {
    final today = DateTime.now().weekday;
    return schedule.any((s) => s.dayOfWeek == today);
  }

  /// Belirli bir günde bu ders var mı? / Does this course have classes on a specific day?
  bool hasClassOnDay(int dayOfWeek) {
    return schedule.any((s) => s.dayOfWeek == dayOfWeek);
  }

  /// Bugünkü ders saatlerini getir / Get today's class schedules
  List<CourseSchedule> getTodaysSchedules() {
    final today = DateTime.now().weekday;
    return schedule.where((s) => s.dayOfWeek == today).toList();
  }

  /// Belirli bir gün için ders saatlerini getir / Get schedules for a specific day
  List<CourseSchedule> getSchedulesForDay(int dayOfWeek) {
    return schedule.where((s) => s.dayOfWeek == dayOfWeek).toList();
  }

  /// Kursu kopyala / Copy course with new values
  UserCourse copyWith({
    String? courseId,
    String? courseCode,
    String? courseName,
    String? courseNameEn,
    String? courseNameTr,
    CourseInstructor? instructor,
    List<CourseSchedule>? schedule,
    int? credits,
    String? semester,
    int? year,
    int? semesterNumber,
    String? department,
    String? faculty,
    String? level,
    List<String>? prerequisite,
    String? color,
    String? alias,
    String? notes,
    String? priority,
    bool? favorited,
    bool? isActive,
    bool? isCompleted,
    String? grade,
    CourseAttendance? attendance,
    CourseNotifications? notifications,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? enrolledAt,
  }) {
    return UserCourse(
      courseId: courseId ?? this.courseId,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      courseNameEn: courseNameEn ?? this.courseNameEn,
      courseNameTr: courseNameTr ?? this.courseNameTr,
      instructor: instructor ?? this.instructor,
      schedule: schedule ?? this.schedule,
      credits: credits ?? this.credits,
      semester: semester ?? this.semester,
      year: year ?? this.year,
      semesterNumber: semesterNumber ?? this.semesterNumber,
      department: department ?? this.department,
      faculty: faculty ?? this.faculty,
      level: level ?? this.level,
      prerequisite: prerequisite ?? this.prerequisite,
      color: color ?? this.color,
      alias: alias ?? this.alias,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      favorited: favorited ?? this.favorited,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      grade: grade ?? this.grade,
      attendance: attendance ?? this.attendance,
      notifications: notifications ?? this.notifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      enrolledAt: enrolledAt ?? this.enrolledAt,
    );
  }

  @override
  String toString() {
    return 'UserCourse{courseId: $courseId, courseCode: $courseCode, courseName: $courseName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCourse &&
          runtimeType == other.runtimeType &&
          courseId == other.courseId;

  @override
  int get hashCode => courseId.hashCode;
}

/// Ders öğretmeni bilgileri / Course instructor information
@JsonSerializable()
class CourseInstructor {
  @JsonKey(name: 'name')
  final String name;
  
  @JsonKey(name: 'email')
  final String? email;
  
  @JsonKey(name: 'office')
  final String? office;
  
  @JsonKey(name: 'officeHours')
  final String? officeHours;

  const CourseInstructor({
    required this.name,
    this.email,
    this.office,
    this.officeHours,
  });

  factory CourseInstructor.fromJson(Map<String, dynamic> json) => _$CourseInstructorFromJson(json);
  Map<String, dynamic> toJson() => _$CourseInstructorToJson(this);
}

/// Ders programı bilgileri / Course schedule information
@JsonSerializable()
class CourseSchedule {
  @JsonKey(name: 'dayOfWeek')
  final int dayOfWeek; // 1=Monday, 2=Tuesday, ..., 7=Sunday
  
  @JsonKey(name: 'startTime')
  final String startTime; // "08:00"
  
  @JsonKey(name: 'endTime')
  final String endTime; // "10:00"
  
  @JsonKey(name: 'startHour')
  final int startHour; // 8
  
  @JsonKey(name: 'duration')
  final double duration; // 2.0
  
  @JsonKey(name: 'room')
  final String room; // "B201"
  
  @JsonKey(name: 'building')
  final String? building; // "Engineering"
  
  @JsonKey(name: 'floor')
  final int? floor; // 2
  
  @JsonKey(name: 'classType')
  final String classType; // 'lecture', 'lab', 'tutorial', 'exam'

  const CourseSchedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.startHour,
    required this.duration,
    required this.room,
    this.building,
    this.floor,
    this.classType = 'lecture',
  });

  factory CourseSchedule.fromJson(Map<String, dynamic> json) => _$CourseScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$CourseScheduleToJson(this);

  /// Bitiş saatini hesapla / Calculate end hour
  int get endHour {
    return startHour + duration.ceil();
  }

  /// Tam ders saati string'i / Full time string
  String get timeString {
    return '$startTime - $endTime';
  }

  /// Gün adını getir / Get day name
  String getDayName() {
    switch (dayOfWeek) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return 'Unknown';
    }
  }

  /// Türkçe gün adını getir / Get Turkish day name
  String getDayNameTr() {
    switch (dayOfWeek) {
      case 1: return 'Pazartesi';
      case 2: return 'Salı';
      case 3: return 'Çarşamba';
      case 4: return 'Perşembe';
      case 5: return 'Cuma';
      case 6: return 'Cumartesi';
      case 7: return 'Pazar';
      default: return 'Bilinmiyor';
    }
  }

  /// Program çakışması kontrol et / Check schedule conflict
  bool conflictsWith(CourseSchedule other) {
    if (dayOfWeek != other.dayOfWeek) return false;
    
    final thisStart = startHour * 60 + int.parse(startTime.split(':')[1]);
    final thisEnd = thisStart + (duration * 60).round();
    final otherStart = other.startHour * 60 + int.parse(other.startTime.split(':')[1]);
    final otherEnd = otherStart + (other.duration * 60).round();
    
    return (thisStart < otherEnd) && (thisEnd > otherStart);
  }
}

/// Devam durumu bilgileri / Attendance information
@JsonSerializable()
class CourseAttendance {
  @JsonKey(name: 'attended')
  final int attended;
  
  @JsonKey(name: 'total')
  final int total;
  
  @JsonKey(name: 'percentage')
  final double percentage;

  const CourseAttendance({
    required this.attended,
    required this.total,
    required this.percentage,
  });

  factory CourseAttendance.fromJson(Map<String, dynamic> json) => _$CourseAttendanceFromJson(json);
  Map<String, dynamic> toJson() => _$CourseAttendanceToJson(this);

  /// Devam durumu iyi mi? / Is attendance good?
  bool get isGood => percentage >= 70.0;
  
  /// Devam durumu kritik mi? / Is attendance critical?
  bool get isCritical => percentage < 50.0;
}

/// Bildirim ayarları / Notification settings
@JsonSerializable()
class CourseNotifications {
  @JsonKey(name: 'beforeClass')
  final int beforeClass; // Minutes before class
  
  @JsonKey(name: 'classReminder')
  final bool classReminder;
  
  @JsonKey(name: 'examReminder')
  final bool examReminder;
  
  @JsonKey(name: 'assignmentReminder')
  final bool assignmentReminder;

  const CourseNotifications({
    this.beforeClass = 15,
    this.classReminder = true,
    this.examReminder = true,
    this.assignmentReminder = true,
  });

  factory CourseNotifications.fromJson(Map<String, dynamic> json) => _$CourseNotificationsFromJson(json);
  Map<String, dynamic> toJson() => _$CourseNotificationsToJson(this);
}

/// Firestore Timestamp converter
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