import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

/// Media picker widget for chat messages
/// Sohbet mesajları için medya seçici widget'ı
class MediaPickerWidget extends StatelessWidget {
  final Function(List<File> images) onImagesSelected;
  final Function(File document, String fileName) onDocumentSelected;
  final Function(File voice) onVoiceSelected;
  final VoidCallback? onCameraPressed;
  final VoidCallback? onVoiceRecordPressed;

  const MediaPickerWidget({
    super.key,
    required this.onImagesSelected,
    required this.onDocumentSelected,
    required this.onVoiceSelected,
    this.onCameraPressed,
    this.onVoiceRecordPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Text(
            'Medya Seç',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Media options grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _MediaOption(
                icon: Icons.camera_alt,
                label: 'Kamera',
                color: Colors.blue,
                onTap: () {
                  debugPrint('📷 MediaPickerWidget: Camera button tapped!');
                  _pickFromCamera(context);
                },
              ),
              _MediaOption(
                icon: Icons.photo_library,
                label: 'Galeri',
                color: Colors.green,
                onTap: () => _pickFromGallery(context),
              ),
              _MediaOption(
                icon: Icons.description,
                label: 'Dosya',
                color: Colors.orange,
                onTap: () => _pickDocument(context),
              ),
              _MediaOption(
                icon: Icons.mic,
                label: 'Ses Kaydı',
                color: Colors.red,
                onTap: onVoiceRecordPressed,
              ),
              _MediaOption(
                icon: Icons.videocam,
                label: 'Video',
                color: Colors.purple,
                onTap: () => _pickVideo(context),
              ),
              _MediaOption(
                icon: Icons.location_on,
                label: 'Konum',
                color: Colors.teal,
                onTap: () => _shareLocation(context),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Cancel button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'İptal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          
          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  /// Pick image from camera
  /// Kameradan fotoğraf çek
  Future<void> _pickFromCamera(BuildContext context) async {
    try {
      debugPrint('📷 MediaPickerWidget: Starting camera picker...');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      debugPrint('📷 MediaPickerWidget: Camera picker result: ${image?.path}');
      
      if (image != null) {
        debugPrint('📷 MediaPickerWidget: Calling onImagesSelected with image: ${image.path}');
        onImagesSelected([File(image.path)]);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } else {
        debugPrint('📷 MediaPickerWidget: No image selected from camera');
      }
    } catch (e) {
      debugPrint('❌ MediaPickerWidget: Error picking from camera: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Kamera erişiminde hata oluştu');
      }
    }
  }

  /// Pick images from gallery
  /// Galeriden fotoğraf seç
  Future<void> _pickFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (images.isNotEmpty) {
        final List<File> imageFiles = images.map((xFile) => File(xFile.path)).toList();
        onImagesSelected(imageFiles);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('❌ MediaPickerWidget: Error picking from gallery: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Galeri erişiminde hata oluştu');
      }
    }
  }

  /// Pick document file
  /// Dosya seç
  Future<void> _pickDocument(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        onDocumentSelected(file, fileName);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('❌ MediaPickerWidget: Error picking document: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Dosya seçiminde hata oluştu');
      }
    }
  }

  /// Pick video file
  /// Video dosyası seç
  Future<void> _pickVideo(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5), // 5 minute limit
      );

      if (video != null) {
        onImagesSelected([File(video.path)]); // Treat as image for now
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      debugPrint('❌ MediaPickerWidget: Error picking video: $e');
      if (context.mounted) {
        _showErrorSnackBar(context, 'Video seçiminde hata oluştu');
      }
    }
  }

  /// Share location (placeholder)
  /// Konum paylaş (yer tutucu)
  Future<void> _shareLocation(BuildContext context) async {
    // TODO: Implement location sharing
    if (context.mounted) {
      _showErrorSnackBar(context, 'Konum paylaşımı yakında gelecek');
      Navigator.of(context).pop();
    }
  }

  /// Show error snackbar
  /// Hata snackbar'ı göster
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show media picker bottom sheet
  /// Medya seçici alt sayfasını göster
  static Future<void> show(
    BuildContext context, {
    required Function(List<File> images) onImagesSelected,
    required Function(File document, String fileName) onDocumentSelected,
    required Function(File voice) onVoiceSelected,
    VoidCallback? onCameraPressed,
    VoidCallback? onVoiceRecordPressed,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MediaPickerWidget(
        onImagesSelected: onImagesSelected,
        onDocumentSelected: onDocumentSelected,
        onVoiceSelected: onVoiceSelected,
        onCameraPressed: onCameraPressed,
        onVoiceRecordPressed: onVoiceRecordPressed,
      ),
    );
  }
}

/// Individual media option widget
/// Bireysel medya seçeneği widget'ı
class _MediaOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _MediaOption({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}