import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/campus_map_screen.dart';
import '../screens/qr_access_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/inbox_screen.dart';
import '../screens/course_grades_screen.dart';

/// Navigasyon hizmetleri / Navigation services
class NavigationService {
  /// Bottom navigation ile sayfa geçişleri / Page transitions with bottom navigation
  static void navigateToPage(BuildContext context, NavigationPage page) {
    Widget targetScreen;

    switch (page) {
      case NavigationPage.navigation:
        targetScreen = const CampusMapScreen();
        break;
      case NavigationPage.calendar:
        targetScreen = const CalendarScreen();
        break;
      case NavigationPage.home:
        targetScreen = const HomeScreen();
        break;
      case NavigationPage.scan:
        targetScreen = const QRAccessScreen();
        break;
      case NavigationPage.profile:
        targetScreen = const ProfileScreen();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  /// Index ile navigasyon (geriye uyumluluk için) / Navigation with index (for backward compatibility)
  static void navigateToIndex(BuildContext context, int index) {
    final page = NavigationPage.values.firstWhere(
      (p) => p.navIndex == index,
      orElse: () => NavigationPage.home,
    );
    navigateToPage(context, page);
  }

  /// Drawer menü navigasyonları / Drawer menu navigations
  static void navigateToFeedback(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FeedbackScreen()),
    );
  }

  static void navigateToInbox(BuildContext context, {int? messageId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InboxScreen(selectedMessageId: messageId),
      ),
    );
  }

  static void navigateToCourseGrades(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CourseGradesScreen()),
    );
  }

  /// Geri gitme işlemleri / Back navigation operations
  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// Ana sayfaya git / Go to home page
  static void goToHome(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  /// Çıkış işlemi / Logout operation
  static void logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/', // Ana route'a dön / Return to main route
      (route) => false,
    );
  }

  /// Sayfa doğrulama / Page validation
  static bool isCurrentPage(BuildContext context, NavigationPage page) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    switch (page) {
      case NavigationPage.home:
        return currentRoute?.contains('home') ?? false;
      case NavigationPage.calendar:
        return currentRoute?.contains('calendar') ?? false;
      case NavigationPage.navigation:
        return currentRoute?.contains('campus') ?? false;
      case NavigationPage.scan:
        return currentRoute?.contains('qr') ?? false;
      case NavigationPage.profile:
        return currentRoute?.contains('profile') ?? false;
    }
  }
}

/// Navigasyon durumu yönetimi / Navigation state management
class NavigationState {
  static const Map<NavigationPage, String> _pageLabels = {
    NavigationPage.navigation: 'Navigation',
    NavigationPage.calendar: 'Calendar',
    NavigationPage.home: 'Home',
    NavigationPage.scan: 'Scan',
    NavigationPage.profile: 'Profile',
  };

  static const Map<NavigationPage, IconData> _pageIcons = {
    NavigationPage.navigation: Icons.location_on,
    NavigationPage.calendar: Icons.calendar_today,
    NavigationPage.home: Icons.home,
    NavigationPage.scan: Icons.qr_code_scanner,
    NavigationPage.profile: Icons.person,
  };

  /// Sayfa etiketi al / Get page label
  static String getPageLabel(NavigationPage page) {
    return _pageLabels[page] ?? 'Unknown';
  }

  /// Sayfa ikonu al / Get page icon
  static IconData getPageIcon(NavigationPage page) {
    return _pageIcons[page] ?? Icons.help_outline;
  }

  /// Tüm sayfaları al / Get all pages
  static List<NavigationPage> get allPages => NavigationPage.values;
}
