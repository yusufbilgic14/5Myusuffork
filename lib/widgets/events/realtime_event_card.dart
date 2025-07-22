import 'package:flutter/material.dart';
import 'dart:async';

import '../../constants/app_constants.dart';
import '../../themes/app_themes.dart';
import '../../models/user_event_models.dart';
import '../../models/user_interaction_models.dart';
import '../../services/user_events_service.dart';
import '../../services/user_interactions_service.dart';
import '../../l10n/app_localizations.dart';

/// Real-time event card that updates counters live
/// Sayaçları canlı güncelleyen gerçek zamanlı etkinlik kartı
class RealTimeEventCard extends StatefulWidget {
  final Event event;
  final Club? club;
  final VoidCallback? onLike;
  final VoidCallback? onJoin;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onMoreOptions;

  const RealTimeEventCard({
    super.key,
    required this.event,
    this.club,
    this.onLike,
    this.onJoin,
    this.onComment,
    this.onShare,
    this.onMoreOptions,
  });

  @override
  State<RealTimeEventCard> createState() => _RealTimeEventCardState();
}

class _RealTimeEventCardState extends State<RealTimeEventCard> {
  final UserEventsService _eventsService = UserEventsService();

  StreamSubscription<EventCounters>? _countersSubscription;
  StreamSubscription<UserEventInteraction?>? _interactionSubscription;

