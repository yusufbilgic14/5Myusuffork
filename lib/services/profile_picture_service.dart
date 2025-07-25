import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'firebase_auth_service.dart';
import 'user_profile_service.dart';

/// Profil fotoğrafı yönetim servisi / Profile picture management service
class ProfilePictureService {
  // Singleton pattern implementation
  static final ProfilePictureService _instance = ProfilePictureService._internal();
  factory ProfilePictureService() => _instance;
  ProfilePictureService._internal();

  // Firebase instances
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserProfileService _profileService = UserProfileService();

  /// Mevcut kullanıcının Firebase UID'sini getir / Get current user's Firebase UID
  String? get currentUserId => _authService.currentAppUser?.id;

  /// Kullanıcının kimlik doğrulaması yapılmış mı kontrol et / Check if user is authenticated
  bool get isAuthenticated => _authService.isAuthenticated;

  // ==========================================
  // PROFILE PICTURE UPLOAD / PROFİL FOTOĞRAFI YÜKLEMESİ
  // ==========================================

  /// Upload profile picture to Firebase Storage
  /// Profil fotoğrafını Firebase Storage'a yükle
  Future<String?> uploadProfilePicture({
    required File imageFile,
    String? userId,
  }) async {
    try {
      final uid = userId ?? currentUserId;
      if (!isAuthenticated || uid == null) {
        debugPrint('❌ ProfilePictureService: User not authenticated');
        return null;
      }

      debugPrint('📸 ProfilePictureService: Starting profile picture upload for user $uid');

      // Validate file size (10MB max for profile pictures)
      final fileSize = await imageFile.length();
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (fileSize > maxSize) {
        debugPrint('❌ ProfilePictureService: File too large: ${fileSize / (1024 * 1024)}MB');
        throw Exception('Dosya çok büyük. Maksimum boyut 10MB olmalıdır.');
      }

      // Generate unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last.toLowerCase();
      final fileName = 'avatar_${timestamp}.$extension';

      // Create storage reference - matches Firebase Storage rules path
      final storageRef = _storage.ref().child('user_profiles/$uid/avatar/$fileName');

      // Set metadata
      final metadata = SettableMetadata(
        contentType: _getContentType(extension),
        customMetadata: {
          'uploaderId': uid,
          'uploadTimestamp': timestamp.toString(),
          'fileType': 'profile_picture',
        },
      );

      debugPrint('🔄 ProfilePictureService: Uploading file to Firebase Storage...');

      // Upload file
      final uploadTask = storageRef.putFile(imageFile, metadata);
      final taskSnapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      debugPrint('✅ ProfilePictureService: File uploaded successfully');

      // Update user profile with new photo URL
      final success = await _profileService.updateProfilePhoto(downloadUrl, uid);
      if (!success) {
        debugPrint('❌ ProfilePictureService: Failed to update profile with new photo URL');
        // Clean up uploaded file if profile update failed
        await _deleteProfilePicture(downloadUrl, uid);
        return null;
      }

      debugPrint('✅ ProfilePictureService: Profile picture uploaded and updated successfully');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ ProfilePictureService: Error uploading profile picture: $e');
      return null;
    }
  }

  /// Upload profile picture from bytes (for web compatibility)
  /// Byte array'den profil fotoğrafı yükle (web uyumluluğu için)
  Future<String?> uploadProfilePictureFromBytes({
    required Uint8List bytes,
    required String fileName,
    String? userId,
  }) async {
    try {
      final uid = userId ?? currentUserId;
      if (!isAuthenticated || uid == null) {
        debugPrint('❌ ProfilePictureService: User not authenticated');
        return null;
      }

      debugPrint('📸 ProfilePictureService: Starting profile picture upload from bytes for user $uid');

      // Validate file size (10MB max for profile pictures)
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (bytes.length > maxSize) {
        debugPrint('❌ ProfilePictureService: File too large: ${bytes.length / (1024 * 1024)}MB');
        throw Exception('Dosya çok büyük. Maksimum boyut 10MB olmalıdır.');
      }

      // Generate unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = fileName.split('.').last.toLowerCase();
      final uniqueFileName = 'avatar_${timestamp}.$extension';

      // Create storage reference
      final storageRef = _storage.ref().child('user_profiles/$uid/avatar/$uniqueFileName');

      // Set metadata
      final metadata = SettableMetadata(
        contentType: _getContentType(extension),
        customMetadata: {
          'uploaderId': uid,
          'uploadTimestamp': timestamp.toString(),
          'fileType': 'profile_picture',
        },
      );

      debugPrint('🔄 ProfilePictureService: Uploading bytes to Firebase Storage...');

      // Upload bytes
      final uploadTask = storageRef.putData(bytes, metadata);
      final taskSnapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      debugPrint('✅ ProfilePictureService: Bytes uploaded successfully');

      // Update user profile with new photo URL
      final success = await _profileService.updateProfilePhoto(downloadUrl, uid);
      if (!success) {
        debugPrint('❌ ProfilePictureService: Failed to update profile with new photo URL');
        // Clean up uploaded file if profile update failed
        await _deleteProfilePicture(downloadUrl, uid);
        return null;
      }

      debugPrint('✅ ProfilePictureService: Profile picture uploaded from bytes and updated successfully');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ ProfilePictureService: Error uploading profile picture from bytes: $e');
      return null;
    }
  }

