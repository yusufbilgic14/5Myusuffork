import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../constants/app_constants.dart';
import '../../themes/app_themes.dart';
import '../../l10n/app_localizations.dart';
import '../../services/profile_picture_service.dart';
import 'profile_picture_widget.dart';

/// Profil fotoğrafı seçici widget'ı / Profile picture picker widget
class ProfilePicturePickerWidget extends StatefulWidget {
  final String? userId;
  final String? currentPhotoUrl;
  final String? displayName;
  final double size;
  final Function(String?)? onPhotoUpdated;
  final bool showEditButton;
  final bool showDeleteButton;

  const ProfilePicturePickerWidget({
    super.key,
    this.userId,
    this.currentPhotoUrl,
    this.displayName,
    this.size = 120.0,
    this.onPhotoUpdated,
    this.showEditButton = true,
    this.showDeleteButton = true,
  });

  @override
  State<ProfilePicturePickerWidget> createState() => _ProfilePicturePickerWidgetState();
}

class _ProfilePicturePickerWidgetState extends State<ProfilePicturePickerWidget> {
  final ProfilePictureService _profilePictureService = ProfilePictureService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isUploading = false;
  String? _currentPhotoUrl;

  @override
  void initState() {
    super.initState();
    _currentPhotoUrl = widget.currentPhotoUrl;
  }

  @override
  void didUpdateWidget(ProfilePicturePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPhotoUrl != widget.currentPhotoUrl) {
      setState(() {
        _currentPhotoUrl = widget.currentPhotoUrl;
      });
    }
  }

  /// Show photo source selection dialog
  /// Fotoğraf kaynağı seçim dialog'unu göster
  Future<void> _showPhotoSourceDialog() async {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Text(
              'Profil Fotoğrafı Seç',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppThemes.getTextColor(context),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Camera option
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppThemes.getPrimaryColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppThemes.getPrimaryColor(context),
                ),
              ),
              title: const Text('Kameradan Çek'),
              subtitle: const Text('Yeni fotoğraf çek'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            
            // Gallery option
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppThemes.getPrimaryColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: AppThemes.getPrimaryColor(context),
                ),
              ),
              title: const Text('Galeriden Seç'),
              subtitle: const Text('Mevcut fotoğraflardan seç'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            
            // Delete option (if photo exists)
            if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty && widget.showDeleteButton) ...[
              const Divider(),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                ),
                title: const Text(
                  'Fotoğrafı Sil',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: const Text('Mevcut profil fotoğrafını sil'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmationDialog();
                },
              ),
            ],
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Pick image from source
  /// Kaynaktan görüntü seç
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Validate file size
      final file = File(pickedFile.path);
      final fileSize = await file.length();
      const maxSize = 10 * 1024 * 1024; // 10MB

      if (fileSize > maxSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dosya çok büyük. Maksimum boyut 10MB olmalıdır.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Validate file type
      if (!_profilePictureService.isValidImageExtension(pickedFile.name)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Desteklenmeyen dosya formatı. Lütfen JPG, PNG, GIF, WebP veya SVG dosyası seçin.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Upload image
      await _uploadImage(file);
    } catch (e) {
      debugPrint('❌ ProfilePicturePickerWidget: Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Upload image to Firebase Storage
  /// Görüntüyü Firebase Storage'a yükle
  Future<void> _uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final photoUrl = await _profilePictureService.uploadProfilePicture(
        imageFile: imageFile,
        userId: widget.userId,
      );

      if (photoUrl != null) {
        setState(() {
          _currentPhotoUrl = photoUrl;
        });

        // Notify parent widget
        widget.onPhotoUpdated?.call(photoUrl);

        // Clean up old profile pictures
        _profilePictureService.cleanupOldProfilePictures(widget.userId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil fotoğrafı başarıyla güncellendi!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fotoğraf yüklenirken hata oluştu. Lütfen tekrar deneyin.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ ProfilePicturePickerWidget: Error uploading image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf yüklenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  /// Show delete confirmation dialog
  /// Silme onayı dialog'unu göster
  Future<void> _showDeleteConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil Fotoğrafını Sil'),
        content: const Text('Profil fotoğrafınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: TextStyle(color: AppThemes.getSecondaryTextColor(context)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteProfilePicture();
    }
  }

  /// Delete profile picture
  /// Profil fotoğrafını sil
  Future<void> _deleteProfilePicture() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final success = await _profilePictureService.deleteCurrentProfilePicture(widget.userId);

      if (success) {
        setState(() {
          _currentPhotoUrl = null;
        });

        // Notify parent widget
        widget.onPhotoUpdated?.call(null);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil fotoğrafı silindi.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fotoğraf silinirken hata oluştu. Lütfen tekrar deneyin.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ ProfilePicturePickerWidget: Error deleting image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf silinirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  /// Build edit button overlay
  /// Düzenleme butonu overlay'ini oluştur
  Widget _buildEditButtonOverlay() {
    if (!widget.showEditButton) return const SizedBox.shrink();

    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: widget.size * 0.25,
        height: widget.size * 0.25,
        decoration: BoxDecoration(
          color: AppThemes.getPrimaryColor(context),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppThemes.getBackgroundColor(context),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: widget.size * 0.12,
        ),
      ),
    );
  }

  /// Build upload progress overlay
  /// Yükleme ilerleme overlay'ini oluştur
  Widget _buildUploadProgressOverlay() {
    if (!_isUploading) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SizedBox(
            width: widget.size * 0.3,
            height: widget.size * 0.3,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppThemes.getPrimaryColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUploading ? null : _showPhotoSourceDialog,
      child: Stack(
        children: [
          // Profile picture
          ProfilePictureWidget(
            userId: widget.userId,
            profilePhotoUrl: _currentPhotoUrl,
            displayName: widget.displayName,
            size: widget.size,
            showBorder: true,
            borderColor: AppThemes.getPrimaryColor(context).withValues(alpha: 0.3),
            borderWidth: 2,
          ),
          
          // Edit button overlay
          _buildEditButtonOverlay(),
          
          // Upload progress overlay
          _buildUploadProgressOverlay(),
        ],
      ),
    );
  }
}

/// Simple profile picture picker for quick usage
/// Hızlı kullanım için basit profil fotoğrafı seçici
class SimpleProfilePicturePicker extends StatelessWidget {
  final String? userId;
  final String? currentPhotoUrl;
  final String? displayName;
  final Function(String?)? onPhotoUpdated;

  const SimpleProfilePicturePicker({
    super.key,
    this.userId,
    this.currentPhotoUrl,
    this.displayName,
    this.onPhotoUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePicturePickerWidget(
      userId: userId,
      currentPhotoUrl: currentPhotoUrl,
      displayName: displayName,
      onPhotoUpdated: onPhotoUpdated,
      size: 100.0,
    );
  }
}