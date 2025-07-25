import 'package:flutter/material.dart';
import '../../models/club_chat_models.dart';
import '../../services/club_chat_service.dart';

/// User presence indicator widget
/// Kullanıcı varlık göstergesi widget'ı
class UserPresenceWidget extends StatefulWidget {
  final String clubId;
  final bool showTypingIndicator;
  final bool showOnlineCount;

  const UserPresenceWidget({
    super.key,
    required this.clubId,
    this.showTypingIndicator = true,
    this.showOnlineCount = true,
  });

  @override
  State<UserPresenceWidget> createState() => _UserPresenceWidgetState();
}

class _UserPresenceWidgetState extends State<UserPresenceWidget> {
  final ClubChatService _chatService = ClubChatService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserPresence>>(
      stream: _chatService.streamUserPresence(widget.clubId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final presenceList = snapshot.data ?? [];
        final onlineUsers = presenceList.where((p) => p.isOnline).toList();
        final typingUsers = presenceList.where((p) => p.isTyping && p.isOnline).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Online users count
            if (widget.showOnlineCount && onlineUsers.isNotEmpty)
              _buildOnlineIndicator(onlineUsers),
            
            // Typing indicator
            if (widget.showTypingIndicator && typingUsers.isNotEmpty)
              _buildTypingIndicator(typingUsers),
          ],
        );
      },
    );
  }

  /// Build online users count indicator
  /// Çevrimiçi kullanıcı sayısı göstergesini oluştur
  Widget _buildOnlineIndicator(List<UserPresence> onlineUsers) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${onlineUsers.length} kişi çevrimiçi',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onlineUsers.length <= 5) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showOnlineUsersList(onlineUsers),
              child: Icon(
                Icons.info_outline,
                size: 14,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build typing indicator
  /// Yazma göstergesini oluştur
  Widget _buildTypingIndicator(List<UserPresence> typingUsers) {
    final typingText = _getTypingText(typingUsers);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const TypingAnimation(),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              typingText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get typing indicator text
  /// Yazma göstergesi metnini al
  String _getTypingText(List<UserPresence> typingUsers) {
    if (typingUsers.isEmpty) return '';
    
    if (typingUsers.length == 1) {
      return '${typingUsers.first.userName} yazıyor...';
    } else if (typingUsers.length == 2) {
      return '${typingUsers[0].userName} ve ${typingUsers[1].userName} yazıyor...';
    } else {
      return '${typingUsers[0].userName} ve ${typingUsers.length - 1} kişi daha yazıyor...';
    }
  }

  /// Show online users list
  /// Çevrimiçi kullanıcılar listesini göster
  void _showOnlineUsersList(List<UserPresence> onlineUsers) {
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
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.circle,
                    size: 12,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Çevrimiçi Kullanıcılar (${onlineUsers.length})',
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
                itemCount: onlineUsers.length,
                itemBuilder: (context, index) {
                  final presence = onlineUsers[index];
                  return ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            presence.userName.isNotEmpty 
                                ? presence.userName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(presence.userName),
                    subtitle: Text(
                      presence.isTyping 
                          ? 'Yazıyor...' 
                          : _formatLastSeen(presence.lastSeen),
                      style: TextStyle(
                        color: presence.isTyping 
                            ? Colors.green 
                            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontStyle: presence.isTyping ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                    trailing: presence.isTyping
                        ? const TypingAnimation(size: 16)
                        : null,
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

  /// Format last seen time
  /// Son görülme zamanını formatla
  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Şimdi çevrimiçi';
    } else if (difference.inMinutes < 5) {
      return '${difference.inMinutes} dakika önce görüldü';
    } else {
      return 'Çevrimiçi';
    }
  }
}

/// Animated typing indicator
/// Animasyonlu yazma göstergesi
class TypingAnimation extends StatefulWidget {
  final double size;
  final Color? color;

  const TypingAnimation({
    super.key,
    this.size = 20,
    this.color,
  });

  @override
  State<TypingAnimation> createState() => _TypingAnimationState();
}

class _TypingAnimationState extends State<TypingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            0.6 + index * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? 
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

    return SizedBox(
      width: widget.size * 2,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Opacity(
                opacity: _animations[index].value,
                child: Container(
                  width: widget.size * 0.2,
                  height: widget.size * 0.2,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// Online status indicator for individual user
/// Bireysel kullanıcı için çevrimiçi durum göstergesi
class OnlineStatusIndicator extends StatelessWidget {
  final bool isOnline;
  final double size;

  const OnlineStatusIndicator({
    super.key,
    required this.isOnline,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline ? Colors.green : Colors.grey,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
    );
  }
}

/// User presence status widget for profile displays
/// Profil gösterimleri için kullanıcı varlık durumu widget'ı
class UserPresenceStatus extends StatelessWidget {
  final UserPresence presence;
  final bool showLastSeen;

  const UserPresenceStatus({
    super.key,
    required this.presence,
    this.showLastSeen = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OnlineStatusIndicator(isOnline: presence.isOnline),
        const SizedBox(width: 6),
        if (presence.isTyping) ...[
          Text(
            'Yazıyor...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 4),
          const TypingAnimation(size: 12),
        ] else if (presence.isOnline) ...[
          Text(
            'Çevrimiçi',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green,
            ),
          ),
        ] else if (showLastSeen) ...[
          Text(
            _formatLastSeen(presence.lastSeen),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }

  /// Format last seen time
  /// Son görülme zamanını formatla
  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'Şimdi görüldü';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} dakika önce';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
    }
  }
}