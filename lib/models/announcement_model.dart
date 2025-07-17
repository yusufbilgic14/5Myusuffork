import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'announcement_model.g.dart';

/// Üniversite duyuruları modeli / University announcements model
@JsonSerializable()
class AnnouncementModel {
  @JsonKey(name: 'id')
  final String? id;

  // Content / İçerik
  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'content')
  final String content;

  @JsonKey(name: 'summary')
  final String? summary;

  // Media / Medya
  @JsonKey(name: 'images')
  final List<String>? images;

  @JsonKey(name: 'attachments')
  final List<AttachmentModel>? attachments;

  // Targeting / Hedefleme
  @JsonKey(name: 'targetAudience')
  final TargetAudienceModel targetAudience;

  // Classification / Sınıflandırma
  @JsonKey(name: 'category')
  final AnnouncementCategory category;

  @JsonKey(name: 'priority')
  final AnnouncementPriority priority;

  @JsonKey(name: 'tags')
  final List<String>? tags;

  // Publishing / Yayınlama
  @JsonKey(name: 'status')
  final AnnouncementStatus status;

  @JsonKey(name: 'publishAt', includeIfNull: false)
  @TimestampConverter()
  final DateTime? publishAt;

  @JsonKey(name: 'expiresAt', includeIfNull: false)
  @TimestampConverter()
  final DateTime? expiresAt;

  // Interaction / Etkileşim
  @JsonKey(name: 'viewCount')
  final int viewCount;

  @JsonKey(name: 'likeCount')
  final int likeCount;

  @JsonKey(name: 'commentCount')
  final int commentCount;

  @JsonKey(name: 'shareCount')
  final int shareCount;

  // Author / Yazar
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

  // SEO & Search / SEO ve arama
  @JsonKey(name: 'searchKeywords')
  final List<String>? searchKeywords;

  @JsonKey(name: 'slug')
  final String? slug;

  const AnnouncementModel({
    this.id,
    required this.title,
    required this.content,
    this.summary,
    this.images,
    this.attachments,
    required this.targetAudience,
    required this.category,
    required this.priority,
    this.tags,
    required this.status,
    this.publishAt,
    this.expiresAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    required this.createdBy,
    required this.authorName,
    required this.authorRole,
    required this.createdAt,
    required this.updatedAt,
    this.searchKeywords,
    this.slug,
  });

  /// JSON'dan AnnouncementModel oluştur / Create AnnouncementModel from JSON
  factory AnnouncementModel.fromJson(Map<String, dynamic> json) => _$AnnouncementModelFromJson(json);

  /// AnnouncementModel'i JSON'a çevir / Convert AnnouncementModel to JSON
  Map<String, dynamic> toJson() => _$AnnouncementModelToJson(this);

  /// Firestore verilerinden AnnouncementModel oluştur / Create AnnouncementModel from Firestore data
  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return AnnouncementModel.fromJson(data);
  }

  /// Firebase'e uygun veri formatına çevir / Convert to Firebase-compatible format
  Map<String, dynamic> toFirestore() {
    final data = toJson();
    data.remove('id'); // Firestore document ID olarak ayarlanacak / Will be set as Firestore document ID
    return data;
  }

  /// Duyurunun aktif olup olmadığını kontrol et / Check if announcement is active
  bool get isActive {
    final now = DateTime.now();
    
    // Status kontrolü / Status check
    if (status != AnnouncementStatus.published) return false;
    
    // Yayınlanma tarihi kontrolü / Publish date check
    if (publishAt != null && publishAt!.isAfter(now)) return false;
    
    // Son kullanma tarihi kontrolü / Expiry date check
    if (expiresAt != null && expiresAt!.isBefore(now)) return false;
    
    return true;
  }

  /// Duyurunun belirli bir kullanıcı için uygun olup olmadığını kontrol et / Check if announcement is suitable for a specific user
  bool isTargetedTo({
    required String userRole,
    String? department,
    String? faculty,
    int? year,
    String? userId,
  }) {
    // Herkese açık duyurular / Public announcements
    if (targetAudience.roles.contains('all')) return true;
    
    // Rol bazlı kontrol / Role-based check
    if (!targetAudience.roles.contains(userRole)) return false;
    
    // Bölüm kontrolü / Department check
    if (targetAudience.departments != null && 
        targetAudience.departments!.isNotEmpty && 
        department != null &&
        !targetAudience.departments!.contains(department)) {
      return false;
    }
    
    // Fakülte kontrolü / Faculty check
    if (targetAudience.faculties != null && 
        targetAudience.faculties!.isNotEmpty && 
        faculty != null &&
        !targetAudience.faculties!.contains(faculty)) {
      return false;
    }
    
    // Sınıf kontrolü (öğrenciler için) / Year check (for students)
    if (targetAudience.years != null && 
        targetAudience.years!.isNotEmpty && 
        year != null &&
        !targetAudience.years!.contains(year)) {
      return false;
    }
    
    // Özel kullanıcı kontrolü / Specific user check
    if (targetAudience.userIds != null && 
        targetAudience.userIds!.isNotEmpty && 
        userId != null &&
        !targetAudience.userIds!.contains(userId)) {
      return false;
    }
    
    return true;
  }

  /// Önizleme metni getir / Get preview text
  String get previewText {
    if (summary != null && summary!.isNotEmpty) {
      return summary!;
    }
    
    // HTML etiketlerini temizle ve ilk 150 karakteri al / Clean HTML tags and take first 150 characters
    final cleanContent = content.replaceAll(RegExp(r'<[^>]*>'), '');
    return cleanContent.length > 150 
        ? '${cleanContent.substring(0, 150)}...'
        : cleanContent;
  }

  /// Kategori renk kodu / Category color code
  String get categoryColor {
    switch (category) {
      case AnnouncementCategory.urgent:
        return '#FF4444';
      case AnnouncementCategory.academic:
        return '#2196F3';
      case AnnouncementCategory.administrative:
        return '#FF9800';
      case AnnouncementCategory.social:
        return '#4CAF50';
      case AnnouncementCategory.event:
        return '#9C27B0';
      case AnnouncementCategory.general:
      default:
        return '#757575';
    }
  }

  /// Öncelik simgesi / Priority icon
  String get priorityIcon {
    switch (priority) {
      case AnnouncementPriority.critical:
        return '🚨';
      case AnnouncementPriority.high:
        return '⚠️';
      case AnnouncementPriority.medium:
        return '📢';
      case AnnouncementPriority.low:
      default:
        return 'ℹ️';
    }
  }

  /// Duyuru kopyala / Copy announcement with new values
  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? content,
    String? summary,
    List<String>? images,
    List<AttachmentModel>? attachments,
    TargetAudienceModel? targetAudience,
    AnnouncementCategory? category,
    AnnouncementPriority? priority,
    List<String>? tags,
    AnnouncementStatus? status,
    DateTime? publishAt,
    DateTime? expiresAt,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    String? createdBy,
    String? authorName,
    String? authorRole,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? searchKeywords,
    String? slug,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      images: images ?? this.images,
      attachments: attachments ?? this.attachments,
      targetAudience: targetAudience ?? this.targetAudience,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      publishAt: publishAt ?? this.publishAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      createdBy: createdBy ?? this.createdBy,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      searchKeywords: searchKeywords ?? this.searchKeywords,
      slug: slug ?? this.slug,
    );
  }

  @override
  String toString() {
    return 'AnnouncementModel{id: $id, title: $title, category: $category, status: $status}';
  }
}

