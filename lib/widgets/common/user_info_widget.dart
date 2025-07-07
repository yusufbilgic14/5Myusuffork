import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../themes/app_themes.dart';

/// Kullanıcı bilgileri widget'ı / User info widget
class UserInfoWidget extends StatelessWidget {
  final bool isCompact; // Compact mode for drawer, full mode for profile screen
  final bool showStudentId; // Whether to show student ID
  
  const UserInfoWidget({
    super.key,
    this.isCompact = false,
    this.showStudentId = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Kullanıcı fotoğrafı / User photo
        Container(
          width: isCompact ? 80 : 100,
          height: isCompact ? 80 : 100,
                     decoration: BoxDecoration(
             shape: BoxShape.circle,
             border: Border.all(
               color: isCompact ? AppConstants.textColorLight : AppThemes.getPrimaryColor(context),
               width: isCompact ? 2 : 3,
             ),
           ),
          child: ClipOval(
            child: Image.asset(
              AppConstants.userPhotoPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: isCompact ? 40 : 50,
                  ),
                );
              },
            ),
          ),
        ),
        
        SizedBox(height: isCompact ? 12 : 16),
        
                 // Kullanıcı adı / User name
         Text(
           AppConstants.userName,
           style: TextStyle(
             color: isCompact ? AppConstants.textColorLight : AppThemes.getPrimaryColor(context),
             fontSize: isCompact ? 20 : 24,
             fontWeight: FontWeight.bold,
           ),
         ),
        
        if (!isCompact) ...[
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
             child: const Text(
               AppConstants.userRole,
               style: TextStyle(
                 color: AppConstants.textColorLight,
                 fontSize: AppConstants.fontSizeSmall,
                 fontWeight: FontWeight.w600,
               ),
             ),
           ),
        ],
        
        SizedBox(height: isCompact ? 4 : 8),
        
                 // Bölüm bilgisi / Department info
         Text(
           isCompact 
               ? '${AppConstants.userDepartment.split(' ').first}\n${AppConstants.userGrade}' // Compact: "MIS\n3rd Grade"
               : '${AppConstants.userDepartment}\n${AppConstants.userGrade}',
           textAlign: TextAlign.center,
           style: TextStyle(
             color: isCompact ? AppConstants.textColorLight : AppThemes.getSecondaryTextColor(context),
             fontSize: isCompact ? 14 : 14,
             fontWeight: isCompact ? FontWeight.w500 : FontWeight.w400,
             height: 1.4,
           ),
         ),
        
        // Öğrenci numarası (sadece tam modda) / Student ID (only in full mode)
        if (showStudentId && !isCompact) ...[
          const SizedBox(height: AppConstants.paddingMedium),
                     Container(
             padding: const EdgeInsets.symmetric(
               horizontal: AppConstants.paddingMedium, 
               vertical: AppConstants.paddingSmall,
             ),
             decoration: BoxDecoration(
               color: AppThemes.getSecondaryTextColor(context).withValues(alpha: 0.1),
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
                   AppConstants.userStudentId,
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
  }
} 