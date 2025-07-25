import 'package:flutter/material.dart';
import 'package:medipolapp/screens/profile_screen.dart';
import 'package:medipolapp/screens/help_support_screen.dart';
import 'package:medipolapp/screens/login_screen.dart';
import '../../screens/inbox_screen.dart';
import '../../screens/feedback_screen.dart';
import '../../screens/course_grades_screen.dart';
import '../../screens/upcoming_events_screen.dart';
import '../../screens/academic_calendar_screen.dart';
import '../../screens/exam_calculator_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/home_screen.dart';
import '../../constants/app_constants.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/user_profile_service.dart';
import '../../models/user_profile_model.dart';
import 'package:url_launcher/url_launcher.dart';

/// Uygulama drawer widget'ı - Tüm sayfalarda kullanılan ana drawer / App drawer widget - Main drawer used across all pages
class AppDrawerWidget extends StatefulWidget {
  final int currentPageIndex;

  const AppDrawerWidget({super.key, required this.currentPageIndex});

  @override
  State<AppDrawerWidget> createState() => _AppDrawerWidgetState();
}

class _AppDrawerWidgetState extends State<AppDrawerWidget> {
  final UserProfileService _profileService = UserProfileService();
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  /// Kullanıcı profilini yükle / Load user profile
  Future<void> _loadUserProfile() async {
    try {
      final profile = await _profileService.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
        });
      }
    } catch (e) {
      // Hata durumunda fallback kullan / Use fallback on error
      print('Error loading user profile in drawer: $e');
    }
  }

  // Firebase'den kullanıcı adını al / Get user name from Firebase
  String _getUserName(BuildContext context) {
    final firebaseAuthService = FirebaseAuthService();
    return firebaseAuthService.currentAppUser?.displayName ??
        AppLocalizations.of(context)!.userName;
  }

  // Firebase'den kullanıcı bölümünü al / Get user department from Firebase
  String _getUserDepartment(BuildContext context) {
    if (_userProfile?.academicInfo != null) {
      return _userProfile!.academicInfo!.department ?? AppLocalizations.of(context)!.userDepartment;
    }
    final firebaseAuthService = FirebaseAuthService();
    return firebaseAuthService.currentAppUser?.department ??
        AppLocalizations.of(context)!.userDepartment;
  }

  // Kullanıcı sınıf/rol bilgisini al / Get user grade/role info
  String _getUserGradeInfo(BuildContext context) {
    if (_userProfile?.academicInfo != null) {
      final academic = _userProfile!.academicInfo!;
      if (academic.grade != null && academic.grade!.isNotEmpty) {
        // Localization için grade formatı / Localized grade format
        final isTurkish = AppLocalizations.of(context)!.localeName == 'tr';
        return isTurkish 
            ? '${academic.grade}'
            : 'Grade ${academic.grade}';
      }
    }
    final firebaseAuthService = FirebaseAuthService();
    final user = firebaseAuthService.currentAppUser;
    if (user != null) {
      return user.role; // This will return "Öğrenci", "Personel", etc.
    }
    return AppLocalizations.of(context)!.userGrade;
  }

  // Öğrenci numarasını al / Get student ID
  String? _getStudentId() {
    if (_userProfile?.academicInfo != null) {
      return _userProfile!.academicInfo!.studentId;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return _buildModernSideDrawer(context);
  }

  // Modern sidebar drawer oluştur / Build modern sidebar drawer
  Widget _buildModernSideDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? [
            const Color(0xFF181F2A),
            AppConstants.primaryColor.withValues(alpha: 0.85),
          ]
        : [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withValues(alpha: 0.85),
          ];
    final boxShadowColor = isDark
        ? Colors.black.withValues(alpha: 0.25)
        : AppConstants.primaryColor.withValues(alpha: 0.13);

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bgGradient,
          ),
          boxShadow: [
            BoxShadow(
              color: boxShadowColor,
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern üst profil bölümü / Modern top profile section
              _buildModernProfileSection(context),

              const SizedBox(height: 16),

              // Modern ayırıcı çizgi / Modern divider line
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.white.withValues(alpha: 0.3),
              ),

              const SizedBox(height: 16),

              // Modern menü öğeleri / Modern menu items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildModernDrawerItem(
                      context,
                      icon: Icons.event_outlined,
                      title: AppLocalizations.of(context)!.upcomingEvents,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UpcomingEventsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildModernDrawerItem(
                      context,
                      icon: Icons.school_outlined,
                      title: AppLocalizations.of(context)!.courseGrades,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CourseGradesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildModernDrawerItem(
                      context,
                      icon: Icons.calculate_outlined,
                      title: AppLocalizations.of(context)!.examCalculator,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExamCalculatorScreen(),
                          ),
                        );
                      },
                    ),
                    _buildModernDrawerItem(
                      context,
                      icon: Icons.date_range_outlined,
                      title: AppLocalizations.of(context)!.academicCalendar,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const AcademicCalendarScreen(),
                          ),
                        );
                      },
                    ),
                    _buildModernDrawerItem(
                      context,
                      icon: Icons.mail_outlined,
                      title: AppLocalizations.of(context)!.inbox,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InboxScreen(),
                          ),
                        );
                      },
                    ),
                    _buildModernDrawerItem(
                      context,
                      icon: Icons.feedback_outlined,
                      title: AppLocalizations.of(context)!.feedback,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FeedbackScreen(),
                          ),
                        );
                      },
                    ),
                    _buildModernDrawerItem(
                      context,
                      icon: Icons.help_outline,
                      title: AppLocalizations.of(context)!.helpSupport,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Modern çıkış yap butonu / Modern logout button
                    _buildModernLogoutItem(context),
                  ],
                ),
              ),

              // Modern sosyal medya ikonları / Modern social media icons
              _buildModernSocialMediaSection(context),
            ],
          ),
        ),
      ),
    );
  }

  // Modern profil bölümü / Modern profile section
  Widget _buildModernProfileSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Modern profil resmi / Modern profile picture
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/elifyilmaz.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 40,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _getUserName(context),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getUserDepartment(context),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getUserGradeInfo(context),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          // Öğrenci numarasını göster / Show student ID if available
          if (_getStudentId() != null) ...[
            const SizedBox(height: 2),
            Text(
              _getStudentId()!,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Modern drawer menü öğesi / Modern drawer menu item
  Widget _buildModernDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Modern çıkış yap öğesi / Modern logout item
  Widget _buildModernLogoutItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.logout_outlined,
            color: Theme.of(context).colorScheme.error,
            size: 18,
          ),
        ),
        title: Text(
          'Çıkış Yap',
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          _showModernLogoutDialog(context);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Modern çıkış yapma dialog'u / Modern logout dialog
  void _showModernLogoutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: isDark ? const Color(0xFF2A3441) : Colors.white,
          title: Row(
            children: [
              Icon(
                Icons.logout_outlined,
                color: Theme.of(context).colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.logout,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            AppLocalizations.of(context)!.logoutConfirm,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.grey.shade600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.6)
                      : Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.logout),
            ),
          ],
        );
      },
    );
  }

  // Modern sosyal medya bölümü / Modern social media section
  Widget _buildModernSocialMediaSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Sosyal Medya',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildModernSocialIcon(
                context,
                'assets/images/facebook.png',
                'https://www.facebook.com/medipoluniversitesi',
              ),
              _buildModernSocialIcon(
                context,
                'assets/images/twitter.png',
                'https://x.com/medipolunv',
              ),
              _buildModernSocialIcon(
                context,
                'assets/images/youtube.png',
                'https://www.youtube.com/medipoluniversitesi',
              ),
              _buildModernSocialIcon(
                context,
                'assets/images/linkedin.jpg',
                'https://www.linkedin.com/school/medipoluniversitesi/',
              ),
              _buildModernSocialIcon(
                context,
                'assets/images/instagram.jpg',
                'https://www.instagram.com/medipolunv/',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Modern sosyal medya ikon butonu / Modern social media icon button
  Widget _buildModernSocialIcon(
    BuildContext context,
    String assetPath,
    String url,
  ) {
    return GestureDetector(
      onTap: () async {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Bağlantı açılamadı: $url')));
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.link, size: 16, color: Colors.white70);
            },
          ),
        ),
      ),
    );
  }
}