/// Ek dosya modeli / Attachment model
@JsonSerializable()
class AttachmentModel {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'url')
  final String url;

  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'size')
  final int size;

  const AttachmentModel({
    required this.name,
    required this.url,
    required this.type,
    required this.size,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) => _$AttachmentModelFromJson(json);
  Map<String, dynamic> toJson() => _$AttachmentModelToJson(this);

  /// Dosya boyutunu human-readable formatta getir / Get file size in human-readable format
  String get formattedSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Dosya simgesi / File icon
  String get icon {
    switch (type.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'xls':
      case 'xlsx':
        return '📊';
      case 'ppt':
      case 'pptx':
        return '📽️';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return '🖼️';
      case 'mp4':
      case 'avi':
      case 'mov':
        return '🎬';
      case 'mp3':
      case 'wav':
        return '🎵';
      case 'zip':
      case 'rar':
        return '📦';
      default:
        return '📎';
    }
  }
}

/// Hedef kitle modeli / Target audience model
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

  @JsonKey(name: 'userIds')
  final List<String>? userIds;

  const TargetAudienceModel({
    required this.roles,
    this.departments,
    this.faculties,
    this.years,
    this.userIds,
  });

  factory TargetAudienceModel.fromJson(Map<String, dynamic> json) => _$TargetAudienceModelFromJson(json);
  Map<String, dynamic> toJson() => _$TargetAudienceModelToJson(this);

  /// Herkese açık hedef kitle / Public target audience
  factory TargetAudienceModel.public() {
    return const TargetAudienceModel(roles: ['all']);
  }

  /// Öğrencilere özel hedef kitle / Students-only target audience
  factory TargetAudienceModel.studentsOnly({
    List<String>? departments,
    List<String>? faculties,
    List<int>? years,
  }) {
    return TargetAudienceModel(
      roles: ['student'],
      departments: departments,
      faculties: faculties,
      years: years,
    );
  }

  /// Personele özel hedef kitle / Staff-only target audience
  factory TargetAudienceModel.staffOnly({
    List<String>? departments,
    List<String>? faculties,
  }) {
    return TargetAudienceModel(
      roles: ['staff'],
      departments: departments,
      faculties: faculties,
    );
  }
}

/// Duyuru kategorileri / Announcement categories
enum AnnouncementCategory {
  @JsonValue('general')
  general,
  @JsonValue('academic')
  academic,
  @JsonValue('administrative')
  administrative,
  @JsonValue('social')
  social,
  @JsonValue('urgent')
  urgent,
  @JsonValue('event')
  event,
}

/// Duyuru öncelikleri / Announcement priorities
enum AnnouncementPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical,
}

/// Duyuru durumları / Announcement statuses
enum AnnouncementStatus {
  @JsonValue('draft')
  draft,
  @JsonValue('published')
  published,
  @JsonValue('archived')
  archived,
  @JsonValue('scheduled')
  scheduled,
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