  // ==========================================
  // PROFILE PICTURE DELETION / PROFİL FOTOĞRAFI SİLME
  // ==========================================

  /// Delete profile picture from Firebase Storage
  /// Profil fotoğrafını Firebase Storage'dan sil
  Future<bool> deleteCurrentProfilePicture([String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (!isAuthenticated || uid == null) {
        debugPrint('❌ ProfilePictureService: User not authenticated');
        return false;
      }

      debugPrint('🗑️ ProfilePictureService: Deleting profile picture for user $uid');

      // Get current profile to get photo URL
      final profile = await _profileService.getUserProfile(uid);
      if (profile?.profilePhotoUrl == null) {
        debugPrint('📝 ProfilePictureService: No profile picture to delete');
        return true; // Nothing to delete
      }

      // Delete from Firebase Storage
      final success = await _deleteProfilePicture(profile!.profilePhotoUrl!, uid);
      if (!success) {
        debugPrint('❌ ProfilePictureService: Failed to delete file from Storage');
        return false;
      }

      // Update profile to remove photo URL
      final updateSuccess = await _profileService.updateProfilePhoto('', uid);
      if (!updateSuccess) {
        debugPrint('❌ ProfilePictureService: Failed to update profile after deletion');
        return false;
      }

      debugPrint('✅ ProfilePictureService: Profile picture deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ ProfilePictureService: Error deleting profile picture: $e');
      return false;
    }
  }

  /// Delete specific profile picture by URL
  /// URL ile belirli profil fotoğrafını sil
  Future<bool> _deleteProfilePicture(String photoUrl, String userId) async {
    try {
      // Extract storage path from URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;

      // Find the storage path (after 'o/')
      final oIndex = pathSegments.indexOf('o');
      if (oIndex == -1 || oIndex >= pathSegments.length - 1) {
        debugPrint('❌ ProfilePictureService: Invalid Firebase Storage URL');
        return false;
      }

      // Get the encoded path and decode it
      final encodedPath = pathSegments[oIndex + 1];
      final decodedPath = Uri.decodeComponent(encodedPath);

      debugPrint('🗑️ ProfilePictureService: Deleting file at path: $decodedPath');

      // Delete from Firebase Storage
      final storageRef = _storage.ref().child(decodedPath);
      await storageRef.delete();

      debugPrint('✅ ProfilePictureService: File deleted from Firebase Storage');
      return true;
    } catch (e) {
      debugPrint('❌ ProfilePictureService: Error deleting file from Storage: $e');
      return false;
    }
  }

  // ==========================================
  // UTILITY METHODS / YARDIMCI METOTLAR
  // ==========================================

  /// Get content type from file extension
  /// Dosya uzantısından içerik tipini al
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }

  /// Validate if file extension is supported
  /// Dosya uzantısının desteklenip desteklenmediğini kontrol et
  bool isValidImageExtension(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    const supportedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'];
    return supportedExtensions.contains(extension);
  }

  /// Get user avatar URL or return null for fallback
  /// Kullanıcı avatar URL'sini al veya fallback için null döndür
  Future<String?> getUserAvatarUrl([String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (uid == null) return null;

      final profile = await _profileService.getUserProfile(uid);
      final photoUrl = profile?.profilePhotoUrl;

      // Return null if empty string or null (for fallback handling)
      if (photoUrl == null || photoUrl.isEmpty) {
        return null;
      }

      return photoUrl;
    } catch (e) {
      debugPrint('❌ ProfilePictureService: Error getting avatar URL: $e');
      return null;
    }
  }

  /// Clean up old profile pictures (keep only the latest one)
  /// Eski profil fotoğraflarını temizle (sadece en yenisini tut)
  Future<void> cleanupOldProfilePictures([String? userId]) async {
    try {
      final uid = userId ?? currentUserId;
      if (!isAuthenticated || uid == null) return;

      debugPrint('🧹 ProfilePictureService: Cleaning up old profile pictures for user $uid');

      // List all files in user's avatar directory
      final listRef = _storage.ref().child('user_profiles/$uid/avatar');
      final result = await listRef.listAll();

      if (result.items.length <= 1) {
        debugPrint('📝 ProfilePictureService: No old files to clean up');
        return; // Keep at least one file or no files to clean
      }

      // Sort by name (which contains timestamp) to keep the newest
      result.items.sort((a, b) => b.name.compareTo(a.name));

      // Delete all except the first (newest) one
      for (int i = 1; i < result.items.length; i++) {
        try {
          await result.items[i].delete();
          debugPrint('🗑️ ProfilePictureService: Deleted old file: ${result.items[i].name}');
        } catch (e) {
          debugPrint('❌ ProfilePictureService: Failed to delete old file: ${result.items[i].name}');
        }
      }

      debugPrint('✅ ProfilePictureService: Cleanup completed');
    } catch (e) {
      debugPrint('❌ ProfilePictureService: Error during cleanup: $e');
    }
  }

  /// Dispose resources
  /// Kaynakları temizle
  void dispose() {
    debugPrint('🧹 ProfilePictureService: Disposing resources');
    // Add any cleanup if needed
  }
}