import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../../models/user_interaction_models.dart';
import '../../services/user_interactions_service.dart';
import 'event_comment_item.dart';
import 'comment_input_widget.dart';

/// Comments list widget with real-time updates
/// Gerçek zamanlı güncellemeler ile yorumlar listesi widget'ı
class EventCommentsList extends StatefulWidget {
  final String eventId;
  final bool showInput;
  final int maxHeight;
  final bool autoScroll;

  const EventCommentsList({
    Key? key,
    required this.eventId,
    this.showInput = true,
    this.maxHeight = 600,
    this.autoScroll = true,
  }) : super(key: key);

  @override
  State<EventCommentsList> createState() => _EventCommentsListState();
}

class _EventCommentsListState extends State<EventCommentsList>
    with TickerProviderStateMixin {
  final UserInteractionsService _interactionsService =
      UserInteractionsService();

  // Controllers
  final ScrollController _scrollController = ScrollController();

  // State management
  List<EventComment> _comments = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  EventComment? _replyToComment;
  EventComment? _editComment;
  bool _isRefreshing = false;

  // Animation controllers
  late AnimationController _listAnimationController;
  late AnimationController _errorAnimationController;
  late Animation<double> _listAnimation;
  late Animation<Offset> _errorSlideAnimation;

  // Stream subscription
  StreamSubscription? _commentsSubscription;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadComments();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _listAnimationController.dispose();
    _errorAnimationController.dispose();
    _commentsSubscription?.cancel();
    super.dispose();
  }

  void _setupAnimations() {
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _errorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _listAnimation = CurvedAnimation(
      parent: _listAnimationController,
      curve: Curves.easeOutCubic,
    );
    _errorSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _errorAnimationController,
      curve: Curves.easeOut,
    ));
  }

  void _loadComments() {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      // Start listening to real-time comments
      _commentsSubscription?.cancel();
      _commentsSubscription = _interactionsService
          .watchEventComments(widget.eventId)
          .listen(
            _onCommentsUpdated,
            onError: _onCommentsError,
          );
    } catch (e) {
      _onCommentsError(e);
    }
  }

  void _onCommentsUpdated(List<EventComment> comments) {
    if (!mounted) return;

    final previousCount = _comments.length;
    
    setState(() {
      _comments = comments;
      _isLoading = false;
      _hasError = false;
      _errorMessage = null;
    });

    // Animate list entrance
    if (previousCount == 0 && comments.isNotEmpty) {
      _listAnimationController.forward();
    }

    // Auto-scroll to bottom if new comments are added
    if (widget.autoScroll && 
        comments.length > previousCount && 
        _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _onCommentsError(dynamic error) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _hasError = true;
      _errorMessage = error.toString();
    });

    _errorAnimationController.forward();
    
    debugPrint('❌ Comments loading error: $error');
  }

  Future<void> _refreshComments() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Add haptic feedback
      HapticFeedback.lightImpact();
      
      // Reload comments by restarting the stream
      _loadComments();
      
      // Simulate minimum refresh time for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onReply(EventComment comment) {
    setState(() {
      _replyToComment = comment;
      _editComment = null;
    });
  }

  void _onEdit(EventComment comment) {
    setState(() {
      _editComment = comment;
      _replyToComment = null;
    });
    _showEditDialog(comment);
  }

  void _onDelete(EventComment comment) {
    _showDeleteConfirmDialog(comment);
  }

  Future<void> _showEditDialog(EventComment comment) async {
    final controller = TextEditingController(text: comment.content);
    
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(
          controller: controller,
          maxLines: null,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Edit your comment...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newContent = controller.text.trim();
              if (newContent.isNotEmpty && newContent != comment.content) {
                try {
                  await _interactionsService.editComment(
                    widget.eventId,
                    comment.commentId,
                    newContent,
                  );
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comment updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update comment: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(EventComment comment) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text(
          'Are you sure you want to delete this comment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _interactionsService.deleteComment(
                  widget.eventId,
                  comment.commentId,
                );
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comment deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete comment: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _onCommentAdded() {
    setState(() {
      _replyToComment = null;
      _editComment = null;
    });
    
    // Scroll to bottom to show new comment
    if (widget.autoScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _onCancelReply() {
    setState(() {
      _replyToComment = null;
      _editComment = null;
    });
  }

  int get _topLevelCommentsCount {
    return _comments.where((comment) => comment.isTopLevel).length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: widget.maxHeight.toDouble()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          if (_hasError) _buildErrorWidget(),
          Expanded(child: _buildCommentsList()),
          if (widget.showInput) _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.comment,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            'Comments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _topLevelCommentsCount.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const Spacer(),
          // Scroll controls
          if (_comments.isNotEmpty) ...[
            IconButton(
              onPressed: _scrollToTop,
              icon: Icon(
                Icons.keyboard_arrow_up,
                color: Theme.of(context).hintColor,
              ),
              tooltip: 'Scroll to top',
            ),
            IconButton(
              onPressed: _scrollToBottom,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).hintColor,
              ),
              tooltip: 'Scroll to bottom',
            ),
          ],
          // Refresh button
          IconButton(
            onPressed: _isRefreshing ? null : _refreshComments,
            icon: _isRefreshing
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : Icon(
                    Icons.refresh,
                    color: Theme.of(context).hintColor,
                  ),
            tooltip: 'Refresh comments',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return SlideTransition(
      position: _errorSlideAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Colors.red.withOpacity(0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to load comments',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                ),
              ),
            ],
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadComments,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_comments.isEmpty && !_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.comment,
                size: 48,
                color: Theme.of(context).hintColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No comments yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).hintColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to comment on this event!',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _listAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(_listAnimation),
            child: child,
          ),
        );
      },
      child: RefreshIndicator(
        onRefresh: _refreshComments,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: _topLevelCommentsCount,
          itemBuilder: (context, index) {
            final topLevelComments = _comments
                .where((comment) => comment.isTopLevel)
                .toList();
            
            if (index >= topLevelComments.length) {
              return const SizedBox();
            }
            
            final comment = topLevelComments[index];
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: EventCommentItem(
                comment: comment,
                eventId: widget.eventId,
                onReply: _onReply,
                onEdit: _onEdit,
                onDelete: _onDelete,
                showReplies: true,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return CommentInputWidget(
      eventId: widget.eventId,
      replyToComment: _replyToComment,
      onCommentAdded: _onCommentAdded,
      onCancel: _onCancelReply,
      autofocus: _replyToComment != null,
    );
  }
}