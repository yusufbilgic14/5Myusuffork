import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan sabitler / App-wide constants
class AppConstants {
  // Renkler / Colors
  static const Color primaryColor = Color(0xFF1E3A8A); // Navy blue
  static const Color backgroundColor = Colors.white;
  static const Color textColorDark = Colors.black87;
  static const Color textColorLight = Colors.white;
  static const Color textColorGrey = Colors.grey;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  
  // Boyutlar / Dimensions
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 24.0;
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  
  static const double bottomNavHeight = 60.0;
  static const double appBarHeight = 56.0;
  
  // Font boyutları / Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 24.0;
  
  // Gölge stilleri / Shadow styles
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      offset: const Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 1,
    ),
  ];
  
  static List<BoxShadow> get bottomNavShadow => [
    BoxShadow(
      color: Colors.grey.withValues(alpha: 0.2),
      spreadRadius: 0,
      blurRadius: 10,
      offset: const Offset(0, -2),
    ),
  ];
  
  // Kullanıcı bilgileri / User info
  static const String userName = 'Elif Yılmaz';
  static const String userRole = 'Öğrenci';
  static const String userDepartment = 'Yönetim Bilişim Sistemleri';
  static const String userGrade = '3. Sınıf';
  static const String userStudentId = '2022520145';
  static const String userPhotoPath = 'assets/images/elifyılmaz.png';
  
  // Navigasyon indeksleri / Navigation indices
  static const int navIndexNavigation = 0;
  static const int navIndexCalendar = 1;
  static const int navIndexHome = 2;
  static const int navIndexScan = 3;
  static const int navIndexProfile = 4;
} 