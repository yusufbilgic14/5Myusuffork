import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../themes/app_themes.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/user_profile_service.dart';
import '../../models/user_profile_model.dart';
import 'profile_picture_widget.dart';
import 'profile_picture_picker_widget.dart';

/// Kullanıcı bilgileri widget'ı / User info widget
class UserInfoWidget extends StatefulWidget {
  final bool isCompact; // Compact mode for drawer, full mode for profile screen
  final bool showStudentId; // Whether to show student ID
  final bool showProfilePicker; // Whether to show profile picture picker
  final VoidCallback? onProfileUpdated; // Callback when profile is updated
  final UserProfile? currentProfile; // Current profile data

  const UserInfoWidget({
    super.key,
    this.isCompact = false,
    this.showStudentId = false,
    this.showProfilePicker = false,
    this.onProfileUpdated,
    this.currentProfile,
  });

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final UserProfileService _profileService = UserProfileService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserProfile?>(
      stream: _profileService.getUserProfileStream(),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final user = _authService.currentAppUser;
        
        // Fallback to user data if profile not loaded
        final displayName = user?.displayName ?? 'Kullanıcı';
        final department = profile?.academicInfo?.department ?? 'Bölüm Belirtilmemiş';
        final grade = profile?.academicInfo?.grade ?? 'Sınıf Belirtilmemiş';
        final studentId = profile?.academicInfo?.studentId ?? 'Numara Belirtilmemiş';
        final role = user?.role ?? 'Öğrenci';

        return Column(
          children: [
            // Kullanıcı fotoğrafı / User photo
            widget.showProfilePicker 
                ? ProfilePicturePickerWidget(
                    currentPhotoUrl: widget.currentProfile?.profilePhotoUrl ?? profile?.profilePhotoUrl,
                    displayName: displayName,
                    size: widget.isCompact ? 80.0 : 100.0,
                    onPhotoUpdated: (photoUrl) {
                      widget.onProfileUpdated?.call();
                    },
                  )
                : ProfilePictureWidget(
                    profilePhotoUrl: profile?.profilePhotoUrl,
                    displayName: displayName,
                    size: widget.isCompact ? 80.0 : 100.0,
                    showBorder: true,
                    borderColor: widget.isCompact
                        ? AppConstants.textColorLight
                        : AppThemes.getPrimaryColor(context),
                    borderWidth: widget.isCompact ? 2.0 : 3.0,
                  ),

            SizedBox(height: widget.isCompact ? 12 : 16),

            // Kullanıcı adı / User name
            Text(
              displayName,
              style: TextStyle(
                color: widget.isCompact
                    ? AppConstants.textColorLight
                    : AppThemes.getPrimaryColor(context),
                fontSize: widget.isCompact ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (!widget.isCompact) ...[
              const SizedBox(height: AppConstants.paddingSmall),

              // Rol rozeti / Role badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppThemes.getPrimaryColor(context),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                ),
                child: Text(
                  role,
                  style: const TextStyle(
                    color: AppConstants.textColorLight,
                    fontSize: AppConstants.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            SizedBox(height: widget.isCompact ? 4 : 8),

            // Bölüm bilgisi / Department info
            Text(
              widget.isCompact
                  ? '${department.split(' ').first}\n$grade' // Compact: "MIS\n3rd Grade"
                  : '$department\n$grade',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.isCompact
                    ? AppConstants.textColorLight
                    : AppThemes.getSecondaryTextColor(context),
                fontSize: widget.isCompact ? 14 : 14,
                fontWeight: widget.isCompact ? FontWeight.w500 : FontWeight.w400,
                height: 1.4,
              ),
            ),

            // Öğrenci numarası (sadece tam modda) / Student ID (only in full mode)
            if (widget.showStudentId && !widget.isCompact) ...[
              const SizedBox(height: AppConstants.paddingMedium),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium,
                  vertical: AppConstants.paddingSmall,
                ),
                decoration: BoxDecoration(
                  color: AppThemes.getSecondaryTextColor(
                    context,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.badge,
                      size: 16,
                      color: AppThemes.getSecondaryTextColor(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      studentId,
                      style: TextStyle(
                        fontSize: AppConstants.fontSizeSmall,
                        fontWeight: FontWeight.w500,
                        color: AppThemes.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

}
