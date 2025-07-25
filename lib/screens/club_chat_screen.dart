import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';

import '../themes/app_themes.dart';
import '../models/club_chat_models.dart';
import '../models/user_interaction_models.dart';
import '../services/club_chat_service.dart';
import '../services/firebase_auth_service.dart';
import 'club_overview_screen.dart';
import '../widgets/chat/media_picker_widget.dart';
import '../widgets/chat/media_preview_widget.dart';
import '../widgets/chat/message_reactions_widget.dart';
import '../widgets/chat/pinned_messages_widget.dart';
import '../widgets/chat/user_presence_widget.dart';

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
  
  // New feature state variables
  List<File> _selectedImages = [];
  File? _selectedDocument;
  String? _selectedDocumentName;
  bool _isPinnedCollapsed = true;
  bool _isTyping = false;
  Timer? _typingTimer;

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
    _typingTimer?.cancel();
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
        final bool isFirstLoad = _messages.isEmpty && messages.isNotEmpty;
        final int previousMessageCount = _messages.length;
        
        setState(() {
          _messages = messages;
        });
        
        if (isFirstLoad) {
          // Scroll to bottom after first message load
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom(animated: false);
          });
        } else if (messages.length > previousMessageCount) {
          // New messages arrived - scroll if user is near the bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              final maxScroll = _scrollController.position.maxScrollExtent;
              final currentScroll = _scrollController.offset;
              // If user is within 100 pixels of bottom, auto-scroll to new messages
              if (maxScroll - currentScroll < 100) {
                _scrollToBottom(animated: true);
              }
            }
          });
        }
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


  /// Handle media selection
  /// Medya seçimini yönet
  void _showMediaPicker() {
    debugPrint('📱 ClubChatScreen: Showing media picker...');
    showModalBottomSheet(
      context: context,
      backgroundColor: AppThemes.getSurfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => MediaPickerWidget(
        onImagesSelected: (images) {
          debugPrint('📷 ClubChatScreen: Received ${images.length} images from MediaPicker');
          for (int i = 0; i < images.length; i++) {
            debugPrint('📷 ClubChatScreen: Image $i: ${images[i].path}');
          }
          setState(() {
            _selectedImages.addAll(images);
          });
          debugPrint('📷 ClubChatScreen: Total selected images now: ${_selectedImages.length}');
          debugPrint('📱 ClubChatScreen: Staying on chat screen - MediaPickerWidget handles navigation');
          // Note: MediaPickerWidget already calls Navigator.pop() internally
        },
        onDocumentSelected: (document, fileName) {
          setState(() {
            _selectedDocument = document;
            _selectedDocumentName = fileName;
          });
          // Note: MediaPickerWidget already calls Navigator.pop() internally
        },
        onVoiceSelected: (voiceFile) {
          // Note: MediaPickerWidget already calls Navigator.pop() internally
          _showErrorSnackBar('Voice messages coming soon');
        },
      ),
    );
  }

  /// Remove selected media
  /// Seçili medyayı kaldır
  void _removeSelectedMedia(int index) {
    setState(() {
      if (index < _selectedImages.length) {
        _selectedImages.removeAt(index);
      }
    });
  }

  /// Clear all selected media
  /// Tüm seçili medyayı temizle
  void _clearSelectedMedia() {
    setState(() {
      _selectedImages.clear();
      _selectedDocument = null;
      _selectedDocumentName = null;
    });
  }


  /// Scroll to bottom of chat (newest messages)
  /// Sohbetin altına kaydır (en yeni mesajlar)
  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    // Scroll to bottom to show newest messages
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
    final hasMedia = _selectedImages.isNotEmpty || _selectedDocument != null;
    
    debugPrint('💬 ClubChatScreen: _sendMessage called - content: "$content", hasMedia: $hasMedia, selectedImages: ${_selectedImages.length}');
    
    if (content.isEmpty && !hasMedia) return;
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      List<MediaAttachment>? mediaAttachments;
      
      // Upload media if selected
      if (hasMedia) {
        mediaAttachments = [];
        
        // Upload images
        for (final image in _selectedImages) {
          final attachment = await _chatService.uploadMediaFile(
            file: image,
            clubId: widget.club.clubId,
            messageId: DateTime.now().millisecondsSinceEpoch.toString(),
            fileType: 'image',
          );
          if (attachment != null) {
            mediaAttachments.add(attachment);
          }
        }
        
        // Upload document
        if (_selectedDocument != null) {
          final attachment = await _chatService.uploadMediaFile(
            file: _selectedDocument!,
            clubId: widget.club.clubId,
            messageId: DateTime.now().millisecondsSinceEpoch.toString(),
            fileType: 'document',
            originalFileName: _selectedDocumentName,
          );
          if (attachment != null) {
            mediaAttachments.add(attachment);
          }
        }
      }

      final success = await _chatService.sendMessage(
        clubId: widget.club.clubId,
        content: content.isNotEmpty ? content : '[Media message]',
        mediaUrls: mediaAttachments?.map((a) => a.fileUrl).toList(),
        mediaAttachments: mediaAttachments,
        replyToMessageId: _replyToMessage?.messageId,
        replyToContent: _replyToMessage?.content,
        replyToSenderName: _replyToMessage?.senderName,
      );

      if (success) {
        _messageController.clear();
        _clearReply();
        _clearSelectedMedia();
        _scrollToBottom();
        
        // Stop typing indicator
        if (_isTyping) {
          setState(() {
            _isTyping = false;
          });
          _chatService.updateTypingStatus(clubId: widget.club.clubId, isTyping: false);
        }
        
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

            // React to message
            ListTile(
              leading: const Icon(Icons.emoji_emotions),
              title: const Text('React'),
              onTap: () {
                Navigator.pop(context);
                _showReactionPicker(message);
              },
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

            // Pin/Unpin message (admin only)
            if (_canUserPin())
              ListTile(
                leading: Icon(
                  message.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  color: message.isPinned ? Colors.orange : null,
                ),
                title: Text(message.isPinned ? 'Unpin' : 'Pin'),
                onTap: () {
                  Navigator.pop(context);
                  _toggleMessagePin(message);
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
              value: 'club_overview',
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Club Overview'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
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
        // Pinned messages
        PinnedMessagesWidget(
          clubId: widget.club.clubId,
          isCollapsed: _isPinnedCollapsed,
          onToggleCollapse: () {
            setState(() {
              _isPinnedCollapsed = !_isPinnedCollapsed;
            });
          },
          onMessageTap: (message) {
            // TODO: Scroll to message
          },
        ),
        
        // User presence indicator
        UserPresenceWidget(
          clubId: widget.club.clubId,
        ),
        
        // Messages list
        Expanded(
          child: _buildMessagesList(),
        ),
        
        // Media preview
        if (_selectedImages.isNotEmpty || _selectedDocument != null)
          MediaPreviewWidget(
            localFiles: _selectedImages,
            showDeleteButton: true,
            onDeletePressed: (index) => _removeSelectedMedia(index),
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
                    // Pinned indicator
                    if (message.isPinned)
                      Row(
                        children: [
                          Icon(
                            Icons.push_pin,
                            size: 12,
                            color: isOwnMessage ? Colors.white70 : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pinned',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isOwnMessage ? Colors.white70 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    
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
                    
                    // Media attachments
                    if (message.mediaAttachments != null && message.mediaAttachments!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: MediaPreviewWidget(
                          mediaAttachments: message.mediaAttachments!,
                          showDeleteButton: false,
                        ),
                      ),
                    
                    // Message content
                    if (message.content.isNotEmpty && message.content != '[Media message]')
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 16,
                          color: isOwnMessage ? Colors.white : Colors.black87,
                        ),
                      ),
                    
                    // Message reactions
                    if (message.reactions != null && message.reactions!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: MessageReactionsWidget(
                          message: message,
                          currentUserId: _authService.currentAppUser?.id ?? '',
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
          // Media picker button
          IconButton(
            onPressed: _showMediaPicker,
            icon: Icon(
              Icons.add,
              color: AppThemes.getPrimaryColor(context),
            ),
          ),
          
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _messageFocusNode,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: (_selectedImages.isNotEmpty || _selectedDocument != null) 
                    ? 'Add a caption or send media...' 
                    : 'Type a message...',
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
              onChanged: _handleTypingIndicator,
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
                  : Icon(
                      (_selectedImages.isNotEmpty || _selectedDocument != null) 
                          ? Icons.photo_camera 
                          : Icons.send,
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
      case 'club_overview':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClubOverviewScreen(club: widget.club),
          ),
        );
        break;
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


  /// Handle typing indicator
  /// Yazma göstergesini işle
  void _handleTypingIndicator(String text) {
    if (_typingTimer?.isActive == true) {
      _typingTimer!.cancel();
    }

    if (text.isNotEmpty) {
      // User is typing - simplified implementation
      debugPrint('User is typing in ${widget.club.clubId}');

      _typingTimer = Timer(const Duration(seconds: 2), () {
        debugPrint('User stopped typing in ${widget.club.clubId}');
      });
    } else {
      debugPrint('User cleared input in ${widget.club.clubId}');
    }
  }

  /// Handle reaction tap
  /// Reaksiyon dokunuşunu işle
  void _handleReactionTap(ChatMessage message, String emoji) async {
    final success = await _chatService.addReaction(
      messageId: message.messageId,
      emoji: emoji,
    );
    
    if (!success) {
      _showErrorSnackBar('Failed to add reaction');
    }
  }

  /// Show reaction picker
  /// Reaksiyon seçiciyi göster
  void _showReactionPicker(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppThemes.getSurfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'React to message',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                children: ['👍', '❤️', '😂', '😮', '😢', '😡'].map((emoji) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _handleReactionTap(message, emoji);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Toggle message pin
  /// Mesaj sabitlemesini değiştir
  void _toggleMessagePin(ChatMessage message) async {
    final success = await _chatService.toggleMessagePin(
      clubId: widget.club.clubId,
      messageId: message.messageId,
    );
    
    if (!success) {
      _showErrorSnackBar('Failed to ${message.isPinned ? 'unpin' : 'pin'} message');
    }
  }

  /// Check if user can pin messages
  /// Kullanıcının mesaj sabitleyip sabitleyemeyeceğini kontrol et
  bool _canUserPin() {
    final currentUser = _authService.currentAppUser;
    if (currentUser == null) return false;
    
    final participant = _participants.firstWhere(
      (p) => p.userId == currentUser.id,
      orElse: () => ChatParticipant(
        chatRoomId: widget.club.clubId,
        clubId: widget.club.clubId,
        participantId: '',
        userId: '',
        userName: '',
        userAvatar: null,
        role: 'member',
        joinedAt: DateTime.now(),
      ),
    );
    
    return participant.role == 'creator' || participant.role == 'admin';
  }
}