  EventCounters? _currentCounters;
  UserEventInteraction? _userInteraction;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _setupStreams();
  }

  @override
  void dispose() {
    _countersSubscription?.cancel();
    _interactionSubscription?.cancel();
    super.dispose();
  }

  void _setupStreams() {
    // Watch event counters
    _countersSubscription = _eventsService
        .watchEventCounters(widget.event.eventId)
        .listen(
          (counters) {
            if (mounted) {
              setState(() {
                _currentCounters = counters;
              });
            }
          },
          onError: (error) {
            debugPrint(
              '❌ RealTimeEventCard: Error listening to counters - $error',
            );
          },
        );

    // Watch user interaction
    _interactionSubscription = _eventsService
        .watchUserEventInteraction(widget.event.eventId)
        .listen(
          (interaction) {
            if (mounted) {
              setState(() {
                _userInteraction = interaction;
              });
            }
          },
          onError: (error) {
            debugPrint(
              '❌ RealTimeEventCard: Error listening to interaction - $error',
            );
          },
        );
  }

  bool get isLiked => _userInteraction?.hasLiked ?? false;
  bool get isJoined => _userInteraction?.hasJoined ?? false;
  bool get hasShared => _userInteraction?.hasShared ?? false;

  int get likeCount => _currentCounters?.likeCount ?? widget.event.likeCount;
  int get commentCount =>
      _currentCounters?.commentCount ?? widget.event.commentCount;
  int get joinCount => _currentCounters?.joinCount ?? widget.event.joinCount;
  int get shareCount => _currentCounters?.shareCount ?? widget.event.shareCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppThemes.getCardShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event header
          _buildEventHeader(context),

          // Event content
          _buildEventContent(context),

          // Real-time counters and actions
          _buildEventActions(context),
        ],
      ),
    );
  }

  /// Event header with club info
  Widget _buildEventHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Row(
        children: [
          // Club logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color:
                  widget.club?.colors.primaryColor.withValues(alpha: 0.1) ??
                  AppThemes.getPrimaryColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Center(
              child: widget.club?.logoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                      child: Image.network(
                        widget.club!.logoUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.group, size: 24);
                        },
                      ),
                    )
                  : const Icon(Icons.group, size: 24),
            ),
          ),

          const SizedBox(width: AppConstants.paddingMedium),

          // Club info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.club?.displayName ?? widget.event.organizerName,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeMedium,
                        fontWeight: FontWeight.w600,
                        color: AppThemes.getTextColor(context),
                      ),
                    ),
                    if (widget.club?.verificationStatus ==
                        VerificationStatus.verified) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: AppThemes.getPrimaryColor(context),
                      ),
                    ],
                  ],
                ),
                Text(
                  widget.event.createdAt != null
                      ? _formatPostTime(widget.event.createdAt!)
                      : 'Yeni',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppThemes.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),

          // More options
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: widget.onMoreOptions,
          ),
        ],
      ),
    );
  }

  /// Event content
  Widget _buildEventContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            widget.event.title,
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppThemes.getTextColor(context),
            ),
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // Description
          Text(
            widget.event.description,
            style: TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              color: AppThemes.getTextColor(context),
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          // Event image
          if (widget.event.imageUrl != null) _buildEventImage(context),

          // Event details
          _buildEventDetails(context),

          const SizedBox(height: AppConstants.paddingMedium),

          // Tags
          if (widget.event.tags.isNotEmpty) _buildEventTags(context),
        ],
      ),
    );
  }

  /// Event image
  Widget _buildEventImage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        child: Image.network(
          widget.event.imageUrl!,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Event details
  Widget _buildEventDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppThemes.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
      ),
      child: Column(
        children: [
          // Date and time
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 20,
                color: AppThemes.getPrimaryColor(context),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Text(
                _formatEventDate(context, widget.event.startDateTime),
                style: TextStyle(
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w500,
                  color: AppThemes.getTextColor(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: AppThemes.getPrimaryColor(context),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              Expanded(
                child: Text(
                  widget.event.location,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppThemes.getTextColor(context),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // Participant count with real-time updates
          Row(
            children: [
              Icon(
                Icons.people,
                size: 20,
                color: AppThemes.getPrimaryColor(context),
              ),
              const SizedBox(width: AppConstants.paddingSmall),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  widget.event.maxCapacity != null
                      ? '$joinCount/${widget.event.maxCapacity} katılımcı'
                      : '$joinCount katılımcı',
                  key: ValueKey(joinCount),
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeMedium,
                    color: AppThemes.getTextColor(context),
                  ),
                ),
              ),
              if (widget.event.maxCapacity != null) ...[
                const SizedBox(width: AppConstants.paddingSmall),
                Expanded(
                  child: LinearProgressIndicator(
                    value: joinCount / widget.event.maxCapacity!,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppThemes.getPrimaryColor(context),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Event tags
  Widget _buildEventTags(BuildContext context) {
    return Wrap(
      spacing: AppConstants.paddingSmall,
      runSpacing: AppConstants.paddingSmall,
      children: widget.event.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingSmall,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color:
                widget.club?.colors.primaryColor.withValues(alpha: 0.1) ??
                AppThemes.getPrimaryColor(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
          ),
          child: Text(
            '#$tag',
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              color:
                  widget.club?.colors.primaryColor ??
                  AppThemes.getPrimaryColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Event actions with real-time counters
  Widget _buildEventActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        children: [
          // Real-time statistics with animated counters
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '$likeCount beğeni',
                  key: ValueKey(likeCount),
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppThemes.getSecondaryTextColor(context),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '$commentCount yorum',
                  key: ValueKey(commentCount),
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    color: AppThemes.getSecondaryTextColor(context),
                  ),
                ),
              ),
              if (shareCount > 0) ...[
                const SizedBox(width: AppConstants.paddingMedium),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '$shareCount paylaşım',
                    key: ValueKey(shareCount),
                    style: TextStyle(
                      fontSize: AppConstants.fontSizeSmall,
                      color: AppThemes.getSecondaryTextColor(context),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: AppConstants.paddingSmall),
          const Divider(height: 1),
          const SizedBox(height: AppConstants.paddingSmall),

          // Action buttons
          Row(
            children: [
              // Like button with loading state
              Expanded(
                child: TextButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() => _isLoading = true);
                          try {
                            widget.onLike?.call();
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isLiked),
                      color: isLiked
                          ? Colors.red
                          : AppThemes.getSecondaryTextColor(context),
                    ),
                  ),
                  label: Text(
                    'Beğen',
                    style: TextStyle(
                      color: isLiked
                          ? Colors.red
                          : AppThemes.getSecondaryTextColor(context),
                    ),
                  ),
                ),
              ),

              // Comment button
              Expanded(
                child: TextButton.icon(
                  onPressed: widget.onComment,
                  icon: Icon(
                    Icons.comment_outlined,
                    color: AppThemes.getSecondaryTextColor(context),
                  ),
                  label: Text(
                    'Yorum',
                    style: TextStyle(
                      color: AppThemes.getSecondaryTextColor(context),
                    ),
                  ),
                ),
              ),

              // Join button with loading state
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _isLoading ||
                          (widget.event.maxCapacity != null &&
                              joinCount >= widget.event.maxCapacity!)
                      ? null
                      : () {
                          setState(() => _isLoading = true);
                          try {
                            widget.onJoin?.call();
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isJoined ? Icons.check : Icons.add,
                      key: ValueKey(isJoined),
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  label: Text(
                    isJoined ? 'Katıldım' : 'Katıl',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isJoined
                        ? Colors.green[600]
                        : AppThemes.getPrimaryColor(context),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper methods

  String _formatEventDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Bugün, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yarın, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      final days = [
        AppLocalizations.of(context)!.monday,
        AppLocalizations.of(context)!.tuesday,
        AppLocalizations.of(context)!.wednesday,
        AppLocalizations.of(context)!.thursday,
        AppLocalizations.of(context)!.friday,
        AppLocalizations.of(context)!.saturday,
        AppLocalizations.of(context)!.sunday,
      ];
      return '${days[date.weekday - 1]}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatPostTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

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
