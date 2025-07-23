import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../constants/app_constants.dart';
import '../themes/app_themes.dart';
import '../models/club_chat_models.dart';
import '../models/user_interaction_models.dart';
import '../services/club_chat_service.dart';
import '../services/firebase_auth_service.dart';
import '../l10n/app_localizations.dart';

/// Real-time club chat screen
/// Gerçek zamanlı kulüp sohbet ekranı
class ClubChatScreen extends StatefulWidget {
  final Club club;

  const ClubChatScreen({
    super.key,
    required this.club,
  });

  @override
  State<ClubChatScreen> createState() => _ClubChatScreenState();
}

class _ClubChatScreenState extends State<ClubChatScreen> with WidgetsBindingObserver {
  final ClubChatService _chatService = ClubChatService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();

  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  StreamSubscription<List<ChatParticipant>>? _participantsSubscription;

  List<ChatMessage> _messages = [];
  List<ChatParticipant> _participants = [];
  bool _isLoading = true;
  bool _isSending = false;
  ChatMessage? _replyToMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeChat();
    _setupMessageListener();
    _setupParticipantsListener();
    _updateLastSeen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messagesSubscription?.cancel();
    _participantsSubscription?.cancel();
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _updateLastSeen();
    }
  }

  /// Initialize chat room
  /// Sohbet odasını başlat
  Future<void> _initializeChat() async {
    try {
      await _chatService.createOrGetChatRoom(
        clubId: widget.club.clubId,
        clubName: widget.club.displayName,
        requiresApproval: true,
      );
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ ClubChatScreen: Error initializing chat: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Setup real-time message listener
  /// Gerçek zamanlı mesaj dinleyicisini kurr
  void _setupMessageListener() {
    _messagesSubscription = _chatService
        .streamChatMessages(widget.club.clubId)
        .listen(
      (messages) {
        setState(() {
          _messages = messages;
        });
        _scrollToBottom();
      },
      onError: (error) {
        debugPrint('❌ ClubChatScreen: Error listening to messages: $error');
      },
    );
  }

  /// Setup participants listener
  /// Katılımcı dinleyicisini kur
  void _setupParticipantsListener() {
    _participantsSubscription = _chatService
        .streamChatParticipants(widget.club.clubId)
        .listen(
      (participants) {
        setState(() {
          _participants = participants;
        });
      },
      onError: (error) {
        debugPrint('❌ ClubChatScreen: Error listening to participants: $error');
      },
    );
  }

  /// Update user's last seen timestamp
  /// Kullanıcının son görülme zamanını güncelle
  void _updateLastSeen() {
    _chatService.updateLastSeen(widget.club.clubId);
  }

  /// Scroll to bottom of chat
  /// Sohbetin altına kaydır
  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  /// Send message
  /// Mesaj gönder
  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final success = await _chatService.sendMessage(
        clubId: widget.club.clubId,
        content: content,
        replyToMessageId: _replyToMessage?.messageId,
        replyToContent: _replyToMessage?.content,
        replyToSenderName: _replyToMessage?.senderName,
      );

      if (success) {
        _messageController.clear();
        _clearReply();
        _scrollToBottom();
        
        // Haptic feedback
        HapticFeedback.lightImpact();
      } else {
        _showErrorSnackBar('Failed to send message');
      }
    } catch (e) {
      debugPrint('❌ ClubChatScreen: Error sending message: $e');
      _showErrorSnackBar('Error sending message: $e');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  /// Set reply to message
  /// Mesaja yanıt ayarla
  void _setReplyToMessage(ChatMessage message) {
    setState(() {
      _replyToMessage = message;
    });
    _messageFocusNode.requestFocus();
  }

  /// Clear reply
  /// Yanıtı temizle
  void _clearReply() {
    setState(() {
      _replyToMessage = null;
    });
  }

  /// Show error snackbar
  /// Hata snackbar'ı göster
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show message options
  /// Mesaj seçeneklerini göster
  void _showMessageOptions(ChatMessage message) {
    final isOwnMessage = message.senderId == _authService.currentAppUser?.id;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppThemes.getSurfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Reply option
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                _setReplyToMessage(message);
              },
            ),

            // Copy text
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy Text'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied')),
                );
              },
            ),

            if (isOwnMessage) ...[
              const Divider(),
              
              // Edit message
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditMessageDialog(message);
                },
              ),

              // Delete message
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteMessageDialog(message);
                },
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Show edit message dialog
  /// Mesaj düzenleme dialogunu göster
  void _showEditMessageDialog(ChatMessage message) {
    final controller = TextEditingController(text: message.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter your message...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newContent = controller.text.trim();
              if (newContent.isNotEmpty) {
                Navigator.pop(context);
                final success = await _chatService.editMessage(
                  messageId: message.messageId,
                  newContent: newContent,
                );
                if (!success) {
                  _showErrorSnackBar('Failed to edit message');
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  /// Show delete message dialog
  /// Mesaj silme dialogunu göster
  void _showDeleteMessageDialog(ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _chatService.deleteMessage(message.messageId);
              if (!success) {
                _showErrorSnackBar('Failed to delete message');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.getBackgroundColor(context),
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingIndicator() : _buildChatInterface(),
    );
  }

  /// Build app bar
  /// Uygulama çubuğunu oluştur
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppThemes.getPrimaryColor(context),
      foregroundColor: Colors.white,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.club.displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_participants.isNotEmpty)
            Text(
              '${_participants.length} members',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
        ],
      ),
      actions: [
        // Participants list button
        IconButton(
          onPressed: _showParticipantsList,
          icon: const Icon(Icons.people),
        ),
        
        // Chat options menu
        PopupMenuButton<String>(
          onSelected: _handleChatMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'participants',
              child: ListTile(
                leading: Icon(Icons.people),
                title: Text('Members'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Chat Settings'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build loading indicator
  /// Yükleme göstergesini oluştur
  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Build chat interface
  /// Sohbet arayüzünü oluştur
  Widget _buildChatInterface() {
    return Column(
      children: [
        // Messages list
        Expanded(
          child: _buildMessagesList(),
        ),
        
        // Reply preview
        if (_replyToMessage != null) _buildReplyPreview(),
        
        // Message input
        _buildMessageInput(),
      ],
    );
  }

  /// Build messages list
  /// Mesaj listesini oluştur
  Widget _buildMessagesList() {
    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isOwnMessage = message.senderId == _authService.currentAppUser?.id;
        final showAvatar = index == 0 || 
            _messages[index - 1].senderId != message.senderId;

        return _buildMessageItem(message, isOwnMessage, showAvatar);
      },
    );
  }

  /// Build empty state
  /// Boş durum arayüzünü oluştur
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// Build message item
  /// Mesaj öğesini oluştur
  Widget _buildMessageItem(ChatMessage message, bool isOwnMessage, bool showAvatar) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwnMessage && showAvatar) _buildAvatar(message),
          if (!isOwnMessage && !showAvatar) const SizedBox(width: 40),
          
          Flexible(
            child: GestureDetector(
              onLongPress: () => _showMessageOptions(message),
              child: Container(
                margin: EdgeInsets.only(
                  left: isOwnMessage ? 60 : 0,
                  right: isOwnMessage ? 0 : 60,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isOwnMessage 
                      ? AppThemes.getPrimaryColor(context)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reply indicator
                    if (message.replyToMessageId != null) 
                      _buildReplyIndicator(message),
                    
                    // Sender name (for group messages)
                    if (!isOwnMessage)
                      Text(
                        message.senderName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppThemes.getPrimaryColor(context),
                        ),
                      ),
                    
                    // Message content
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: isOwnMessage ? Colors.white : Colors.black87,
                      ),
                    ),
                    
                    // Message metadata
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatMessageTime(message.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: isOwnMessage ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        if (message.isEdited) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(edited)',
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: isOwnMessage ? Colors.white60 : Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          if (isOwnMessage && showAvatar) _buildAvatar(message),
          if (isOwnMessage && !showAvatar) const SizedBox(width: 40),
        ],
      ),
    );
  }

  /// Build user avatar
  /// Kullanıcı avatarını oluştur
  Widget _buildAvatar(ChatMessage message) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppThemes.getPrimaryColor(context),
        shape: BoxShape.circle,
      ),
      child: message.senderAvatar != null
          ? ClipOval(
              child: Image.network(
                message.senderAvatar!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(message.senderName),
              ),
            )
          : _buildInitialsAvatar(message.senderName),
    );
  }

  /// Build initials avatar
  /// Baş harfler avatarını oluştur
  Widget _buildInitialsAvatar(String name) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build reply indicator
  /// Yanıt göstergesini oluştur
  Widget _buildReplyIndicator(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.replyToSenderName ?? 'Unknown',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
          Text(
            message.replyToContent ?? '',
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build reply preview
  /// Yanıt önizlemesini oluştur
  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyToMessage!.senderName}:',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  _replyToMessage!.content,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearReply,
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }

  /// Build message input
  /// Mesaj giriş alanını oluştur
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _messageFocusNode,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppThemes.getPrimaryColor(context),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isSending ? null : _sendMessage,
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show participants list
  /// Katılımcı listesini göster
  void _showParticipantsList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppThemes.getSurfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Text(
              'Members (${_participants.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Participants list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _participants.length,
                itemBuilder: (context, index) {
                  final participant = _participants[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppThemes.getPrimaryColor(context),
                      child: participant.userAvatar != null
                          ? ClipOval(
                              child: Image.network(
                                participant.userAvatar!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Text(participant.userName[0].toUpperCase()),
                              ),
                            )
                          : Text(participant.userName[0].toUpperCase()),
                    ),
                    title: Text(participant.userName),
                    subtitle: Text(participant.role),
                    trailing: participant.role == 'creator'
                        ? const Icon(Icons.star, color: Colors.amber)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle chat menu actions
  /// Sohbet menü eylemlerini işle
  void _handleChatMenuAction(String action) {
    switch (action) {
      case 'participants':
        _showParticipantsList();
        break;
      case 'settings':
        // TODO: Implement chat settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat settings coming soon')),
        );
        break;
    }
  }

  /// Format message time
  /// Mesaj zamanını formatla
  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}