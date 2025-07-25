import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/club_chat_models.dart';

/// Media preview widget for chat messages
/// Sohbet mesajları için medya önizleme widget'ı
class MediaPreviewWidget extends StatelessWidget {
  final List<File>? localFiles;
  final List<MediaAttachment>? mediaAttachments;
  final bool showDeleteButton;
  final Function(int index)? onDeletePressed;
  final Function(MediaAttachment attachment)? onAttachmentTap;

  const MediaPreviewWidget({
    super.key,
    this.localFiles,
    this.mediaAttachments,
    this.showDeleteButton = false,
    this.onDeletePressed,
    this.onAttachmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocalFiles = localFiles != null && localFiles!.isNotEmpty;
    final hasAttachments = mediaAttachments != null && mediaAttachments!.isNotEmpty;

    debugPrint('🖼️ MediaPreviewWidget: hasLocalFiles: $hasLocalFiles (${localFiles?.length}), hasAttachments: $hasAttachments (${mediaAttachments?.length})');

    if (!hasLocalFiles && !hasAttachments) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasLocalFiles) _buildLocalFilesPreview(context),
          if (hasAttachments) _buildAttachmentsPreview(context),
        ],
      ),
    );
  }

  /// Build preview for local files (before upload)
  /// Yerel dosyalar için önizleme oluştur (yüklemeden önce)
  Widget _buildLocalFilesPreview(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: localFiles!.length,
        itemBuilder: (context, index) {
          final file = localFiles![index];
          return Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                _buildFilePreview(context, file: file),
                if (showDeleteButton)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onDeletePressed?.call(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build preview for uploaded attachments
  /// Yüklenmiş ekler için önizleme oluştur
  Widget _buildAttachmentsPreview(BuildContext context) {
    debugPrint('🖼️ MediaPreviewWidget: Building attachments preview for ${mediaAttachments!.length} attachments');
    
    // For single images in chat, show larger preview
    if (mediaAttachments!.length == 1 && mediaAttachments![0].fileType == 'image') {
      return _buildSingleImagePreview(context, mediaAttachments![0]);
    }
    
    // For multiple attachments, use horizontal scroll
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mediaAttachments!.length,
        itemBuilder: (context, index) {
          final attachment = mediaAttachments![index];
          return Container(
            width: 120,
            height: 120,
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _showFullscreenImage(context, attachment),
              child: _buildAttachmentPreview(context, attachment),
            ),
          );
        },
      ),
    );
  }

  /// Build single image preview for chat messages
  /// Sohbet mesajları için tek görüntü önizlemesi oluştur
  Widget _buildSingleImagePreview(BuildContext context, MediaAttachment attachment) {
    return GestureDetector(
      onTap: () => _showFullscreenImage(context, attachment),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 250,
          maxHeight: 300,
          minWidth: 150,
          minHeight: 100,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildNetworkImage(attachment),
        ),
      ),
    );
  }

  /// Show fullscreen image dialog
  /// Tam ekran görüntü diyaloğunu göster
  void _showFullscreenImage(BuildContext context, MediaAttachment attachment) {
    if (attachment.fileType != 'image') return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Full screen image
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  attachment.fileUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  shape: const CircleBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build preview for individual file
  /// Bireysel dosya için önizleme oluştur
  Widget _buildFilePreview(BuildContext context, {required File file}) {
    final extension = file.path.split('.').last.toLowerCase();
    final isImage = ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isImage
            ? Image.file(
                file,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildFileIcon(extension),
              )
            : _buildFileIcon(extension),
      ),
    );
  }

  /// Build preview for uploaded attachment
  /// Yüklenmiş ek için önizleme oluştur
  Widget _buildAttachmentPreview(BuildContext context, MediaAttachment attachment) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: attachment.fileType == 'image'
            ? _buildNetworkImage(attachment)
            : _buildAttachmentIcon(attachment),
      ),
    );
  }

  /// Build network image widget
  /// Ağ görüntüsü widget'ı oluştur
  Widget _buildNetworkImage(MediaAttachment attachment) {
    final imageUrl = attachment.thumbnailUrl ?? attachment.fileUrl;
    debugPrint('🖼️ MediaPreviewWidget: Loading network image from URL: $imageUrl');
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ MediaPreviewWidget: Error loading image from $imageUrl: $error');
        return _buildAttachmentIcon(attachment);
      },
    );
  }

  /// Build file icon based on extension
  /// Dosya uzantısına göre ikon oluştur
  Widget _buildFileIcon(String extension) {
    IconData iconData;
    Color iconColor;

    switch (extension) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'ppt':
      case 'pptx':
        iconData = Icons.slideshow;
        iconColor = Colors.orange;
        break;
      case 'xls':
      case 'xlsx':
        iconData = Icons.table_chart;
        iconColor = Colors.green;
        break;
      case 'mp3':
      case 'wav':
        iconData = Icons.audio_file;
        iconColor = Colors.purple;
        break;
      case 'mp4':
      case 'mov':
        iconData = Icons.video_file;
        iconColor = Colors.indigo;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
    }

    return Container(
      color: iconColor.withValues(alpha: 0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 32,
              color: iconColor,
            ),
            const SizedBox(height: 4),
            Text(
              extension.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build attachment icon based on type
  /// Ek tipine göre ikon oluştur
  Widget _buildAttachmentIcon(MediaAttachment attachment) {
    final extension = attachment.fileName.split('.').last.toLowerCase();
    
    return Stack(
      children: [
        _buildFileIcon(extension),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _formatFileSize(attachment.fileSize),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Format file size to human readable format
  /// Dosya boyutunu okunabilir formata çevir
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// Full screen media viewer
/// Tam ekran medya görüntüleyici
class FullScreenMediaViewer extends StatelessWidget {
  final MediaAttachment attachment;

  const FullScreenMediaViewer({
    super.key,
    required this.attachment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement download/share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('İndirme özelliği yakında gelecek')),
              );
            },
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: Center(
        child: attachment.fileType == 'image'
            ? InteractiveViewer(
                child: Image.network(
                  attachment.fileUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Görüntü yüklenemedi',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    attachment.originalFileName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(  
                    _formatFileSize(attachment.fileSize),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Format file size to human readable format
  /// Dosya boyutunu okunabilir formata çevir
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Show full screen media viewer
  /// Tam ekran medya görüntüleyiciyi göster
  static void show(BuildContext context, MediaAttachment attachment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenMediaViewer(attachment: attachment),
      ),
    );
  }
}