import 'package:flutter/material.dart';
import 'package:medipolapp/screens/profile_screen.dart';
import 'package:medipolapp/screens/help_support_screen.dart';
import 'package:medipolapp/screens/login_screen.dart';
import '../../screens/inbox_screen.dart';
import '../../screens/feedback_screen.dart';
import '../../screens/course_grades_screen.dart';
import '../../screens/upcoming_events_screen.dart';
import '../../screens/academic_calendar_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Uygulama drawer widget'ı - Tüm sayfalarda kullanılan ana drawer / App drawer widget - Main drawer used across all pages
class AppDrawerWidget extends StatelessWidget {
  final int currentPageIndex;

  const AppDrawerWidget({super.key, required this.currentPageIndex});

  @override
  Widget build(BuildContext context) {
    return _buildSideDrawer(context);
  }

  // Sidebar drawer oluştur / Build sidebar drawer
  Widget _buildSideDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF181F2A), Color(0xFF1E3A8A)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
          );
    final boxShadow = [
      BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.25)
            : const Color(0xFF1E3A8A).withOpacity(0.13),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ];
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          boxShadow: boxShadow,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Üst profil bölümü / Top profile section
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profil resmi / Profile picture
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/elifyilmaz.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)!.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.userDepartment,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.userGrade,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // Ayırıcı çizgi / Divider line
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.white.withValues(alpha: 0.3),
              ),

              const SizedBox(height: 20),

              // Menü öğeleri / Menu items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      icon: Icons.event,
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
                    _buildDrawerItem(
                      icon: Icons.school,
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
                    _buildDrawerItem(
                      icon: Icons.date_range,
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

                    _buildDrawerItem(
                      icon: Icons.mail,
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
                    _buildDrawerItem(
                      icon: Icons.feedback,
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
                    // Yardım ve Destek
                    _buildDrawerItem(
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
                    // Çıkış Yap
                    _buildDrawerItem(
                      icon: Icons.logout,
                      title: AppLocalizations.of(context)!.logout,
                      textColor: Colors.red[300],
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(AppLocalizations.of(context)!.logout),
                              content: Text(
                                AppLocalizations.of(context)!.logoutConfirm,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.logout,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Sosyal medya ikonları en alta sabit
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIcon(
                      context,
                      'assets/images/facebook.png',
                      'https://www.facebook.com/medipoluniversitesi',
                    ),
                    const SizedBox(width: 10),
                    _buildSocialIcon(
                      context,
                      'assets/images/twitter.png',
                      'https://x.com/medipolunv',
                    ),
                    const SizedBox(width: 10),
                    _buildSocialIcon(
                      context,
                      'assets/images/youtube.png',
                      'https://www.youtube.com/medipoluniversitesi',
                    ),
                    const SizedBox(width: 10),
                    _buildSocialIcon(
                      context,
                      'assets/images/linkedin.jpg',
                      'https://www.linkedin.com/school/medipoluniversitesi/',
                    ),
                    const SizedBox(width: 10),
                    _buildSocialIcon(
                      context,
                      'assets/images/instagram.jpg',
                      'https://www.instagram.com/medipolunv/',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Drawer menü öğesi oluşturucu / Drawer menu item builder
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.white, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  // Sosyal medya ikon butonu
  Widget _buildSocialIcon(BuildContext context, String assetPath, String url) {
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A).withOpacity(0.12), // Mavi ton uyumu
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(assetPath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
