import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'calendar_model.g.dart';

/// Takvim etkinliği modeli / Calendar event model
@JsonSerializable()
class CalendarEventModel {
  @JsonKey(name: 'id')
  final String? id;

  // Event Details / Etkinlik detayları
  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'location')
  final String? location;

  @JsonKey(name: 'locationDetails')
  final LocationDetailsModel? locationDetails;

  // Timing / Zamanlama
  @JsonKey(name: 'startDate')
  @TimestampConverter()
  final DateTime startDate;

  @JsonKey(name: 'endDate')
  @TimestampConverter()
  final DateTime endDate;

  @JsonKey(name: 'isAllDay')
  final bool isAllDay;

  @JsonKey(name: 'timezone')
  final String timezone;

  // Recurrence / Tekrarlama
  @JsonKey(name: 'recurrence')
  final RecurrenceModel? recurrence;

  // Event Type / Etkinlik türü
  @JsonKey(name: 'type')
  final EventType type;

  @JsonKey(name: 'category')
  final EventCategory category;

  // Targeting / Hedefleme
  @JsonKey(name: 'targetAudience')
  final TargetAudienceModel targetAudience;

  // Additional Info / Ek bilgiler
  @JsonKey(name: 'priority')
  final EventPriority priority;

  @JsonKey(name: 'color')
  final String? color;

  @JsonKey(name: 'tags')
  final List<String>? tags;

  // Exam-specific fields / Sınavlara özel alanlar
  @JsonKey(name: 'examDetails')
  final ExamDetailsModel? examDetails;

  // Notification settings / Bildirim ayarları
  @JsonKey(name: 'reminders')
  final List<ReminderModel>? reminders;

  // Status / Durum
  @JsonKey(name: 'status')
  final EventStatus status;

  // Interaction / Etkileşim
  @JsonKey(name: 'attendeeCount')
  final int? attendeeCount;

  @JsonKey(name: 'maxAttendees')
  final int? maxAttendees;

  @JsonKey(name: 'registrationRequired')
  final bool registrationRequired;

  @JsonKey(name: 'registrationDeadline', includeIfNull: false)
  @TimestampConverter()
  final DateTime? registrationDeadline;

  // Creator / Oluşturan
  @JsonKey(name: 'createdBy')
  final String createdBy;

  @JsonKey(name: 'authorName')
  final String authorName;

  @JsonKey(name: 'authorRole')
  final String authorRole;

  // Timestamps / Zaman damgaları
  @JsonKey(name: 'createdAt')
  @TimestampConverter()
  final DateTime createdAt;

  @JsonKey(name: 'updatedAt')
  @TimestampConverter()
  final DateTime updatedAt;

  const CalendarEventModel({
    this.id,
    required this.title,
    this.description,
    this.location,
    this.locationDetails,
    required this.startDate,
    required this.endDate,
    this.isAllDay = false,
    this.timezone = 'Europe/Istanbul',
    this.recurrence,
    required this.type,
    required this.category,
    required this.targetAudience,
    this.priority = EventPriority.medium,
    this.color,
    this.tags,
    this.examDetails,
    this.reminders,
    this.status = EventStatus.scheduled,
    this.attendeeCount,
    this.maxAttendees,
    this.registrationRequired = false,
    this.registrationDeadline,
    required this.createdBy,
    required this.authorName,
    required this.authorRole,
    required this.createdAt,
    required this.updatedAt,
  });

  /// JSON'dan CalendarEventModel oluştur / Create CalendarEventModel from JSON
  factory CalendarEventModel.fromJson(Map<String, dynamic> json) =>
      _$CalendarEventModelFromJson(json);

  /// CalendarEventModel'i JSON'a çevir / Convert CalendarEventModel to JSON
  Map<String, dynamic> toJson() => _$CalendarEventModelToJson(this);

  /// Firestore verilerinden CalendarEventModel oluştur / Create CalendarEventModel from Firestore data
  factory CalendarEventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return CalendarEventModel.fromJson(data);
  }

  /// Firebase'e uygun veri formatına çevir / Convert to Firebase-compatible format
  Map<String, dynamic> toFirestore() {
    final data = toJson();
    data.remove('id');
    return data;
  }

  /// Etkinliğin aktif olup olmadığını kontrol et / Check if event is active
  bool get isActive {
    final now = DateTime.now();

    // Status kontrolü / Status check
    if (status == EventStatus.cancelled) return false;

    // Tarih kontrolü / Date check
    return endDate.isAfter(now);
  }

  /// Etkinliğin devam edip etmediğini kontrol et / Check if event is ongoing
  bool get isOngoing {
    final now = DateTime.now();
    return startDate.isBefore(now) &&
        endDate.isAfter(now) &&
        status == EventStatus.ongoing;
  }

  /// Etkinliğin tamamlanıp tamamlanmadığını kontrol et / Check if event is completed
  bool get isCompleted {
    return status == EventStatus.completed ||
        (endDate.isBefore(DateTime.now()) && status != EventStatus.cancelled);
  }

  /// Etkinliğe kaç gün kaldığını hesapla / Calculate days until event
  int get daysUntilEvent {
    final now = DateTime.now();
    if (startDate.isBefore(now)) return 0;
    return startDate.difference(now).inDays;
  }

  /// Etkinlik süresini hesapla / Calculate event duration
  Duration get duration => endDate.difference(startDate);

  /// Etkinlik süresini saat cinsinden getir / Get event duration in hours
  double get durationInHours => duration.inMinutes / 60;

  /// Etkinlik süresini formatlanmış şekilde getir / Get formatted duration
  String get formattedDuration {
    if (isAllDay) return 'Tüm gün';

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}s ${minutes}dk';
    } else if (hours > 0) {
      return '${hours}s';
    } else {
      return '${minutes}dk';
    }
  }

  /// Etkinlik tarihi formatlanmış / Formatted event date
  String get formattedDate {
    if (isAllDay) {
      return '${startDate.day}/${startDate.month}/${startDate.year}';
    }

    if (startDate.day == endDate.day &&
        startDate.month == endDate.month &&
        startDate.year == endDate.year) {
      return '${startDate.day}/${startDate.month}/${startDate.year} ${startDate.hour.toString().padLeft(2, '0')}:${startDate.minute.toString().padLeft(2, '0')} - ${endDate.hour.toString().padLeft(2, '0')}:${endDate.minute.toString().padLeft(2, '0')}';
    }

    return '${startDate.day}/${startDate.month}/${startDate.year} - ${endDate.day}/${endDate.month}/${endDate.year}';
  }

  /// Etkinlik rengi / Event color
  String get eventColor {
    if (color != null) return color!;

    // Varsayılan renkler kategoriye göre / Default colors by category
    switch (category) {
      case EventCategory.exam:
        return '#FF5722'; // Deep Orange
      case EventCategory.academic:
        return '#2196F3'; // Blue
      case EventCategory.administrative:
        return '#FF9800'; // Orange
      case EventCategory.social:
        return '#4CAF50'; // Green
      case EventCategory.deadline:
        return '#F44336'; // Red
    }
  }

  /// Etkinlik simgesi / Event icon
  String get eventIcon {
    switch (type) {
      case EventType.exam:
        return '📝';
      case EventType.lecture:
        return '📚';
      case EventType.seminar:
        return '🎓';
      case EventType.meeting:
        return '🤝';
      case EventType.holiday:
        return '🏖️';
      case EventType.deadline:
        return '⏰';
      case EventType.social:
        return '🎉';
      case EventType.academic:
        return '🎯';
    }
  }

  /// Kayıt için uygun mu kontrol et / Check if eligible for registration
  bool get canRegister {
    if (!registrationRequired) return false;
    if (attendeeCount != null &&
        maxAttendees != null &&
        attendeeCount! >= maxAttendees!)
      return false;
    if (registrationDeadline != null &&
        registrationDeadline!.isBefore(DateTime.now()))
      return false;
    return status == EventStatus.scheduled;
  }

  /// Etkinlik kopyala / Copy event with new values
  CalendarEventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    LocationDetailsModel? locationDetails,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAllDay,
    String? timezone,
    RecurrenceModel? recurrence,
    EventType? type,
    EventCategory? category,
    TargetAudienceModel? targetAudience,
    EventPriority? priority,
    String? color,
    List<String>? tags,
    ExamDetailsModel? examDetails,
    List<ReminderModel>? reminders,
    EventStatus? status,
    int? attendeeCount,
    int? maxAttendees,
    bool? registrationRequired,
    DateTime? registrationDeadline,
    String? createdBy,
    String? authorName,
    String? authorRole,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      locationDetails: locationDetails ?? this.locationDetails,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isAllDay: isAllDay ?? this.isAllDay,
      timezone: timezone ?? this.timezone,
      recurrence: recurrence ?? this.recurrence,
      type: type ?? this.type,
      category: category ?? this.category,
      targetAudience: targetAudience ?? this.targetAudience,
      priority: priority ?? this.priority,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      examDetails: examDetails ?? this.examDetails,
      reminders: reminders ?? this.reminders,
      status: status ?? this.status,
      attendeeCount: attendeeCount ?? this.attendeeCount,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      registrationRequired: registrationRequired ?? this.registrationRequired,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      createdBy: createdBy ?? this.createdBy,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CalendarEventModel{id: $id, title: $title, type: $type, status: $status}';
  }
}

