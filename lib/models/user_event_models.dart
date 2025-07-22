import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_event_models.g.dart';

/// Event model for representing university events
/// Üniversite etkinliklerini temsil eden model
@JsonSerializable()
class Event {
  @JsonKey(name: 'eventId')
  final String eventId;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'imageUrl')
  final String? imageUrl;

  @JsonKey(name: 'eventType')
  final String eventType; // 'conference', 'workshop', 'social', 'sports', 'cultural', 'academic', 'career'

  @JsonKey(name: 'category')
  final String category;

  @JsonKey(name: 'location')
  final String location;

  @JsonKey(name: 'building')
  final String? building;

  @JsonKey(name: 'room')
  final String? room;

  // Date & Time
  @JsonKey(name: 'startDateTime', includeIfNull: false)
  @TimestampConverter()
  final DateTime startDateTime;

  @JsonKey(name: 'endDateTime', includeIfNull: false)
  @TimestampConverter()
  final DateTime endDateTime;

  @JsonKey(name: 'timezone')
  final String timezone;

  // Capacity & Registration
  @JsonKey(name: 'maxCapacity')
  final int? maxCapacity;

  @JsonKey(name: 'requiresRegistration')
  final bool requiresRegistration;

  @JsonKey(name: 'registrationDeadline', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? registrationDeadline;

  // Organizer Information
  @JsonKey(name: 'organizerId')
  final String organizerId;

  @JsonKey(name: 'organizerName')
  final String organizerName;

  @JsonKey(name: 'organizerType')
  final String organizerType; // 'university', 'club', 'department', 'student_organization'

  @JsonKey(name: 'clubId')
  final String? clubId;

  // Status & Visibility
  @JsonKey(name: 'status')
  final String status; // 'draft', 'published', 'cancelled', 'completed'

  @JsonKey(name: 'isVisible')
  final bool isVisible;

  @JsonKey(name: 'isFeatured')
  final bool isFeatured;

  // Engagement Counters
  @JsonKey(name: 'likeCount')
  final int likeCount;

  @JsonKey(name: 'commentCount')
  final int commentCount;

  @JsonKey(name: 'joinCount')
  final int joinCount;

  @JsonKey(name: 'shareCount')
  final int shareCount;

  // Metadata
  @JsonKey(name: 'createdAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? updatedAt;

  @JsonKey(name: 'createdBy')
  final String createdBy;

  @JsonKey(name: 'updatedBy')
  final String? updatedBy;

  // Tags & Search
  @JsonKey(name: 'tags')
  final List<String> tags;

  @JsonKey(name: 'keywords')
  final List<String> keywords;

  const Event({
    required this.eventId,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.eventType,
    required this.category,
    required this.location,
    this.building,
    this.room,
    required this.startDateTime,
    required this.endDateTime,
    this.timezone = 'Europe/Istanbul',
    this.maxCapacity,
    this.requiresRegistration = false,
    this.registrationDeadline,
    required this.organizerId,
    required this.organizerName,
    required this.organizerType,
    this.clubId,
    this.status = 'published',
    this.isVisible = true,
    this.isFeatured = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.joinCount = 0,
    this.shareCount = 0,
    this.createdAt,
    this.updatedAt,
    required this.createdBy,
    this.updatedBy,
    this.tags = const [],
    this.keywords = const [],
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);

  /// Create Event from Firestore data
  factory Event.fromFirestoreData(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final jsonData = Map<String, dynamic>.from(data);

    // Set event ID if not present
    if (!jsonData.containsKey('eventId')) {
      jsonData['eventId'] = documentId;
    }

    // Convert Timestamps to DateTime strings for JSON parsing
    _convertTimestampFields(jsonData, [
      'startDateTime',
      'endDateTime',
      'registrationDeadline',
      'createdAt',
      'updatedAt',
    ]);

    return Event.fromJson(jsonData);
  }

  /// Create Firestore-compatible data
  Map<String, dynamic> toFirestoreData() {
    final data = toJson();

    // Convert DateTime fields to Timestamps
    if (data['startDateTime'] != null) {
      data['startDateTime'] = Timestamp.fromDate(startDateTime);
    }
    if (data['endDateTime'] != null) {
      data['endDateTime'] = Timestamp.fromDate(endDateTime);
    }
    if (registrationDeadline != null) {
      data['registrationDeadline'] = Timestamp.fromDate(registrationDeadline!);
    }
    if (createdAt != null) {
      data['createdAt'] = Timestamp.fromDate(createdAt!);
    }
    if (updatedAt != null) {
      data['updatedAt'] = Timestamp.fromDate(updatedAt!);
    }

    return data;
  }

  /// Check if event is upcoming
  bool get isUpcoming => startDateTime.isAfter(DateTime.now());

  /// Check if event is ongoing
  bool get isOngoing {
    final now = DateTime.now();
    return startDateTime.isBefore(now) && endDateTime.isAfter(now);
  }

  /// Check if event is past
  bool get isPast => endDateTime.isBefore(DateTime.now());

  /// Get event duration in hours
  double get durationInHours {
    return endDateTime.difference(startDateTime).inMinutes / 60.0;
  }

  /// Copy with new values
  Event copyWith({
    String? eventId,
    String? title,
    String? description,
    String? imageUrl,
    String? eventType,
    String? category,
    String? location,
    String? building,
    String? room,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? timezone,
    int? maxCapacity,
    bool? requiresRegistration,
    DateTime? registrationDeadline,
    String? organizerId,
    String? organizerName,
    String? organizerType,
    String? clubId,
    String? status,
    bool? isVisible,
    bool? isFeatured,
    int? likeCount,
    int? commentCount,
    int? joinCount,
    int? shareCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    List<String>? tags,
    List<String>? keywords,
  }) {
    return Event(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      eventType: eventType ?? this.eventType,
      category: category ?? this.category,
      location: location ?? this.location,
      building: building ?? this.building,
      room: room ?? this.room,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      timezone: timezone ?? this.timezone,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      requiresRegistration: requiresRegistration ?? this.requiresRegistration,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      organizerType: organizerType ?? this.organizerType,
      clubId: clubId ?? this.clubId,
      status: status ?? this.status,
      isVisible: isVisible ?? this.isVisible,
      isFeatured: isFeatured ?? this.isFeatured,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      joinCount: joinCount ?? this.joinCount,
      shareCount: shareCount ?? this.shareCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      tags: tags ?? this.tags,
      keywords: keywords ?? this.keywords,
    );
  }

  /// Get formatted date string
  /// Formatlanmış tarih string'i getir
  String getFormattedDate() {
    final eventDate = startDateTime;
    final now = DateTime.now();
    final difference = eventDate.difference(now);

    if (difference.inDays == 0) {
      return 'Today, ${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow, ${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0 && difference.inDays < 7) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[eventDate.weekday - 1]}, ${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}';
    } else {
      return '${eventDate.day}/${eventDate.month}/${eventDate.year} ${eventDate.hour.toString().padLeft(2, '0')}:${eventDate.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  String toString() => 'Event{eventId: $eventId, title: $title}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId;

  @override
  int get hashCode => eventId.hashCode;
}

/// User's interaction with an event
/// Kullanıcının etkinlik ile etkileşimi
@JsonSerializable()
class UserEventInteraction {
  @JsonKey(name: 'eventId')
  final String eventId;

  @JsonKey(name: 'userId')
  final String userId;

  // Interaction Types
  @JsonKey(name: 'hasLiked')
  final bool hasLiked;

  @JsonKey(name: 'hasJoined')
  final bool hasJoined;

  @JsonKey(name: 'hasShared')
  final bool hasShared;

  @JsonKey(name: 'isFavorited')
  final bool isFavorited;

  // Participation Details
  @JsonKey(name: 'joinedAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? joinedAt;

  @JsonKey(name: 'leftAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? leftAt;

  @JsonKey(name: 'joinStatus')
  final JoinStatus joinStatus;

  // Notification Preferences
  @JsonKey(name: 'notifyBeforeEvent')
  final bool notifyBeforeEvent;

  @JsonKey(name: 'notifyDayBefore')
  final bool notifyDayBefore;

  @JsonKey(name: 'notifyHourBefore')
  final bool notifyHourBefore;

  // Interaction History
  @JsonKey(name: 'likedAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? likedAt;

  @JsonKey(name: 'unlikedAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? unlikedAt;

  // Metadata
  @JsonKey(name: 'createdAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? updatedAt;

  const UserEventInteraction({
    required this.eventId,
    required this.userId,
    this.hasLiked = false,
    this.hasJoined = false,
    this.hasShared = false,
    this.isFavorited = false,
    this.joinedAt,
    this.leftAt,
    this.joinStatus = JoinStatus.notJoined,
    this.notifyBeforeEvent = true,
    this.notifyDayBefore = true,
    this.notifyHourBefore = true,
    this.likedAt,
    this.unlikedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory UserEventInteraction.fromJson(Map<String, dynamic> json) =>
      _$UserEventInteractionFromJson(json);
  Map<String, dynamic> toJson() => _$UserEventInteractionToJson(this);

  /// Create from Firestore data
  factory UserEventInteraction.fromFirestoreData(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final jsonData = Map<String, dynamic>.from(data);

    // Set event ID if not present
    if (!jsonData.containsKey('eventId')) {
      jsonData['eventId'] = documentId;
    }

    // Convert Timestamps to DateTime strings
    _convertTimestampFields(jsonData, [
      'joinedAt',
      'leftAt',
      'likedAt',
      'unlikedAt',
      'createdAt',
      'updatedAt',
    ]);

    return UserEventInteraction.fromJson(jsonData);
  }

  /// Create Firestore-compatible data
  Map<String, dynamic> toFirestoreData() {
    final data = toJson();

    // Convert DateTime fields to Timestamps
    _convertDateTimeToTimestamp(data, 'joinedAt', joinedAt);
    _convertDateTimeToTimestamp(data, 'leftAt', leftAt);
    _convertDateTimeToTimestamp(data, 'likedAt', likedAt);
    _convertDateTimeToTimestamp(data, 'unlikedAt', unlikedAt);
    _convertDateTimeToTimestamp(data, 'createdAt', createdAt);
    _convertDateTimeToTimestamp(data, 'updatedAt', updatedAt);

    return data;
  }

  UserEventInteraction copyWith({
    String? eventId,
    String? userId,
    bool? hasLiked,
    bool? hasJoined,
    bool? hasShared,
    bool? isFavorited,
    DateTime? joinedAt,
    DateTime? leftAt,
    JoinStatus? joinStatus,
    bool? notifyBeforeEvent,
    bool? notifyDayBefore,
    bool? notifyHourBefore,
    DateTime? likedAt,
    DateTime? unlikedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserEventInteraction(
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      hasLiked: hasLiked ?? this.hasLiked,
      hasJoined: hasJoined ?? this.hasJoined,
      hasShared: hasShared ?? this.hasShared,
      isFavorited: isFavorited ?? this.isFavorited,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
      joinStatus: joinStatus ?? this.joinStatus,
      notifyBeforeEvent: notifyBeforeEvent ?? this.notifyBeforeEvent,
      notifyDayBefore: notifyDayBefore ?? this.notifyDayBefore,
      notifyHourBefore: notifyHourBefore ?? this.notifyHourBefore,
      likedAt: likedAt ?? this.likedAt,
      unlikedAt: unlikedAt ?? this.unlikedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'UserEventInteraction{eventId: $eventId, userId: $userId}';
}

/// User's personal event calendar entry
/// Kullanıcının kişisel etkinlik takvimi girişi
@JsonSerializable()
class UserMyEvent {
  @JsonKey(name: 'eventId')
  final String eventId;

  @JsonKey(name: 'userId')
  final String userId;

  // Event Reference Data (denormalized)
  @JsonKey(name: 'eventTitle')
  final String eventTitle;

  @JsonKey(name: 'eventStartDate', includeIfNull: false)
  @TimestampConverter()
  final DateTime eventStartDate;

  @JsonKey(name: 'eventEndDate', includeIfNull: false)
  @TimestampConverter()
  final DateTime eventEndDate;

  @JsonKey(name: 'eventLocation')
  final String eventLocation;

  @JsonKey(name: 'organizerName')
  final String organizerName;

  // User Participation
  @JsonKey(name: 'joinedAt', includeIfNull: false)
  @TimestampConverter()
  final DateTime joinedAt;

  @JsonKey(name: 'joinMethod')
  final JoinMethod joinMethod;

  @JsonKey(name: 'participationStatus')
  final ParticipationStatus participationStatus;

  // Personal Notes & Reminders
  @JsonKey(name: 'personalNotes')
  final String? personalNotes;

  @JsonKey(name: 'customReminders')
  final CustomReminders customReminders;

  // Calendar Integration
  @JsonKey(name: 'addedToCalendar')
  final bool addedToCalendar;

  @JsonKey(name: 'calendarEventId')
  final String? calendarEventId;

  // Metadata
  @JsonKey(name: 'createdAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt', includeIfNull: false)
  @NullableTimestampConverter()
  final DateTime? updatedAt;

  const UserMyEvent({
    required this.eventId,
    required this.userId,
    required this.eventTitle,
    required this.eventStartDate,
    required this.eventEndDate,
    required this.eventLocation,
    required this.organizerName,
    required this.joinedAt,
    this.joinMethod = JoinMethod.direct,
    this.participationStatus = ParticipationStatus.confirmed,
    this.personalNotes,
    this.customReminders = const CustomReminders(),
    this.addedToCalendar = false,
    this.calendarEventId,
    this.createdAt,
    this.updatedAt,
  });

  factory UserMyEvent.fromJson(Map<String, dynamic> json) =>
      _$UserMyEventFromJson(json);
  Map<String, dynamic> toJson() => _$UserMyEventToJson(this);

  /// Create from Firestore data
  factory UserMyEvent.fromFirestoreData(
    Map<String, dynamic> data,
    String documentId,
  ) {
    final jsonData = Map<String, dynamic>.from(data);

    if (!jsonData.containsKey('eventId')) {
      jsonData['eventId'] = documentId;
    }

    _convertTimestampFields(jsonData, [
      'eventStartDate',
      'eventEndDate',
      'joinedAt',
      'createdAt',
      'updatedAt',
    ]);

    return UserMyEvent.fromJson(jsonData);
  }

  /// Create Firestore-compatible data
  Map<String, dynamic> toFirestoreData() {
    final data = toJson();

    data['eventStartDate'] = Timestamp.fromDate(eventStartDate);
    data['eventEndDate'] = Timestamp.fromDate(eventEndDate);
    data['joinedAt'] = Timestamp.fromDate(joinedAt);
    _convertDateTimeToTimestamp(data, 'createdAt', createdAt);
    _convertDateTimeToTimestamp(data, 'updatedAt', updatedAt);

    return data;
  }

  @override
  String toString() =>
      'UserMyEvent{eventId: $eventId, eventTitle: $eventTitle}';
}

/// Custom reminder settings
/// Özel hatırlatma ayarları
@JsonSerializable()
class CustomReminders {
  @JsonKey(name: 'enabled')
  final bool enabled;

  @JsonKey(name: 'beforeMinutes')
  final List<int> beforeMinutes;

  const CustomReminders({
    this.enabled = true,
    this.beforeMinutes = const [15, 60], // 15 minutes and 1 hour before
  });

  factory CustomReminders.fromJson(Map<String, dynamic> json) =>
      _$CustomRemindersFromJson(json);
  Map<String, dynamic> toJson() => _$CustomRemindersToJson(this);
}

/// Join status enum
/// Katılım durumu enum'u
enum JoinStatus {
  @JsonValue('not_joined')
  notJoined,
  @JsonValue('joined')
  joined,
  @JsonValue('waitlisted')
  waitlisted,
  @JsonValue('cancelled')
  cancelled,
}

/// Join method enum
/// Katılım yöntemi enum'u
enum JoinMethod {
  @JsonValue('direct')
  direct,
  @JsonValue('invitation')
  invitation,
  @JsonValue('import')
  import,
}

/// Participation status enum
/// Katılım durumu enum'u
enum ParticipationStatus {
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('maybe')
  maybe,
  @JsonValue('cancelled')
  cancelled,
}

/// Firestore Timestamp converter
/// Firestore Timestamp dönüştürücüsü
class TimestampConverter implements JsonConverter<DateTime, Object?> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json == null) throw ArgumentError('DateTime cannot be null');
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    throw ArgumentError('Cannot convert $json to DateTime');
  }

  @override
  Object toJson(DateTime dateTime) {
    return dateTime.toIso8601String();
  }
}

/// Nullable Firestore Timestamp converter
/// Nullable Firestore Timestamp dönüştürücüsü
class NullableTimestampConverter implements JsonConverter<DateTime?, Object?> {
  const NullableTimestampConverter();

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

/// Helper function to convert timestamp fields
/// Timestamp alanlarını dönüştürme yardımcı fonksiyonu
void _convertTimestampFields(Map<String, dynamic> data, List<String> fields) {
  for (final field in fields) {
    if (data[field] is Timestamp) {
      data[field] = (data[field] as Timestamp).toDate().toIso8601String();
    }
  }
}

/// Helper function to convert DateTime to Timestamp
/// DateTime'ı Timestamp'a dönüştürme yardımcı fonksiyonu
void _convertDateTimeToTimestamp(
  Map<String, dynamic> data,
  String field,
  DateTime? dateTime,
) {
  if (dateTime != null) {
    data[field] = Timestamp.fromDate(dateTime);
  }
}

/// Event counters model for real-time updates
/// Gerçek zamanlı güncellemeler için etkinlik sayaçları modeli
class EventCounters {
  final int likeCount;
  final int commentCount;
  final int joinCount;
  final int shareCount;

  const EventCounters({
    required this.likeCount,
    required this.commentCount,
    required this.joinCount,
    required this.shareCount,
  });

  @override
  String toString() =>
      'EventCounters{likeCount: $likeCount, commentCount: $commentCount, joinCount: $joinCount, shareCount: $shareCount}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventCounters &&
          runtimeType == other.runtimeType &&
          likeCount == other.likeCount &&
          commentCount == other.commentCount &&
          joinCount == other.joinCount &&
          shareCount == other.shareCount;

  @override
  int get hashCode =>
      Object.hash(likeCount, commentCount, joinCount, shareCount);
}
