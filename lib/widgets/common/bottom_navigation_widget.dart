import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../themes/app_themes.dart';
import '../../screens/home_screen.dart';
import '../../screens/calendar_screen.dart';
import '../../screens/campus_map_screen.dart';
import '../../screens/qr_access_screen.dart';
import '../../screens/profile_screen.dart';

/// Alt navigasyon çubuğu widget'ı / Bottom navigation bar widget
class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  
  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        boxShadow: AppThemes.getCardShadow(context),
      ),
      child: SafeArea(
        child: Container(
          height: AppConstants.bottomNavHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(context, Icons.location_on, 'Navigation', AppConstants.navIndexNavigation),
              _buildBottomNavItem(context, Icons.calendar_today, 'Calendar', AppConstants.navIndexCalendar),
              _buildBottomNavItem(context, Icons.home, 'Home', AppConstants.navIndexHome),
              _buildBottomNavItem(context, Icons.qr_code_scanner, 'Scan', AppConstants.navIndexScan),
              _buildBottomNavItem(context, Icons.person, 'Profile', AppConstants.navIndexProfile),
            ],
          ),
        ),
      ),
    );
  }

  /// Alt navigasyon öğesi oluşturucu / Bottom navigation item builder
  Widget _buildBottomNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => _navigateToScreen(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppThemes.getPrimaryColor(context) : AppThemes.getSecondaryTextColor(context),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppThemes.getPrimaryColor(context) : AppThemes.getSecondaryTextColor(context),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Ekranlar arası navigasyon / Navigate between screens
  void _navigateToScreen(BuildContext context, int index) {
    if (index == currentIndex) return; // Aynı ekrandaysa hiçbir şey yapma / Do nothing if on same screen
    
    Widget targetScreen;
    switch (index) {
      case AppConstants.navIndexNavigation:
        targetScreen = const CampusMapScreen();
        break;
      case AppConstants.navIndexCalendar:
        targetScreen = const CalendarScreen();
        break;
      case AppConstants.navIndexHome:
        targetScreen = const HomeScreen();
        break;
      case AppConstants.navIndexScan:
        targetScreen = const QRAccessScreen();
        break;
      case AppConstants.navIndexProfile:
        targetScreen = const ProfileScreen();
        break;
      default:
        return;
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }
} 