/// Konum detayları modeli / Location details model
@JsonSerializable()
class LocationDetailsModel {
  @JsonKey(name: 'building')
  final String? building;

  @JsonKey(name: 'room')
  final String? room;

  @JsonKey(name: 'campus')
  final String? campus;

  @JsonKey(name: 'coordinates')
  final CoordinatesModel? coordinates;

  const LocationDetailsModel({
    this.building,
    this.room,
    this.campus,
    this.coordinates,
  });

  factory LocationDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$LocationDetailsModelFromJson(json);
  Map<String, dynamic> toJson() => _$LocationDetailsModelToJson(this);

  /// Tam konum adresi / Full location address
  String get fullAddress {
    final parts = <String>[];
    if (campus != null) parts.add(campus!);
    if (building != null) parts.add(building!);
    if (room != null) parts.add(room!);
    return parts.join(', ');
  }
}

/// Koordinat modeli / Coordinates model
@JsonSerializable()
class CoordinatesModel {
  @JsonKey(name: 'latitude')
  final double latitude;

  @JsonKey(name: 'longitude')
  final double longitude;

  const CoordinatesModel({required this.latitude, required this.longitude});

  factory CoordinatesModel.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesModelFromJson(json);
  Map<String, dynamic> toJson() => _$CoordinatesModelToJson(this);
}

