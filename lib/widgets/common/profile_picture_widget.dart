import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/app_constants.dart';
import '../../themes/app_themes.dart';
import '../../services/profile_picture_service.dart';
import '../../services/firebase_auth_service.dart';

/// Profil fotoğrafı widget'ı - kullanıcı avatarını gösterir / Profile picture widget - displays user avatar
class ProfilePictureWidget extends StatefulWidget {
  final String? userId;
  final String? profilePhotoUrl;
  final String? displayName;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final bool showOnlineIndicator;
  final bool isOnline;

  const ProfilePictureWidget({
    super.key,
    this.userId,
    this.profilePhotoUrl,
    this.displayName,
    this.size = 40.0,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
    this.onTap,
    this.showOnlineIndicator = false,
    this.isOnline = false,
  });

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  final ProfilePictureService _profilePictureService = ProfilePictureService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  
  String? _currentPhotoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfilePicture();
  }

  @override
  void didUpdateWidget(ProfilePictureWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if userId or profilePhotoUrl changed
    if (oldWidget.userId != widget.userId || 
        oldWidget.profilePhotoUrl != widget.profilePhotoUrl) {
      _loadProfilePicture();
    }
  }

  /// Load profile picture URL
  /// Profil fotoğrafı URL'sini yükle
  Future<void> _loadProfilePicture() async {
    // If profilePhotoUrl is provided directly, use it
    if (widget.profilePhotoUrl != null && widget.profilePhotoUrl!.isNotEmpty) {
      setState(() {
        _currentPhotoUrl = widget.profilePhotoUrl;
      });
      return;
    }

    // Otherwise, fetch from service
    if (widget.userId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final photoUrl = await _profilePictureService.getUserAvatarUrl(widget.userId);
        if (mounted) {
          setState(() {
            _currentPhotoUrl = photoUrl;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _currentPhotoUrl = null;
            _isLoading = false;
          });
        }
      }
    }
  }

  /// Get user display name for fallback
  /// Fallback için kullanıcı görünen adını al
  String _getDisplayName() {
    if (widget.displayName != null && widget.displayName!.isNotEmpty) {
      return widget.displayName!;
    }
    
    // Try to get from current user if it's the current user
    if (widget.userId == _authService.currentAppUser?.id) {
      return _authService.currentAppUser?.displayName ?? 'U';
    }
    
    return 'U'; // Default fallback
  }

  /// Get initials from display name
  /// Görünen isimden baş harfleri al
  String _getInitials(String displayName) {
    if (displayName.isEmpty) return 'U';
    
    final parts = displayName.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return displayName[0].toUpperCase();
    
    if (parts.length == 1) {
      // Single name, take first character
      return parts[0][0].toUpperCase();
    } else {
      // Multiple names, take first character of first and last name
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
  }

  /// Get avatar background color based on user ID
  /// Kullanıcı ID'sine göre avatar arka plan rengini al
  Color _getAvatarColor(String userId) {
    const colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];
    
    // Use userId hash to get consistent color
    final hash = userId.hashCode.abs();
    return colors[hash % colors.length];
  }

  /// Build fallback avatar with initials
  /// Baş harflerle fallback avatar oluştur
  Widget _buildFallbackAvatar(BuildContext context) {
    final displayName = _getDisplayName();
    final initials = _getInitials(displayName);
    final backgroundColor = widget.userId != null 
        ? _getAvatarColor(widget.userId!)
        : AppThemes.getPrimaryColor(context);

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: widget.showBorder
            ? Border.all(
                color: widget.borderColor ?? Colors.white,
                width: widget.borderWidth,
              )
            : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: widget.size * 0.4, // Scale font size with avatar size
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build network image avatar
  /// Network görüntüsü avatar oluştur
  Widget _buildNetworkAvatar(BuildContext context, String imageUrl) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: widget.showBorder
            ? Border.all(
                color: widget.borderColor ?? Colors.white,
                width: widget.borderWidth,
              )
            : null,
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: widget.size,
            height: widget.size,
            color: Colors.grey[300],
            child: Center(
              child: SizedBox(
                width: widget.size * 0.3,
                height: widget.size * 0.3,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppThemes.getPrimaryColor(context),
                  ),
                ),
              ),
            ),
          ),
          errorWidget: (context, url, error) => _buildFallbackAvatar(context),
        ),
      ),
    );
  }

  /// Build loading avatar
  /// Yükleniyor avatar oluştur
  Widget _buildLoadingAvatar(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
        border: widget.showBorder
            ? Border.all(
                color: widget.borderColor ?? Colors.white,
                width: widget.borderWidth,
              )
            : null,
      ),
      child: Center(
        child: SizedBox(
          width: widget.size * 0.3,
          height: widget.size * 0.3,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppThemes.getPrimaryColor(context),
            ),
          ),
        ),
      ),
    );
  }

  /// Build online indicator
  /// Çevrimiçi gösterge oluştur
  Widget _buildOnlineIndicator() {
    if (!widget.showOnlineIndicator) return const SizedBox.shrink();

    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: widget.size * 0.25,
        height: widget.size * 0.25,
        decoration: BoxDecoration(
          color: widget.isOnline ? Colors.green : Colors.grey,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget;

    if (_isLoading) {
      avatarWidget = _buildLoadingAvatar(context);
    } else if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      avatarWidget = _buildNetworkAvatar(context, _currentPhotoUrl!);
    } else {
      avatarWidget = _buildFallbackAvatar(context);
    }

    // Wrap with GestureDetector if onTap is provided
    if (widget.onTap != null) {
      avatarWidget = GestureDetector(
        onTap: widget.onTap,
        child: avatarWidget,
      );
    }

    // Add online indicator if needed
    if (widget.showOnlineIndicator) {
      avatarWidget = Stack(
        children: [
          avatarWidget,
          _buildOnlineIndicator(),
        ],
      );
    }

    return avatarWidget;
  }
}

/// Simplified profile picture widget for common use cases
/// Yaygın kullanım durumları için basitleştirilmiş profil fotoğrafı widget'ı
class SimpleProfilePicture extends StatelessWidget {
  final String? userId;
  final String? profilePhotoUrl;
  final String? displayName;
  final double size;

  const SimpleProfilePicture({
    super.key,
    this.userId,
    this.profilePhotoUrl,
    this.displayName,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePictureWidget(
      userId: userId,
      profilePhotoUrl: profilePhotoUrl,
      displayName: displayName,
      size: size,
    );
  }
}

/// Profile picture widget with border for special cases
/// Özel durumlar için kenarlıklı profil fotoğrafı widget'ı
class BorderedProfilePicture extends StatelessWidget {
  final String? userId;
  final String? profilePhotoUrl;
  final String? displayName;
  final double size;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const BorderedProfilePicture({
    super.key,
    this.userId,
    this.profilePhotoUrl,
    this.displayName,
    this.size = 40.0,
    this.borderColor,
    this.borderWidth = 2.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ProfilePictureWidget(
      userId: userId,
      profilePhotoUrl: profilePhotoUrl,
      displayName: displayName,
      size: size,
      showBorder: true,
      borderColor: borderColor,
      borderWidth: borderWidth,
      onTap: onTap,
    );
  }
}