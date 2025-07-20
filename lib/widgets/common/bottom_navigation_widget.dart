import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../themes/app_themes.dart';
import '../../services/navigation_service.dart';

/// Alt navigasyon çubuğu widget'ı / Bottom navigation bar widget
class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;

  const BottomNavigationWidget({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        boxShadow: AppShadows.bottomNav,
      ),
      child: SafeArea(
        child: Container(
          height: AppConstants.bottomNavHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingMedium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: NavigationState.allPages.map((page) {
              return _buildBottomNavItem(
                context,
                NavigationState.getPageIcon(page),
                NavigationState.getPageLabel(context, page),
                page.navIndex,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  /// Alt navigasyon öğesi oluşturucu / Bottom navigation item builder
  Widget _buildBottomNavItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
  ) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => _handleNavigation(context, index),
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingSmall,
          vertical: 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: AppConstants.animationFast,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppThemes.getPrimaryColor(context).withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppThemes.getPrimaryColor(context)
                    : AppThemes.getSecondaryTextColor(context),
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppThemes.getPrimaryColor(context)
                    : AppThemes.getSecondaryTextColor(context),
                fontSize: isSelected
                    ? AppConstants.fontSizeSmall - 1
                    : AppConstants.fontSizeSmall - 2,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigasyon işlemi / Navigation operation
  void _handleNavigation(BuildContext context, int index) {
    // Eğer ana sayfa ikonuna tıklanırsa, her zaman HomeScreen'e yönlendir
    if (index == AppConstants.navIndexHome) {
      NavigationService.goToHome(context);
      return;
    }
    if (index == currentIndex) return;
    NavigationService.navigateToIndex(context, index);
  }
}
