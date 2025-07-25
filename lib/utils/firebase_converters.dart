import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore Timestamp converter for JSON serialization
/// Firebase Timestamp'larını JSON serileştirme için dönüştürücü
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

/// Firestore non-nullable Timestamp converter (for required DateTime fields)
/// Firebase zorunlu Timestamp dönüştürücü (zorunlu DateTime alanları için)
class RequiredTimestampConverter implements JsonConverter<DateTime, Object?> {
  const RequiredTimestampConverter();

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

/// Nullable Firestore Timestamp converter (alternative name for compatibility)
/// Nullable Firestore Timestamp dönüştürücü (uyumluluk için alternatif isim)
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

/// List of strings converter for Firestore
/// Firestore için string listesi dönüştürücü
class StringListConverter implements JsonConverter<List<String>, Object?> {
  const StringListConverter();

  @override
  List<String> fromJson(Object? json) {
    if (json == null) return [];
    if (json is List) return json.cast<String>();
    return [];
  }

  @override
  Object toJson(List<String> list) {
    return list;
  }
}