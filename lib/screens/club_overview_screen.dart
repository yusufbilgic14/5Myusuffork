import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../themes/app_themes.dart';
import '../models/user_interaction_models.dart';
import '../models/club_chat_models.dart';
import '../services/user_club_following_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/club_chat_service.dart';
import '../l10n/app_localizations.dart';
import 'club_chat_screen.dart';
import 'dart:async';

/// Comprehensive club overview screen with professional layout
/// Profesyonel düzen ile kapsamlı kulüp genel bakış ekranı
class ClubOverviewScreen extends StatefulWidget {
  final Club club;

  const ClubOverviewScreen({
    super.key,
    required this.club,
  });

  @override
  State<ClubOverviewScreen> createState() => _ClubOverviewScreenState();
}

class _ClubOverviewScreenState extends State<ClubOverviewScreen> {
  final UserClubFollowingService _clubService = UserClubFollowingService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  final ClubChatService _chatService = ClubChatService();

  bool _isFollowing = false;
  bool _isLoading = true;
  bool _isFollowLoading = false;
  bool _hasChatAccess = false;
  bool _chatAccessLoading = true;
  List<PendingApproval> _pendingApprovals = [];
  StreamSubscription<List<PendingApproval>>? _approvalsSubscription;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
    _checkChatAccess();
    if (isCreator) {
      _setupApprovalsStream();
    }
  }

  @override
  void dispose() {
    _approvalsSubscription?.cancel();
    super.dispose();
  }

  /// Check if current user has chat access
  /// Mevcut kullanıcının sohbet erişimi olup olmadığını kontrol et
  Future<void> _checkChatAccess() async {
    try {
      final hasAccess = await _chatService.checkChatAccess(widget.club.clubId);
      if (mounted) {
        setState(() {
          _hasChatAccess = hasAccess;
          _chatAccessLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ ClubOverviewScreen: Error checking chat access: $e');
      if (mounted) {
        setState(() {
          _hasChatAccess = false;
          _chatAccessLoading = false;
        });
      }
    }
  }

  /// Setup stream for pending approvals (creator only)
  /// Bekleyen onaylar için akış kurulumu (sadece oluşturucu)
  void _setupApprovalsStream() {
    _approvalsSubscription = _chatService
        .streamPendingApprovals(widget.club.clubId)
        .listen(
      (approvals) {
        if (mounted) {
          setState(() {
            _pendingApprovals = approvals;
          });
        }
      },
      onError: (error) {
        debugPrint('❌ ClubOverviewScreen: Error listening to approvals: $error');
      },
    );
  }

  /// Check if current user is following this club
  /// Mevcut kullanıcının bu kulübü takip edip etmediğini kontrol et
  Future<void> _checkFollowStatus() async {
    try {
      final isFollowing = await _clubService.isFollowingClub(widget.club.clubId);
      if (mounted) {
        setState(() {
          _isFollowing = isFollowing;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ ClubOverviewScreen: Failed to check follow status - $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Check if current user is the creator of this club
  /// Mevcut kullanıcının bu kulübün kurucusu olup olmadığını kontrol et
  bool get isCreator {
    final currentUserId = _authService.currentAppUser?.id;
    return currentUserId != null && currentUserId == widget.club.createdBy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          // App bar with banner image
          _buildSliverAppBar(context),
          
          // Club content
          SliverToBoxAdapter(
            child: _buildClubContent(context),
          ),
        ],
      ),
      floatingActionButton: _buildChatButton(context),
    );
  }

  /// Build chat floating action button (for approved members)
  /// Sohbet floating action buton oluştur (onaylı üyeler için)
  Widget? _buildChatButton(BuildContext context) {
    // Don't show chat button while loading
    if (_chatAccessLoading) return null;
    
    // Show chat button if user has access (creator always has access)
    if (isCreator || _hasChatAccess) {
      return FloatingActionButton(
        onPressed: () => _openChat(context),
        backgroundColor: AppThemes.getPrimaryColor(context),
        foregroundColor: Colors.white,
        child: const Icon(Icons.chat),
        heroTag: 'club_chat_fab',
      );
    }
    
    // Show request access button if user is following but doesn't have chat access
    if (_isFollowing && !_hasChatAccess) {
      return FloatingActionButton.extended(
        onPressed: () => _requestChatAccess(context),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('Request Chat'),
        heroTag: 'request_chat_fab',
      );
    }
    
    return null;
  }

  /// Open chat screen
  /// Sohbet ekranını aç
  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubChatScreen(club: widget.club),
      ),
    );
  }

  /// Request chat access
  /// Sohbet erişimi talep et
  Future<void> _requestChatAccess(BuildContext context) async {
    // Show dialog to get optional message
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Request Chat Access'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.contactDesc.isNotEmpty ? 'Your request will be sent to the club creator for approval.' : 'Your request will be sent to the club creator for approval.',
                style: TextStyle(
                  color: AppThemes.getSecondaryTextColor(context),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Optional message (e.g., why you want to join)...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );
    
    if (result != null) {
      // Send the request
      final success = await _chatService.requestChatAccess(
        clubId: widget.club.clubId,
        requestMessage: result.isEmpty ? null : result,
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chat access request sent!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send request. You may have already requested.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// Build sliver app bar with banner image and logo
  /// Banner görseli ve logo ile sliver app bar oluştur
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppThemes.getPrimaryColor(context),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // Creator options (edit/delete)
        if (isCreator) ...[
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _editClub(context),
            tooltip: 'Kulübü Düzenle',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteConfirmation(context);
                  break;
                case 'settings':
                  _showClubSettings(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(Icons.settings),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.settings),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ] else ...[
          // Share button for non-creators
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareClub(context),
            tooltip: AppLocalizations.of(context)!.share,
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Banner image
            widget.club.bannerUrl != null
                ? Image.network(
                    widget.club.bannerUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultBanner(context);
                    },
                  )
                : _buildDefaultBanner(context),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),

            // Club logo positioned at bottom
            Positioned(
              bottom: 20,
              left: 20,
              child: _buildClubLogo(context),
            ),

            // Club basic info positioned at bottom right
            Positioned(
              bottom: 30,
              right: 20,
              left: 140, // Leave space for logo
              child: _buildBasicInfo(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Build default banner with club colors
  /// Kulüp renkleri ile varsayılan banner oluştur
  Widget _buildDefaultBanner(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.club.colors.primaryColor,
            widget.club.colors.primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups,
              size: 64,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              widget.club.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build club logo with border
  /// Kenarlıklı kulüp logosu oluştur
  Widget _buildClubLogo(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium - 4),
        child: widget.club.logoUrl != null
            ? Image.network(
                widget.club.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultLogo();
                },
              )
            : _buildDefaultLogo(),
      ),
    );
  }

  /// Build default logo
  /// Varsayılan logo oluştur
  Widget _buildDefaultLogo() {
    return Container(
      color: widget.club.colors.primaryColor.withValues(alpha: 0.1),
      child: Center(
        child: Text(
          widget.club.displayName.isNotEmpty 
              ? widget.club.displayName[0].toUpperCase()
              : 'K',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: widget.club.colors.primaryColor,
          ),
        ),
      ),
    );
  }

  /// Build basic club info overlay
  /// Temel kulüp bilgileri yer paylaşımı oluştur
  Widget _buildBasicInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Club name
        Row(
          children: [
            Flexible(
              child: Text(
                widget.club.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.club.verificationStatus == VerificationStatus.verified) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.verified,
                color: Colors.white,
                size: 20,
              ),
            ],
          ],
        ),
        
        const SizedBox(height: 4),
        
        // Follower count
        Text(
          '${widget.club.followerCount} ${AppLocalizations.of(context)!.members}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Follow/Unfollow button
        _buildFollowButton(context),
      ],
    );
  }

  /// Build follow/unfollow button
  /// Takip et/takibi bırak butonu oluştur
  Widget _buildFollowButton(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 100,
        height: 36,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: _isFollowLoading ? null : _toggleFollow,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isFollowing ? Colors.grey[600] : Colors.white,
        foregroundColor: _isFollowing ? Colors.white : widget.club.colors.primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: _isFollowLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              _isFollowing 
                  ? AppLocalizations.of(context)!.following 
                  : AppLocalizations.of(context)!.follow,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
    );
  }

  /// Build club content below the banner
  /// Banner altındaki kulüp içeriği oluştur
  Widget _buildClubContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description section
          _buildDescriptionSection(context),
          
          const SizedBox(height: AppConstants.paddingLarge),
          
          // Stats section
          _buildStatsSection(context),
          
          const SizedBox(height: AppConstants.paddingLarge),
          
          // User confirmation section (creator only)
          if (isCreator) ...[
            _buildUserConfirmationSection(context),
            const SizedBox(height: AppConstants.paddingLarge),
          ],
          
          // Club information section
          _buildClubInfoSection(context),
          
          if (widget.club.email != null || widget.club.website != null) ...[
            const SizedBox(height: AppConstants.paddingLarge),
            _buildContactSection(context),
          ],

          if (widget.club.socialMedia.hasAnyLinks) ...[
            const SizedBox(height: AppConstants.paddingLarge),
            _buildSocialMediaSection(context),
          ],
        ],
      ),
    );
  }

  /// Build description section
  /// Açıklama bölümü oluştur
  Widget _buildDescriptionSection(BuildContext context) {
    return Card(
      color: AppThemes.getSurfaceColor(context),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppThemes.getPrimaryColor(context),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'About', // Will use existing 'About' term since there's no direct localization
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.getTextColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              widget.club.description,
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppThemes.getTextColor(context),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build stats section
  /// İstatistikler bölümü oluştur
  Widget _buildStatsSection(BuildContext context) {
    return Card(
      color: AppThemes.getSurfaceColor(context),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                'Followers', // Since followers is a universal term
                widget.club.followerCount.toString(),
                Icons.people,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey[300],
            ),
            Expanded(
              child: _buildStatItem(
                context,
                AppLocalizations.of(context)!.members,
                widget.club.memberCount.toString(),
                Icons.event,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey[300],
            ),
            Expanded(
              child: _buildStatItem(
                context,
                'Established', // Clear English term
                widget.club.establishedYear?.toString() ?? '-',
                Icons.calendar_today,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual stat item
  /// Tekil istatistik öğesi oluştur
  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppThemes.getPrimaryColor(context),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.bold,
            color: AppThemes.getTextColor(context),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.fontSizeSmall,
            color: AppThemes.getSecondaryTextColor(context),
          ),
        ),
      ],
    );
  }

  /// Build club information section
  /// Kulüp bilgileri bölümü oluştur
  Widget _buildClubInfoSection(BuildContext context) {
    return Card(
      color: AppThemes.getSurfaceColor(context),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.business,
                  color: AppThemes.getPrimaryColor(context),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'Club Information', // Clear English term
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.getTextColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Category
            _buildInfoRow(
              context,
              'Category', // Universal term
              _getCategoryDisplayName(widget.club.category),
              Icons.category,
            ),
            
            // Faculty (if available)
            if (widget.club.faculty != null) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              _buildInfoRow(
                context,
                AppLocalizations.of(context)!.faculty,
                widget.club.faculty!,
                Icons.school,
              ),
            ],
            
            // Department (if available)
            if (widget.club.department != null) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              _buildInfoRow(
                context,
                AppLocalizations.of(context)!.department,
                widget.club.department!,
                Icons.class_,
              ),
            ],
            
            // Establishment year
            if (widget.club.establishedYear != null) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              _buildInfoRow(
                context,
                AppLocalizations.of(context)!.establishedIn, // Use existing localization key
                widget.club.establishedYear.toString(),
                Icons.calendar_today,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build contact section
  /// İletişim bölümü oluştur
  Widget _buildContactSection(BuildContext context) {
    
    return Card(
      color: AppThemes.getSurfaceColor(context),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_mail,
                  color: AppThemes.getPrimaryColor(context),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  AppLocalizations.of(context)!.contact,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.getTextColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            if (widget.club.email != null) ...[
              _buildInfoRow(context, AppLocalizations.of(context)!.email, widget.club.email!, Icons.email),
              const SizedBox(height: AppConstants.paddingSmall),
            ],
            
            if (widget.club.website != null) ...[
              _buildInfoRow(context, AppLocalizations.of(context)!.website, widget.club.website!, Icons.language),
            ],
          ],
        ),
      ),
    );
  }

  /// Build social media section
  /// Sosyal medya bölümü oluştur
  Widget _buildSocialMediaSection(BuildContext context) {
    final socialMedia = widget.club.socialMedia;
    
    return Card(
      color: AppThemes.getSurfaceColor(context),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.share,
                  color: AppThemes.getPrimaryColor(context),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  AppLocalizations.of(context)!.socialMedia,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.getTextColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            Wrap(
              spacing: AppConstants.paddingMedium,
              runSpacing: AppConstants.paddingSmall,
              children: [
                if (socialMedia.instagram != null)
                  _buildSocialMediaChip(context, AppLocalizations.of(context)!.instagram, socialMedia.instagram!, Icons.camera_alt),
                if (socialMedia.twitter != null)
                  _buildSocialMediaChip(context, AppLocalizations.of(context)!.twitter, socialMedia.twitter!, Icons.alternate_email),
                if (socialMedia.linkedin != null)
                  _buildSocialMediaChip(context, AppLocalizations.of(context)!.linkedin, socialMedia.linkedin!, Icons.work),
                if (widget.club.website != null)
                  _buildSocialMediaChip(context, AppLocalizations.of(context)!.website, widget.club.website!, Icons.language),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build user confirmation section (creator only)
  /// Kullanıcı onaylama bölümü oluştur (sadece oluşturucu)
  Widget _buildUserConfirmationSection(BuildContext context) {
    return Card(
      color: AppThemes.getSurfaceColor(context),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.approval,
                  color: AppThemes.getPrimaryColor(context),
                ),
                const SizedBox(width: AppConstants.paddingSmall),
                Text(
                  'User Confirmations',
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeLarge,
                    fontWeight: FontWeight.bold,
                    color: AppThemes.getTextColor(context),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_pendingApprovals.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            Text(
              'Users requesting to join the club chat:',
              style: TextStyle(
                color: AppThemes.getSecondaryTextColor(context),
                fontSize: AppConstants.fontSizeMedium,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            
            // Pending approvals list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pendingApprovals.length > 3 ? 3 : _pendingApprovals.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final approval = _pendingApprovals[index];
                return _buildApprovalItem(context, approval);
              },
            ),
            
            // Show more button if there are more than 3 requests
            if (_pendingApprovals.length > 3) ...[
              const SizedBox(height: AppConstants.paddingSmall),
              Center(
                child: TextButton(
                  onPressed: _showAllPendingApprovals,
                  child: Text(
                    'View all ${_pendingApprovals.length} requests',
                    style: TextStyle(
                      color: AppThemes.getPrimaryColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build individual approval item
  /// Bireysel onay öğesi oluştur
  Widget _buildApprovalItem(BuildContext context, PendingApproval approval) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppThemes.getPrimaryColor(context),
            child: approval.userAvatar != null
                ? ClipOval(
                    child: Image.network(
                      approval.userAvatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Text(approval.userName[0].toUpperCase()),
                    ),
                  )
                : Text(
                    approval.userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          
          const SizedBox(width: AppConstants.paddingSmall),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  approval.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppThemes.getTextColor(context),
                  ),
                ),
                if (approval.requestMessage != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    approval.requestMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppThemes.getSecondaryTextColor(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  _formatRequestTime(approval.requestedAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppThemes.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Approve button
              IconButton(
                onPressed: () => _approveRequest(approval),
                icon: const Icon(Icons.check_circle, color: Colors.green),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
              
              // Reject button
              IconButton(
                onPressed: () => _rejectRequest(approval),
                icon: const Icon(Icons.cancel, color: Colors.red),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Format request time
  /// Talep zamanını formatla
  String _formatRequestTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  /// Approve chat request
  /// Sohbet talebini onayla
  Future<void> _approveRequest(PendingApproval approval) async {
    try {
      final success = await _chatService.approveChatRequest(
        approvalId: approval.approvalId,
        decisionMessage: 'Welcome to the club chat!',
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${approval.userName} approved for chat access'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ ClubOverviewScreen: Error approving request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Reject chat request
  /// Sohbet talebini reddet
  Future<void> _rejectRequest(PendingApproval approval) async {
    try {
      final success = await _chatService.rejectChatRequest(
        approvalId: approval.approvalId,
        decisionMessage: 'Request declined by club creator',
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${approval.userName} request rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ ClubOverviewScreen: Error rejecting request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show all pending approvals in a modal
  /// Tüm bekleyen onayları modal olarak göster
  void _showAllPendingApprovals() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppThemes.getSurfaceColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
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
              'Pending Requests (${_pendingApprovals.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Full list
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _pendingApprovals.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final approval = _pendingApprovals[index];
                  return _buildApprovalItem(context, approval);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build info row
  /// Bilgi satırı oluştur
  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppThemes.getSecondaryTextColor(context),
        ),
        const SizedBox(width: AppConstants.paddingSmall),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppThemes.getSecondaryTextColor(context),
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: AppThemes.getTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build social media chip
  /// Sosyal medya çipi oluştur
  Widget _buildSocialMediaChip(BuildContext context, String platform, String url, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(platform),
      onPressed: () {
        // TODO: Open URL in browser
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$platform: $url')),
        );
      },
      backgroundColor: widget.club.colors.primaryColor.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: widget.club.colors.primaryColor),
    );
  }

  // Helper methods

  String _getCategoryDisplayName(String category) {
    const displayNames = {
      'student': 'Öğrenci',
      'academic': 'Akademik',
      'career': 'Kariyer',
      'cultural': 'Kültürel',
      'technology': 'Teknoloji',
      'science': 'Bilim',
      'arts': 'Sanat',
      'volunteer': 'Gönüllülük',
      'sports': 'Spor',
      'other': 'Diğer',
    };
    return displayNames[category] ?? category;
  }

  // Action methods

  /// Toggle follow/unfollow status
  /// Takip et/takibi bırak durumunu değiştir
  Future<void> _toggleFollow() async {
    setState(() {
      _isFollowLoading = true;
    });

    try {
      final isNowFollowing = await _clubService.toggleClubFollow(widget.club.clubId);
      
      if (mounted) {
        setState(() {
          _isFollowing = isNowFollowing;
          _isFollowLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNowFollowing
                  ? '${widget.club.displayName} takip edildi'
                  : '${widget.club.displayName} takibi bırakıldı',
            ),
            backgroundColor: widget.club.colors.primaryColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isFollowLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Edit club (creator only)
  /// Kulübü düzenle (sadece kurucu)
  void _editClub(BuildContext context) {
    // TODO: Implement edit club dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Club editing feature will be added soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Show delete confirmation
  /// Silme onayı göster
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteClub),
        content: Text(
          '${widget.club.displayName} kulübünü silmek istediğinizden emin misiniz? '
          'Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteClub(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  /// Delete club (creator only)
  /// Kulübü sil (sadece kurucu)
  Future<void> _deleteClub(BuildContext context) async {
    try {
      await _clubService.deleteClub(widget.club.clubId);
      
      if (mounted) {
        Navigator.pop(context); // Go back to previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.clubDeleted),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show club settings (creator only)
  /// Kulüp ayarları göster (sadece kurucu)
  void _showClubSettings(BuildContext context) {
    // TODO: Implement club settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Club settings will be added soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  /// Share club
  /// Kulübü paylaş
  void _shareClub(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.club.displayName} paylaşıldı'),
        backgroundColor: Colors.green,
      ),
    );
  }
}