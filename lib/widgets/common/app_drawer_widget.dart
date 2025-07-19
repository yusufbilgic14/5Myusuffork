import 'package:flutter/material.dart';
import 'package:medipolapp/screens/profile_screen.dart';
import 'package:medipolapp/screens/help_support_screen.dart';
import 'package:medipolapp/screens/login_screen.dart';
import '../../screens/inbox_screen.dart';
import '../../screens/feedback_screen.dart';
import '../../screens/course_grades_screen.dart';
import '../../screens/upcoming_events_screen.dart';
import '../../screens/academic_calendar_screen.dart';
import '../../screens/cafeteria_menu_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../screens/home_screen.dart';

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
    return Drawer(
      backgroundColor: const Color(0xFF1E3A8A),
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

                  // Kullanıcı adı / Username
                  Text(
                    AppLocalizations.of(context)!.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Bölüm bilgisi / Department info
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
                          builder: (context) => const AcademicCalendarScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.restaurant,
                    title: AppLocalizations.of(context)!.cafeteriaMenu,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CafeteriaMenuScreen(),
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
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: AppLocalizations.of(context)!.settings,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                      // TODO: Settings sayfasına git
                    },
                  ),
                ],
              ),
            ),

            // Alt bölüm - Help ve Logout / Bottom section - Help and Logout
            Column(
              children: [
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
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(AppLocalizations.of(context)!.logout),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
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
}
