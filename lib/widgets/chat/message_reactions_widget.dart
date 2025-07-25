import 'package:flutter/material.dart';
import '../../models/club_chat_models.dart';
import '../../services/club_chat_service.dart';

/// Message reactions display and picker widget
/// Mesaj reaksiyonları görüntü ve seçici widget'ı
class MessageReactionsWidget extends StatefulWidget {
  final ChatMessage message;
  final String currentUserId;
  final bool showAddButton;

  const MessageReactionsWidget({
    super.key,
    required this.message,
    required this.currentUserId,
    this.showAddButton = true,
  });

  @override
  State<MessageReactionsWidget> createState() => _MessageReactionsWidgetState();
}

class _MessageReactionsWidgetState extends State<MessageReactionsWidget> {
  final ClubChatService _chatService = ClubChatService();

  @override
  Widget build(BuildContext context) {
    if (widget.message.reactions == null || widget.message.reactions!.isEmpty) {
      return widget.showAddButton ? _buildAddReactionButton() : const SizedBox.shrink();
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...widget.message.reactions!.entries.map((entry) =>
          _buildReactionChip(entry.key, entry.value),
        ),
        if (widget.showAddButton) _buildAddReactionButton(),
      ],
    );
  }

  /// Build individual reaction chip
  /// Bireysel reaksiyon çipini oluştur
  Widget _buildReactionChip(String emoji, int count) {
    return StreamBuilder<List<MessageReaction>>(
      stream: _chatService.streamMessageReactions(widget.message.messageId),
      builder: (context, snapshot) {
        final reactions = snapshot.data ?? [];
        final userReacted = reactions.any((r) => r.userId == widget.currentUserId && r.emoji == emoji);

        return GestureDetector(
          onTap: () => _toggleReaction(emoji),
          onLongPress: () => _showReactionDetails(emoji, reactions),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: userReacted
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: userReacted
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                width: userReacted ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 14),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: userReacted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: userReacted ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build add reaction button
  /// Reaksiyon ekleme butonunu oluştur
  Widget _buildAddReactionButton() {
    return GestureDetector(
      onTap: () => _showReactionPicker(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.add_reaction_outlined,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  /// Toggle reaction on message
  /// Mesajda reaksiyonu değiştir
  Future<void> _toggleReaction(String emoji) async {
    try {
      // Check if user already reacted with this emoji
      final reactions = await _chatService.streamMessageReactions(widget.message.messageId).first;
      final userReaction = reactions.firstWhere(
        (r) => r.userId == widget.currentUserId && r.emoji == emoji,
        orElse: () => MessageReaction(
          reactionId: '',
          messageId: '',
          userId: '',
          userName: '',
          emoji: '',
          createdAt: DateTime.now(),
        ),
      );

      if (userReaction.reactionId.isNotEmpty) {
        // Remove reaction
        await _chatService.removeReaction(
          messageId: widget.message.messageId,
          emoji: emoji,
        );
      } else {
        // Add reaction
        await _chatService.addReaction(
          messageId: widget.message.messageId,
          emoji: emoji,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reaksiyon eklenirken hata oluştu: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Show reaction picker dialog
  /// Reaksiyon seçici diyaloğunu göster
  void _showReactionPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ReactionPickerWidget(
        onReactionSelected: (emoji) async {
          Navigator.of(context).pop();
          await _toggleReaction(emoji);
        },
      ),
    );
  }

  /// Show reaction details
  /// Reaksiyon detaylarını göster
  void _showReactionDetails(String emoji, List<MessageReaction> allReactions) {
    final emojiReactions = allReactions.where((r) => r.emoji == emoji).toList();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Row(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Text(
                  '${emojiReactions.length} kişi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Users list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: emojiReactions.length,
                itemBuilder: (context, index) {
                  final reaction = emojiReactions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        reaction.userName.isNotEmpty 
                            ? reaction.userName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    title: Text(reaction.userName),
                    subtitle: Text(
                      _formatReactionTime(reaction.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            
            // Safe area padding
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  /// Format reaction time
  /// Reaksiyon zamanını formatla
  String _formatReactionTime(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Şimdi';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else {
      return '${difference.inDays} gün önce';
    }
  }
}

/// Reaction picker widget
/// Reaksiyon seçici widget'ı
class ReactionPickerWidget extends StatelessWidget {
  final Function(String emoji) onReactionSelected;

  const ReactionPickerWidget({
    super.key,
    required this.onReactionSelected,
  });

  static const List<String> _commonEmojis = [
    '👍', '❤️', '😂', '😮', '😢', '😡',
    '🔥', '👏', '🎉', '💯', '❤️‍🔥', '🥳',
    '😍', '🤔', '👎', '😭', '🙄', '😴',
    '🤩', '😘', '🤗', '🤯', '🥺', '😎',
  ];

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
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Text(
            'Reaksiyon Seç',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Emoji grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: _commonEmojis.length,
            itemBuilder: (context, index) {
              final emoji = _commonEmojis[index];
              return GestureDetector(
                onTap: () => onReactionSelected(emoji),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}