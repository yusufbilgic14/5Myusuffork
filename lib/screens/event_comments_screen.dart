import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_event_models.dart';
import '../widgets/events/event_comments_list.dart';
import '../services/user_interactions_service.dart';

/// Full screen for event comments
/// Etkinlik yorumları için tam ekran
class EventCommentsScreen extends StatefulWidget {
  final Event event;
  final bool showEventInfo;

  const EventCommentsScreen({
    Key? key,
    required this.event,
    this.showEventInfo = true,
  }) : super(key: key);

  /// Show comments as a modal bottom sheet
  static Future<void> showCommentsModal(
    BuildContext context,
    Event event,
  ) async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: EventCommentsScreen(
            event: event,
            showEventInfo: true,
          ),
        ),
      ),
    );
  }

  /// Navigate to full comments screen
  static Future<void> navigateToCommentsScreen(
    BuildContext context,
    Event event,
  ) async {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => EventCommentsScreen(
          event: event,
          showEventInfo: false,
        ),
      ),
    );
  }

  @override
  State<EventCommentsScreen> createState() => _EventCommentsScreenState();
}

class _EventCommentsScreenState extends State<EventCommentsScreen>
    with TickerProviderStateMixin {
  final UserInteractionsService _interactionsService =
      UserInteractionsService();

  // State management
  int _commentCount = 0;
  bool _isLoadingStats = true;

  // Animation controllers
  late AnimationController _headerAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadCommentStats();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _headerFadeAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOut,
    );

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animation
    _headerAnimationController.forward();
  }

  Future<void> _loadCommentStats() async {
    try {
      final stats = await _interactionsService
          .getCommentStatistics(widget.event.eventId);
      
      if (mounted) {
        setState(() {
          _commentCount = stats.totalComments;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Failed to load comment stats: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Custom app bar or drag handle
          if (widget.showEventInfo) 
            _buildDragHandle() 
          else 
            _buildAppBar(),
          
          // Event info section
          if (widget.showEventInfo) _buildEventInfoSection(),
          
          // Comments list
          Expanded(
            child: EventCommentsList(
              eventId: widget.event.eventId,
              showInput: true,
              autoScroll: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      title: const Text('Comments'),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        // Comment count
        if (!_isLoadingStats)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$_commentCount',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEventInfoSection() {
    return AnimatedBuilder(
      animation: _headerFadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _headerFadeAnimation,
          child: SlideTransition(
            position: _headerSlideAnimation,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event title and info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: widget.event.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.event.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildEventImagePlaceholder();
                            },
                          ),
                        )
                      : _buildEventImagePlaceholder(),
                ),
                const SizedBox(width: 12),
                // Event details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.group,
                            size: 14,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.event.organizerName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Theme.of(context).hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.event.getFormattedDate(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Engagement stats
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatChip(
                  Icons.favorite,
                  widget.event.likeCount.toString(),
                  Colors.red,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  Icons.group_add,
                  widget.event.joinCount.toString(),
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  Icons.comment,
                  _isLoadingStats ? '...' : _commentCount.toString(),
                  Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  Icons.share,
                  widget.event.shareCount.toString(),
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.event,
        color: Theme.of(context).primaryColor,
        size: 24,
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}