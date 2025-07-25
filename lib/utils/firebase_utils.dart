import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Utility class for common Firebase operations
/// Ortak Firebase işlemleri için yardımcı sınıf
class FirebaseUtils {
  
  /// Convert Firestore Timestamp to DateTime safely
  /// Firestore Timestamp'ı güvenli şekilde DateTime'a dönüştür
  static DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.tryParse(timestamp);
    if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
    return null;
  }

  /// Convert DateTime to Firestore Timestamp
  /// DateTime'ı Firestore Timestamp'a dönüştür
  static Timestamp? dateTimeToTimestamp(DateTime? dateTime) {
    if (dateTime == null) return null;
    return Timestamp.fromDate(dateTime);
  }

  /// Safely get string from Firestore document
  /// Firestore dokümanından güvenli şekilde string al
  static String? getString(Map<String, dynamic>? data, String field) {
    return data?[field] as String?;
  }

  /// Safely get int from Firestore document
  /// Firestore dokümanından güvenli şekilde int al
  static int? getInt(Map<String, dynamic>? data, String field) {
    final value = data?[field];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Safely get double from Firestore document
  /// Firestore dokümanından güvenli şekilde double al
  static double? getDouble(Map<String, dynamic>? data, String field) {
    final value = data?[field];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Safely get bool from Firestore document
  /// Firestore dokümanından güvenli şekilde bool al
  static bool? getBool(Map<String, dynamic>? data, String field) {
    final value = data?[field];
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int) return value != 0;
    return null;
  }

  /// Safely get List from Firestore document
  /// Firestore dokümanından güvenli şekilde List al
  static List<T>? getList<T>(Map<String, dynamic>? data, String field) {
    final value = data?[field];
    if (value is List) {
      try {
        return value.cast<T>();
      } catch (e) {
        debugPrint('❌ FirebaseUtils: Failed to cast list to $T: $e');
        return null;
      }
    }
    return null;
  }

  /// Safely get Map from Firestore document
  /// Firestore dokümanından güvenli şekilde Map al
  static Map<String, dynamic>? getMap(Map<String, dynamic>? data, String field) {
    final value = data?[field];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } catch (e) {
        debugPrint('❌ FirebaseUtils: Failed to convert map: $e');
        return null;
      }
    }
    return null;
  }

  /// Create a document with auto-generated metadata
  /// Otomatik oluşturulan metadata ile doküman oluştur
  static Map<String, dynamic> createDocumentWithMetadata(
    Map<String, dynamic> data, {
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return {
      ...data,
      'createdAt': createdAt ?? now,
      'updatedAt': updatedAt ?? now,
      if (userId != null) 'createdBy': userId,
      'isDeleted': false,
    };
  }

  /// Update document with metadata
  /// Dokümanı metadata ile güncelle
  static Map<String, dynamic> updateDocumentWithMetadata(
    Map<String, dynamic> data, {
    String? userId,
    DateTime? updatedAt,
  }) {
    return {
      ...data,
      'updatedAt': updatedAt ?? DateTime.now(),
      if (userId != null) 'updatedBy': userId,
    };
  }

  /// Soft delete document
  /// Dokümanı yumuşak silme
  static Map<String, dynamic> createSoftDeleteData({
    String? userId,
    DateTime? deletedAt,
  }) {
    return {
      'isDeleted': true,
      'deletedAt': deletedAt ?? DateTime.now(),
      if (userId != null) 'deletedBy': userId,
    };
  }

  /// Build query with common filters
  /// Yaygın filtrelerle sorgu oluştur
  static Query buildQuery(
    CollectionReference collection, {
    List<QueryFilter>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
    DocumentSnapshot? startAfter,
    bool excludeDeleted = true,
  }) {
    Query query = collection;

    // Exclude soft deleted documents by default
    if (excludeDeleted) {
      query = query.where('isDeleted', isEqualTo: false);
    }

    // Apply filters
    if (filters != null) {
      for (final filter in filters) {
        query = filter.apply(query);
      }
    }

    // Apply ordering
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    // Apply pagination
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query;
  }

  /// Execute batch write with error handling
  /// Hata yakalama ile batch write yürüt
  static Future<void> executeBatch(
    FirebaseFirestore firestore,
    List<BatchOperation> operations,
  ) async {
    final batch = firestore.batch();

    for (final operation in operations) {
      operation.execute(batch);
    }

    await batch.commit();
  }

  /// Check if document exists
  /// Dokümanın var olup olmadığını kontrol et
  static Future<bool> documentExists(DocumentReference ref) async {
    final doc = await ref.get();
    return doc.exists;
  }

  /// Get document data safely
  /// Doküman verisini güvenli şekilde al
  static Map<String, dynamic>? getDocumentData(DocumentSnapshot doc) {
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return data as Map<String, dynamic>;
  }

  /// Convert query snapshot to list of maps
  /// Query snapshot'ı map listesine dönüştür
  static List<Map<String, dynamic>> querySnapshotToList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((doc) => {
          'id': doc.id,
          ...?getDocumentData(doc),
        })
        .toList();
  }
}

/// Query filter helper class
/// Sorgu filtresi yardımcı sınıfı
abstract class QueryFilter {
  Query apply(Query query);
}

/// Equality filter
/// Eşitlik filtresi
class EqualityFilter extends QueryFilter {
  final String field;
  final dynamic value;

  EqualityFilter(this.field, this.value);

  @override
  Query apply(Query query) => query.where(field, isEqualTo: value);
}

/// Array contains filter
/// Dizi içerir filtresi
class ArrayContainsFilter extends QueryFilter {
  final String field;
  final dynamic value;

  ArrayContainsFilter(this.field, this.value);

  @override
  Query apply(Query query) => query.where(field, arrayContains: value);
}

/// Range filter
/// Aralık filtresi
class RangeFilter extends QueryFilter {
  final String field;
  final dynamic min;
  final dynamic max;

  RangeFilter(this.field, {this.min, this.max});

  @override
  Query apply(Query query) {
    Query result = query;
    if (min != null) result = result.where(field, isGreaterThanOrEqualTo: min);
    if (max != null) result = result.where(field, isLessThanOrEqualTo: max);
    return result;
  }
}

/// Batch operation helper
/// Batch işlemi yardımcısı
abstract class BatchOperation {
  void execute(WriteBatch batch);
}

/// Set operation
/// Set işlemi
class SetOperation extends BatchOperation {
  final DocumentReference ref;
  final Map<String, dynamic> data;
  final SetOptions? options;

  SetOperation(this.ref, this.data, {this.options});

  @override
  void execute(WriteBatch batch) {
    if (options != null) {
      batch.set(ref, data, options!);
    } else {
      batch.set(ref, data);
    }
  }
}

/// Update operation
/// Update işlemi
class UpdateOperation extends BatchOperation {
  final DocumentReference ref;
  final Map<String, dynamic> data;

  UpdateOperation(this.ref, this.data);

  @override
  void execute(WriteBatch batch) {
    batch.update(ref, data);
  }
}

/// Delete operation
/// Delete işlemi
class DeleteOperation extends BatchOperation {
  final DocumentReference ref;

  DeleteOperation(this.ref);

  @override
  void execute(WriteBatch batch) {
    batch.delete(ref);
  }
}