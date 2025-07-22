import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../models/user_interaction_models.dart';
import '../../services/user_interactions_service.dart';
import '../../services/firebase_auth_service.dart';

/// Single comment item widget with likes and replies
/// Tek yorum öğesi widget'ı - beğeniler ve cevaplar ile
class EventCommentItem extends StatefulWidget {
  final EventComment comment;
  final String eventId;
  final Function(EventComment)? onReply;
  final Function(EventComment)? onEdit;
  final Function(EventComment)? onDelete;
  final bool showReplies;
  final bool isReply;
  final int maxLines;

  const EventCommentItem({
    Key? key,
    required this.comment,
    required this.eventId,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.showReplies = true,
    this.isReply = false,
    this.maxLines = 5,
  }) : super(key: key);

  @override
  State<EventCommentItem> createState() => _EventCommentItemState();
}

class _EventCommentItemState extends State<EventCommentItem>
    with SingleTickerProviderStateMixin {
  final UserInteractionsService _interactionsService =
      UserInteractionsService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  // State management
  bool _isLiked = false;
  int _likeCount = 0;
  bool _isLoading = false;
  bool _showFullText = false;
  bool _showReplies = false;
  List<EventComment> _replies = [];

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Stream subscriptions
  StreamSubscription? _likeStatusSubscription;
  StreamSubscription? _likeCountSubscription;
  StreamSubscription? _repliesSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCommentData();
    _setupRealTimeListeners();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _likeStatusSubscription?.cancel();
    _likeCountSubscription?.cancel();
    _repliesSubscription?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  void _initializeCommentData() {
    _likeCount = widget.comment.likeCount;
  }

  void _setupRealTimeListeners() {
    // Listen to like status changes
    _likeStatusSubscription = _interactionsService
        .watchUserCommentLikeStatus(
          widget.eventId,
          widget.comment.commentId,
        )
        .listen((isLiked) {
      if (mounted) {
        setState(() {
          _isLiked = isLiked;
        });
      }
    });

    // Listen to like count changes
    _likeCountSubscription = _interactionsService
        .watchCommentLikeCount(widget.eventId, widget.comment.commentId)
        .listen((count) {
      if (mounted) {
        setState(() {
          _likeCount = count;
        });
      }
    });

    // Listen to replies if this is a top-level comment
    if (widget.comment.isTopLevel && widget.showReplies) {
      _repliesSubscription = _interactionsService
          .watchCommentReplies(widget.eventId, widget.comment.commentId)
          .listen((replies) {
        if (mounted) {
          setState(() {
            _replies = replies;
          });
        }
      });
    }
  }

  Future<void> _toggleLike() async {
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Animate like button
      if (!_isLiked) {
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      }

      await _interactionsService.toggleCommentLike(
        widget.eventId,
        widget.comment.commentId,
      );
    } catch (e) {
      debugPrint('❌ Failed to toggle comment like: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to ${_isLiked ? 'unlike' : 'like'} comment'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _toggleReplies() {
    setState(() {
      _showReplies = !_showReplies;
    });
  }

  void _toggleFullText() {
    setState(() {
      _showFullText = !_showFullText;
    });
  }

  bool get _isOwnComment {
    final currentUserId = _authService.currentAppUser?.id;
    return currentUserId == widget.comment.authorId;
  }

  bool get _shouldTruncateText {
    return widget.comment.content.length > 200 && !_showFullText;
  }

  String get _displayText {
    if (_shouldTruncateText) {
      return '${widget.comment.content.substring(0, 200)}...';
    }
    return widget.comment.content;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: widget.isReply ? 40.0 : 0.0,
        bottom: 12.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCommentHeader(),
          const SizedBox(height: 8),
          _buildCommentContent(),
          const SizedBox(height: 8),
          _buildCommentActions(),
          if (widget.comment.isTopLevel && _replies.isNotEmpty && _showReplies)
            _buildRepliesSection(),
        ],
      ),
    );
  }

  Widget _buildCommentHeader() {
    return Row(
      children: [
        // Author avatar
        CircleAvatar(
          radius: widget.isReply ? 16 : 20,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          backgroundImage: widget.comment.authorAvatar != null
              ? NetworkImage(widget.comment.authorAvatar!)
              : null,
          child: widget.comment.authorAvatar == null
              ? Text(
                  widget.comment.authorName.isNotEmpty
                      ? widget.comment.authorName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: widget.isReply ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12),
        // Author info and timestamp
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.comment.authorName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: widget.isReply ? 14 : 15,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (widget.comment.isEdited) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.edit,
                      size: 12,
                      color: Theme.of(context).hintColor,
                    ),
                    Text(
                      ' edited',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                widget.comment.getTimeAgo(),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
        // More options menu
        if (_isOwnComment)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: 20,
              color: Theme.of(context).hintColor,
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  widget.onEdit?.call(widget.comment);
                  break;
                case 'delete':
                  widget.onDelete?.call(widget.comment);
                  break;
              }
            },
          ),
      ],
    );
  }

  Widget _buildCommentContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _displayText,
          style: TextStyle(
            fontSize: widget.isReply ? 14 : 15,
            height: 1.4,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        if (_shouldTruncateText)
          GestureDetector(
            onTap: _toggleFullText,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Show more',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        if (_showFullText && widget.comment.content.length > 200)
          GestureDetector(
            onTap: _toggleFullText,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Show less',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        // Media content if available
        if (widget.comment.hasMedia) _buildMediaContent(),
      ],
    );
  }

  Widget _buildMediaContent() {
    if (widget.comment.mediaUrls?.isEmpty ?? true) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.comment.mediaUrls!
            .map((url) => _buildMediaItem(url))
            .toList(),
      ),
    );
  }

  Widget _buildMediaItem(String url) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Theme.of(context).hintColor.withOpacity(0.1),
              child: const Icon(Icons.broken_image),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCommentActions() {
    return Row(
      children: [
        // Like button
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: InkWell(
                onTap: _toggleLike,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: _isLiked
                            ? Colors.red
                            : Theme.of(context).hintColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _likeCount.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _isLiked
                              ? Colors.red
                              : Theme.of(context).hintColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 16),
        // Reply button
        if (!widget.isReply && widget.onReply != null)
          InkWell(
            onTap: () => widget.onReply?.call(widget.comment),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.reply,
                    size: 16,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reply',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Show replies button
        if (widget.comment.isTopLevel && widget.comment.replyCount > 0) ...[
          const SizedBox(width: 16),
          InkWell(
            onTap: _toggleReplies,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showReplies
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: Theme.of(context).hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.comment.replyCount} ${widget.comment.replyCount == 1 ? 'reply' : 'replies'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRepliesSection() {
    if (_replies.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: _replies
            .map((reply) => EventCommentItem(
                  comment: reply,
                  eventId: widget.eventId,
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                  isReply: true,
                  showReplies: false,
                ))
            .toList(),
      ),
    );
  }
}