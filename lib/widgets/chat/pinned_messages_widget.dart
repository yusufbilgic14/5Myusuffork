import 'package:flutter/material.dart';
import '../../models/club_chat_models.dart';
import '../../services/club_chat_service.dart';

/// Pinned messages display widget
/// Sabitlenmiş mesajlar görüntü widget'ı
class PinnedMessagesWidget extends StatefulWidget {
  final String clubId;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  final Function(ChatMessage message)? onMessageTap;

  const PinnedMessagesWidget({
    super.key,
    required this.clubId,
    this.isCollapsed = true,
    this.onToggleCollapse,
    this.onMessageTap,
  });

  @override
  State<PinnedMessagesWidget> createState() => _PinnedMessagesWidgetState();
}

class _PinnedMessagesWidgetState extends State<PinnedMessagesWidget> {
  final ClubChatService _chatService = ClubChatService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatMessage>>(
      stream: _chatService.streamPinnedMessages(widget.clubId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final pinnedMessages = snapshot.data ?? [];
        if (pinnedMessages.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(pinnedMessages.length),
              
              // Messages
              if (!widget.isCollapsed) _buildMessagesList(pinnedMessages),
            ],
          ),
        );
      },
    );
  }

  /// Build pinned messages header
  /// Sabitlenmiş mesajlar başlığını oluştur
  Widget _buildHeader(int count) {
    return InkWell(
      onTap: widget.onToggleCollapse,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.push_pin,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Sabitlenmiş Mesajlar ($count)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (widget.onToggleCollapse != null)
              AnimatedRotation(
                turns: widget.isCollapsed ? 0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build pinned messages list
  /// Sabitlenmiş mesajlar listesini oluştur
  Widget _buildMessagesList(List<ChatMessage> messages) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 8),
        itemCount: messages.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        itemBuilder: (context, index) {
          final message = messages[index];
          return _PinnedMessageItem(
            message: message,
            onTap: () => widget.onMessageTap?.call(message),
          );
        },
      ),
    );
  }
}

/// Individual pinned message item
/// Bireysel sabitlenmiş mesaj öğesi
class _PinnedMessageItem extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onTap;

  const _PinnedMessageItem({
    required this.message,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender and time
            Row(
              children: [
                Expanded(
                  child: Text(
                    message.senderName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatTime(message.pinnedAt ?? message.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            
            // Message content
            Text(
              _getMessagePreview(message),
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Media indicator
            if (_hasMedia(message)) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    _getMediaIcon(message),
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getMediaDescription(message),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Get message preview text
  /// Mesaj önizleme metnini al
  String _getMessagePreview(ChatMessage message) {
    if (message.content.isNotEmpty) {
      return message.content;
    } else if (_hasMedia(message)) {
      return _getMediaDescription(message);
    } else {
      return 'Mesaj içeriği yok';
    }
  }

  /// Check if message has media
  /// Mesajın medyası olup olmadığını kontrol et
  bool _hasMedia(ChatMessage message) {
    return (message.mediaAttachments != null && message.mediaAttachments!.isNotEmpty) ||
           (message.mediaUrls != null && message.mediaUrls!.isNotEmpty);
  }

  /// Get media icon
  /// Medya ikonunu al
  IconData _getMediaIcon(ChatMessage message) {
    if (message.messageType == 'image') return Icons.image;
    if (message.messageType == 'video') return Icons.videocam;
    if (message.messageType == 'voice') return Icons.mic;
    if (message.messageType == 'file') return Icons.attach_file;
    return Icons.attachment;
  }

  /// Get media description
  /// Medya açıklamasını al
  String _getMediaDescription(ChatMessage message) {
    final attachmentCount = message.mediaAttachments?.length ?? 
                           message.mediaUrls?.length ?? 0;
    
    switch (message.messageType) {
      case 'image':
        return attachmentCount > 1 
            ? '$attachmentCount fotoğraf' 
            : 'Fotoğraf';
      case 'video':
        return attachmentCount > 1 
            ? '$attachmentCount video' 
            : 'Video';
      case 'voice':
        return 'Ses mesajı';
      case 'file':
        return attachmentCount > 1 
            ? '$attachmentCount dosya' 
            : 'Dosya';
      default:
        return attachmentCount > 1 
            ? '$attachmentCount ek' 
            : 'Ek';
    }
  }

  /// Format time for display
  /// Görüntü için zamanı formatla
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}dk';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}sa';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}g';
    } else {
      // Format as day/month
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}

/// Pinned messages screen for full view
/// Tam görünüm için sabitlenmiş mesajlar ekranı
class PinnedMessagesScreen extends StatelessWidget {
  final String clubId;
  final String clubName;

  const PinnedMessagesScreen({
    super.key,
    required this.clubId,
    required this.clubName,
  });

  @override
  Widget build(BuildContext context) {
    final chatService = ClubChatService();
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sabitlenmiş Mesajlar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              clubName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: StreamBuilder<List<ChatMessage>>(
        stream: chatService.streamPinnedMessages(clubId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pinnedMessages = snapshot.data ?? [];
          
          if (pinnedMessages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.push_pin_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sabitlenmiş mesaj yok',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Önemli mesajları sabitleyin',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pinnedMessages.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final message = pinnedMessages[index];
              return _PinnedMessageFullItem(message: message);
            },
          );
        },
      ),
    );
  }
}

/// Full pinned message item for screen view
/// Ekran görünümü için tam sabitlenmiş mesaj öğesi
class _PinnedMessageFullItem extends StatelessWidget {
  final ChatMessage message;

  const _PinnedMessageFullItem({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with sender and pin info
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    message.senderName.isNotEmpty 
                        ? message.senderName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.senderName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Sabitlenme: ${_formatDateTime(message.pinnedAt ?? message.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.push_pin,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Message content
            if (message.content.isNotEmpty) ...[
              Text(
                message.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
            ],
            
            // Original message time
            Text(
              'Orijinal mesaj: ${_formatDateTime(message.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format date time for display
  /// Görüntü için tarih zamanını formatla
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Bugün ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Dün ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      const weekdays = ['Pazar', 'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi'];
      return '${weekdays[dateTime.weekday % 7]} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}