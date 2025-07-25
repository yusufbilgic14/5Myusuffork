import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Standardized error handling utility for the application
/// Uygulama için standartlaştırılmış hata yönetim yardımcısı
class ErrorHandler {
  
  /// Handle Firebase Auth errors with user-friendly messages
  /// Firebase Auth hatalarını kullanıcı dostu mesajlarla ele alır
  static String handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Kullanıcı bulunamadı';
        case 'wrong-password':
          return 'Yanlış şifre';
        case 'email-already-in-use':
          return 'Bu e-posta adresi zaten kullanımda';
        case 'weak-password':
          return 'Şifre çok zayıf';
        case 'invalid-email':
          return 'Geçersiz e-posta adresi';
        case 'user-disabled':
          return 'Kullanıcı hesabı devre dışı';
        case 'too-many-requests':
          return 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin';
        case 'network-request-failed':
          return 'İnternet bağlantısı hatası';
        default:
          return 'Kimlik doğrulama hatası: ${error.message ?? 'Bilinmeyen hata'}';
      }
    }
    return 'Kimlik doğrulama hatası';
  }

  /// Handle Firestore errors with user-friendly messages
  /// Firestore hatalarını kullanıcı dostu mesajlarla ele alır
  static String handleFirestoreError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Bu işlem için yetkiniz yok';
        case 'not-found':
          return 'İstenen veri bulunamadı';
        case 'already-exists':
          return 'Bu veri zaten mevcut';
        case 'resource-exhausted':
          return 'Sistem kapasitesi aşıldı. Lütfen daha sonra tekrar deneyin';
        case 'unauthenticated':
          return 'Oturum açmanız gerekiyor';
        case 'unavailable':
          return 'Servis şu anda kullanılamıyor';
        case 'deadline-exceeded':
          return 'İşlem zaman aşımına uğradı';
        case 'cancelled':
          return 'İşlem iptal edildi';
        case 'data-loss':
          return 'Veri kaybı oluştu';
        case 'invalid-argument':
          return 'Geçersiz parametre';
        case 'out-of-range':
          return 'Değer aralık dışında';
        case 'unimplemented':
          return 'Bu özellik henüz desteklenmiyor';
        case 'internal':
          return 'Sunucu hatası';
        case 'unknown':
          return 'Bilinmeyen hata oluştu';
        default:
          return 'Veritabanı hatası: ${error.message ?? 'Bilinmeyen hata'}';
      }
    }
    return 'Veritabanı hatası';
  }

  /// Handle network errors
  /// Ağ hatalarını ele alır
  static String handleNetworkError(dynamic error) {
    final errorMessage = error.toString().toLowerCase();
    
    if (errorMessage.contains('socket') || 
        errorMessage.contains('network') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('timeout')) {
      return 'İnternet bağlantısı hatası. Lütfen bağlantınızı kontrol edin';
    }
    
    return 'Ağ hatası oluştu';
  }

  /// Generic error handler that determines error type and returns appropriate message
  /// Hata türünü belirleyip uygun mesajı döndüren genel hata yakalayıcısı
  static String handleError(dynamic error, [String? fallbackMessage]) {
    if (error is FirebaseAuthException) {
      return handleAuthError(error);
    } else if (error is FirebaseException) {
      return handleFirestoreError(error);
    } else if (error.toString().toLowerCase().contains('network') ||
               error.toString().toLowerCase().contains('socket') ||
               error.toString().toLowerCase().contains('connection')) {
      return handleNetworkError(error);
    } else {
      return fallbackMessage ?? 'Bir hata oluştu: ${error.toString()}';
    }
  }

  /// Log error with context for debugging
  /// Hata ayıklama için bağlamla birlikte hata kaydı
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    debugPrint('❌ ERROR in $context: $error');
    if (stackTrace != null && kDebugMode) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Execute operation with error handling and optional retry
  /// Hata yakalama ve isteğe bağlı yeniden deneme ile işlem yürütme
  static Future<T?> executeWithErrorHandling<T>(
    Future<T> Function() operation, {
    String? context,
    int maxRetries = 0,
    Duration retryDelay = const Duration(seconds: 1),
    String? fallbackMessage,
  }) async {
    int attempts = 0;
    
    while (attempts <= maxRetries) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        attempts++;
        
        if (context != null) {
          logError(context, error, stackTrace);
        }
        
        // If we've exhausted retries, throw the handled error
        if (attempts > maxRetries) {
          throw Exception(handleError(error, fallbackMessage));
        }
        
        // Wait before retry
        if (retryDelay.inMilliseconds > 0) {
          await Future.delayed(retryDelay);
        }
      }
    }
    
    return null;
  }

  /// Show error message to user (placeholder for UI implementation)
  /// Kullanıcıya hata mesajı göster (UI uygulaması için yer tutucu)
  static void showErrorToUser(String message) {
    // This would typically show a snackbar or dialog
    // UI implementation would be done in the actual screens
    debugPrint('🔔 User Error: $message');
  }
}

/// Extension on Exception for easier error handling
/// Daha kolay hata yönetimi için Exception uzantısı
extension ExceptionExtension on Exception {
  String get userFriendlyMessage {
    return ErrorHandler.handleError(this);
  }
}