/// Tekrarlama modeli / Recurrence model
@JsonSerializable()
class RecurrenceModel {
  @JsonKey(name: 'type')
  final RecurrenceType type;

  @JsonKey(name: 'interval')
  final int interval;

  @JsonKey(name: 'endDate', includeIfNull: false)
  @TimestampConverter()
  final DateTime? endDate;

  @JsonKey(name: 'daysOfWeek')
  final List<int>? daysOfWeek;

  @JsonKey(name: 'exceptions')
  @TimestampListConverter()
  final List<DateTime>? exceptions;

  const RecurrenceModel({
    required this.type,
    this.interval = 1,
    this.endDate,
    this.daysOfWeek,
    this.exceptions,
  });

  factory RecurrenceModel.fromJson(Map<String, dynamic> json) =>
      _$RecurrenceModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecurrenceModelToJson(this);

  /// Haftalık tekrarlama / Weekly recurrence
  factory RecurrenceModel.weekly({
    int interval = 1,
    List<int>? daysOfWeek,
    DateTime? endDate,
  }) {
    return RecurrenceModel(
      type: RecurrenceType.weekly,
      interval: interval,
      daysOfWeek: daysOfWeek,
      endDate: endDate,
    );
  }

  /// Günlük tekrarlama / Daily recurrence
  factory RecurrenceModel.daily({int interval = 1, DateTime? endDate}) {
    return RecurrenceModel(
      type: RecurrenceType.daily,
      interval: interval,
      endDate: endDate,
    );
  }
}

/// Sınav detayları modeli / Exam details model
@JsonSerializable()
class ExamDetailsModel {
  @JsonKey(name: 'courseCode')
  final String courseCode;

  @JsonKey(name: 'courseName')
  final String courseName;

  @JsonKey(name: 'examType')
  final ExamType examType;

  @JsonKey(name: 'duration')
  final int duration; // Minutes

  @JsonKey(name: 'instructions')
  final String? instructions;

  @JsonKey(name: 'materials')
  final List<String>? materials;

  const ExamDetailsModel({
    required this.courseCode,
    required this.courseName,
    required this.examType,
    required this.duration,
    this.instructions,
    this.materials,
  });

  factory ExamDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$ExamDetailsModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExamDetailsModelToJson(this);

  /// Sınav süresini formatlanmış şekilde getir / Get formatted exam duration
  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}s ${minutes}dk';
    } else if (hours > 0) {
      return '${hours}s';
    } else {
      return '${minutes}dk';
    }
  }

  /// Sınav türü metni / Exam type text
  String get examTypeText {
    switch (examType) {
      case ExamType.midterm:
        return 'Vize';
      case ExamType.finalExam:
        return 'Final';
      case ExamType.quiz:
        return 'Quiz';
      case ExamType.makeup:
        return 'Bütünleme';
    }
  }
}

