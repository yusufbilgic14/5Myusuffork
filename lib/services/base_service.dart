import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

import 'firebase_auth_service.dart';

/// Abstract base service class for common Firebase operations
/// Firebase işlemleri için ortak abstract base servis sınıfı
abstract class BaseFirebaseService {
  // Firebase instances - shared across all services
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuthService authService = FirebaseAuthService();

  // Stream subscriptions for memory management
  final Map<String, StreamSubscription> subscriptions = {};

  // Common cache expiry duration
  static const Duration defaultCacheExpiry = Duration(minutes: 10);

  /// Get current user's Firebase UID
  String? get currentUserId => authService.currentAppUser?.id;

  /// Check if user is authenticated
  bool get isAuthenticated => authService.isAuthenticated;

  /// Dispose all stream subscriptions
  void dispose() {
    for (var subscription in subscriptions.values) {
      subscription.cancel();
    }
    subscriptions.clear();
  }

  /// Add a stream subscription with automatic cleanup
  void addSubscription(String key, StreamSubscription subscription) {
    // Cancel existing subscription if any
    subscriptions[key]?.cancel();
    subscriptions[key] = subscription;
  }

  /// Remove a specific subscription
  void removeSubscription(String key) {
    subscriptions[key]?.cancel();
    subscriptions.remove(key);
  }

  /// Common error logging
  void logError(String operation, dynamic error, [StackTrace? stackTrace]) {
    debugPrint('❌ ${runtimeType}: $operation failed - $error');
    if (stackTrace != null && kDebugMode) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Common success logging
  void logSuccess(String operation, [String? details]) {
    debugPrint('✅ ${runtimeType}: $operation successful${details != null ? ' - $details' : ''}');
  }

  /// Common info logging
  void logInfo(String message) {
    debugPrint('ℹ️ ${runtimeType}: $message');
  }

  /// Check authentication and throw if not authenticated
  void requireAuthentication() {
    if (!isAuthenticated || currentUserId == null) {
      throw Exception('User not authenticated');
    }
  }

  /// Get user document reference
  DocumentReference getUserDocument([String? userId]) {
    final uid = userId ?? currentUserId;
    if (uid == null) throw Exception('User ID is null');
    return firestore.collection('users').doc(uid);
  }

  /// Batch write with error handling
  Future<void> executeBatch(List<void Function(WriteBatch)> operations) async {
    try {
      final batch = firestore.batch();
      for (final operation in operations) {
        operation(batch);
      }
      await batch.commit();
      logSuccess('Batch operations');
    } catch (error, stackTrace) {
      logError('Batch operations', error, stackTrace);
      rethrow;
    }
  }

  /// Convert Firestore document to Map with error handling
  Map<String, dynamic>? documentToMap(DocumentSnapshot doc) {
    if (!doc.exists) {
      logInfo('Document ${doc.id} does not exist');
      return null;
    }
    
    final data = doc.data();
    if (data == null) {
      logInfo('Document ${doc.id} has no data');
      return null;
    }
    
    return data as Map<String, dynamic>;
  }

  /// Standardized query with authentication check
  Query authenticatedQuery(String collection) {
    requireAuthentication();
    return firestore.collection(collection);
  }

  /// User-specific collection query
  Query userCollectionQuery(String collection) {
    requireAuthentication();
    return getUserDocument().collection(collection);
  }
}