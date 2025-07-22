import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../../models/user_interaction_models.dart';
import '../../services/user_interactions_service.dart';
import '../../services/firebase_auth_service.dart';

/// Comment input widget for posting new comments and replies
/// Yeni yorum ve cevap gönderimi için yorum girişi widget'ı
class CommentInputWidget extends StatefulWidget {
  final String eventId;
  final EventComment? replyToComment;
  final Function()? onCommentAdded;
  final Function()? onCancel;
  final String? initialText;
  final bool autofocus;

  const CommentInputWidget({
    Key? key,
    required this.eventId,
    this.replyToComment,
    this.onCommentAdded,
    this.onCancel,
    this.initialText,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<CommentInputWidget> createState() => _CommentInputWidgetState();
}

class _CommentInputWidgetState extends State<CommentInputWidget>
    with TickerProviderStateMixin {
  final UserInteractionsService _interactionsService =
      UserInteractionsService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  // Controllers
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  // State management
  bool _isLoading = false;
  bool _isExpanded = false;
  int _characterCount = 0;
  static const int _maxCharacters = 500;

  // Animation controllers
  late AnimationController _expandAnimationController;
  late AnimationController _sendButtonController;
  late Animation<double> _expandAnimation;
  late Animation<double> _sendButtonAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
    _setupListeners();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _expandAnimationController.dispose();
    _sendButtonController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _textController = TextEditingController(text: widget.initialText ?? '');
    _characterCount = _textController.text.length;
  }

  void _setupAnimations() {
    _expandAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandAnimationController,
      curve: Curves.easeInOut,
    );
    _sendButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.elasticOut,
    ));
  }

  void _setupListeners() {
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _onTextChanged() {
    setState(() {
      _characterCount = _textController.text.length;
    });

    if (_textController.text.trim().isNotEmpty && !_isExpanded) {
      _expand();
    } else if (_textController.text.trim().isEmpty && _isExpanded) {
      _collapse();
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && !_isExpanded) {
      _expand();
    }
  }

  void _expand() {
    setState(() {
      _isExpanded = true;
    });
    _expandAnimationController.forward();
    _sendButtonController.forward();
  }

  void _collapse() {
    if (_textController.text.trim().isEmpty) {
      setState(() {
        _isExpanded = false;
      });
      _expandAnimationController.reverse();
      _sendButtonController.reverse();
    }
  }

  Future<void> _sendComment() async {
    final content = _textController.text.trim();
    if (content.isEmpty || _isLoading) return;

    if (!_authService.isAuthenticated) {
      _showErrorSnackBar('You must be logged in to comment');
      return;
    }

    if (content.length > _maxCharacters) {
      _showErrorSnackBar('Comment is too long');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      // Haptic feedback
      HapticFeedback.lightImpact();

      final commentId = await _interactionsService.addComment(
        widget.eventId,
        content,
        parentCommentId: widget.replyToComment?.commentId,
      );

      if (commentId != null) {
        // Success feedback
        HapticFeedback.mediumImpact();
        
        // Clear input
        _textController.clear();
        _collapse();
        
        // Unfocus keyboard
        _focusNode.unfocus();

        // Notify parent
        widget.onCommentAdded?.call();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.replyToComment != null
                    ? 'Reply posted successfully'
                    : 'Comment posted successfully',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to send comment: $e');
      _showErrorSnackBar('Failed to post comment. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _cancel() {
    _textController.clear();
    _focusNode.unfocus();
    _collapse();
    widget.onCancel?.call();
  }

  bool get _canSend {
    return _textController.text.trim().isNotEmpty &&
        _characterCount <= _maxCharacters &&
        !_isLoading;
  }

  Color get _characterCountColor {
    if (_characterCount > _maxCharacters) {
      return Colors.red;
    } else if (_characterCount > _maxCharacters * 0.8) {
      return Colors.orange;
    }
    return Theme.of(context).hintColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reply indicator
          if (widget.replyToComment != null) _buildReplyIndicator(),
          
          // Main input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // User avatar
              _buildUserAvatar(),
              const SizedBox(width: 12),
              
              // Input field
              Expanded(child: _buildInputField()),
              const SizedBox(width: 12),
              
              // Send button
              _buildSendButton(),
            ],
          ),
          
          // Expanded options
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _expandAnimation,
                child: _buildExpandedOptions(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReplyIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Replying to ${widget.replyToComment!.authorName}',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: _cancel,
            icon: Icon(
              Icons.close,
              size: 16,
              color: Theme.of(context).hintColor,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    final currentUser = _authService.currentAppUser;
    return CircleAvatar(
      radius: 18,
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      backgroundImage: currentUser?.profilePhotoUrl != null
          ? NetworkImage(currentUser!.profilePhotoUrl!)
          : null,
      child: currentUser?.profilePhotoUrl == null
          ? Text(
              currentUser?.displayName.isNotEmpty == true
                  ? currentUser!.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildInputField() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 40,
        maxHeight: 120,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _focusNode.hasFocus
              ? Theme.of(context).primaryColor.withOpacity(0.5)
              : Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        maxLines: null,
        maxLength: _maxCharacters,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText: widget.replyToComment != null
              ? 'Write a reply...'
              : 'Write a comment...',
          hintStyle: TextStyle(
            color: Theme.of(context).hintColor,
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          counterText: '',
        ),
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _sendButtonAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _sendButtonAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: _canSend
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).disabledColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _canSend ? _sendComment : null,
              icon: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.send,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      size: 20,
                    ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedOptions() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Character counter
          Text(
            '$_characterCount / $_maxCharacters',
            style: TextStyle(
              fontSize: 12,
              color: _characterCountColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.replyToComment != null || _isExpanded)
                TextButton(
                  onPressed: _cancel,
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).hintColor,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}