/// Hatırlatıcı modeli / Reminder model
@JsonSerializable()
class ReminderModel {
  @JsonKey(name: 'time')
  final int time; // Minutes before event

  @JsonKey(name: 'method')
  final ReminderMethod method;

  const ReminderModel({required this.time, required this.method});

  factory ReminderModel.fromJson(Map<String, dynamic> json) =>
      _$ReminderModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReminderModelToJson(this);

  /// Hatırlatıcı zamanını formatlanmış şekilde getir / Get formatted reminder time
  String get formattedTime {
    if (time < 60) {
      return '$time dakika önce';
    } else if (time < 1440) {
      return '${time ~/ 60} saat önce';
    } else {
      return '${time ~/ 1440} gün önce';
    }
  }
}

/// Hedef kitle modeli (announcement_model.dart'tan alıntı) / Target audience model (imported from announcement_model.dart)
@JsonSerializable()
class TargetAudienceModel {
  @JsonKey(name: 'roles')
  final List<String> roles;

  @JsonKey(name: 'departments')
  final List<String>? departments;

  @JsonKey(name: 'faculties')
  final List<String>? faculties;

  @JsonKey(name: 'years')
  final List<int>? years;

  @JsonKey(name: 'courseIds')
  final List<String>? courseIds;

  @JsonKey(name: 'userIds')
  final List<String>? userIds;

  const TargetAudienceModel({
    required this.roles,
    this.departments,
    this.faculties,
    this.years,
    this.courseIds,
    this.userIds,
  });

  factory TargetAudienceModel.fromJson(Map<String, dynamic> json) =>
      _$TargetAudienceModelFromJson(json);
  Map<String, dynamic> toJson() => _$TargetAudienceModelToJson(this);
}

// Enums / Enum'lar

/// Etkinlik türleri / Event types
enum EventType {
  @JsonValue('exam')
  exam,
  @JsonValue('lecture')
  lecture,
  @JsonValue('seminar')
  seminar,
  @JsonValue('meeting')
  meeting,
  @JsonValue('holiday')
  holiday,
  @JsonValue('deadline')
  deadline,
  @JsonValue('social')
  social,
  @JsonValue('academic')
  academic,
}

/// Etkinlik kategorileri / Event categories
enum EventCategory {
  @JsonValue('academic')
  academic,
  @JsonValue('administrative')
  administrative,
  @JsonValue('social')
  social,
  @JsonValue('deadline')
  deadline,
  @JsonValue('exam')
  exam,
}

/// Etkinlik öncelikleri / Event priorities
enum EventPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
}

/// Etkinlik durumları / Event statuses
enum EventStatus {
  @JsonValue('scheduled')
  scheduled,
  @JsonValue('ongoing')
  ongoing,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('postponed')
  postponed,
}

/// Tekrarlama türleri / Recurrence types
enum RecurrenceType {
  @JsonValue('daily')
  daily,
  @JsonValue('weekly')
  weekly,
  @JsonValue('monthly')
  monthly,
  @JsonValue('yearly')
  yearly,
}

/// Sınav türleri / Exam types
enum ExamType {
  @JsonValue('midterm')
  midterm,
  @JsonValue('final')
  finalExam,
  @JsonValue('quiz')
  quiz,
  @JsonValue('makeup')
  makeup,
}

/// Hatırlatıcı yöntemleri / Reminder methods
enum ReminderMethod {
  @JsonValue('push')
  push,
  @JsonValue('email')
  email,
  @JsonValue('both')
  both,
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
    return Timestamp.fromDate(dateTime);
  }
}

/// Timestamp listesi converter / Timestamp list converter
class TimestampListConverter
    implements JsonConverter<List<DateTime>?, List<Object?>?> {
  const TimestampListConverter();

  @override
  List<DateTime>? fromJson(List<Object?>? json) {
    if (json == null) return null;
    return json.map((item) {
      if (item is Timestamp) return item.toDate();
      if (item is String) return DateTime.parse(item);
      if (item is int) return DateTime.fromMillisecondsSinceEpoch(item);
      throw ArgumentError('Invalid timestamp format');
    }).toList();
  }

  @override
  List<Object?>? toJson(List<DateTime>? dateTimeList) {
    if (dateTimeList == null) return null;
    return dateTimeList
        .map((dateTime) => Timestamp.fromDate(dateTime))
        .toList();
  }
}
