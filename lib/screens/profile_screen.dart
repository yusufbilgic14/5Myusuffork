import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/theme_provider.dart';
import '../themes/app_themes.dart';

import '../widgets/common/app_drawer_widget.dart';
import '../widgets/common/bottom_navigation_widget.dart';
import '../widgets/common/user_info_widget.dart';
import '../screens/login_screen.dart'; // LoginScreen importu eklendi
import 'notification_settings_screen.dart'; // Bildirim ayarları ekranı importu
import 'help_support_screen.dart'; // Yardım ve Destek ekranı importu
import 'kampuse_ulasim_screen.dart'; // Kampüse Ulaşım ekranı importu
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart'; // Dil ayarları için provider eklendi
import '../widgets/common/app_bar_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppThemes.getBackgroundColor(context),
      // Modern AppBar / Modern AppBar
      appBar: ModernAppBar(
        title: AppLocalizations.of(context)!.profile,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              tooltip: 'Menü',
            );
          },
        ),
      ),

      // Ana sayfa drawer'ı / Main drawer
      drawer: const AppDrawerWidget(
        currentPageIndex: AppConstants.navIndexProfile,
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern üst kullanıcı bilgi kartı / Modern top user info card
              _buildModernUserInfoCard(),

              const SizedBox(height: 24),

              // Modern istatistik kartları başlığı / Modern stats cards title
              _buildModernSectionTitle(
                AppLocalizations.of(context)!.quickStats,
                Icons.analytics_outlined,
              ),

              const SizedBox(height: 16),

              // Modern yatay kaydırılabilir istatistik kartları / Modern horizontal scrollable stats cards
              _buildModernStatsCards(context),

              const SizedBox(height: 24),

              // Modern menü öğeleri başlığı / Modern menu items title
              _buildModernSectionTitle(
                AppLocalizations.of(context)!.accountSettings,
                Icons.settings_outlined,
              ),

              const SizedBox(height: 16),

              // Modern menü öğeleri listesi / Modern menu items list
              _buildModernMenuItems(),

              const SizedBox(
                height: 80,
              ), // Alt navigasyon için boşluk / Space for bottom navigation
            ],
          ),
        ),
      ),

      // Alt navigasyon çubuğu / Bottom navigation bar
      bottomNavigationBar: const BottomNavigationWidget(
        currentIndex: AppConstants.navIndexProfile,
      ),
    );
  }

  // Modern kullanıcı bilgi kartı / Modern user info card
  Widget _buildModernUserInfoCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2634) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: const UserInfoWidget(showStudentId: true),
    );
  }

  // Modern bölüm başlığı / Modern section title
  Widget _buildModernSectionTitle(String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppConstants.primaryColor,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // Modern istatistik kartları / Modern stats cards
  Widget _buildModernStatsCards(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 110, // Yüksekliği artırdım
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildModernStatCard(
            icon: Icons.event_outlined,
            title: l10n.statsEvents,
            value: '12',
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(width: 12),
          _buildModernStatCard(
            icon: Icons.school_outlined,
            title: l10n.statsGpa,
            value: '3.67',
            color: const Color(0xFF10B981),
          ),
          const SizedBox(width: 12),
          _buildModernStatCard(
            icon: Icons.feedback_outlined,
            title: l10n.statsComplaints,
            value: '2',
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 12),
          _buildModernStatCard(
            icon: Icons.assignment_outlined,
            title: l10n.statsAssignments,
            value: '28',
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  // Modern istatistik kartı / Modern stat card
  Widget _buildModernStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 130,
      height: 100, // Sabit yükseklik ekledim
      padding: const EdgeInsets.all(12), // Padding'i azalttım
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A3441) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.15)
                : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 18, // İkon boyutunu küçülttüm
          ),
          const SizedBox(height: 4), // Spacing'i azalttım
          Text(
            value,
            style: TextStyle(
              fontSize: 15, // Font boyutunu küçülttüm
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2), // Spacing'i azalttım
          Flexible(
            // Flexible widget ekledim
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9, // Font boyutunu küçülttüm
                color: isDark
                    ? Colors.white.withOpacity(0.6)
                    : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Modern bayrak butonu / Modern flag button
  Widget _buildModernFlagButton({
    required String imagePath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Image.asset(imagePath, width: 32, height: 24, fit: BoxFit.cover),
      ),
    );
  }

  // Modern menü öğeleri / Modern menu items
  Widget _buildModernMenuItems() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A3441) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.15)
                : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildModernDivider(),
          // Modern dil seçici
          _buildModernLanguageSelector(languageProvider),
          _buildModernDivider(),
          _buildModernMenuItem(
            icon: Icons.notifications_outlined,
            title: AppLocalizations.of(context)!.notificationSettings,
            subtitle: AppLocalizations.of(context)!.notificationSettingsDesc,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          _buildModernDivider(),
          _buildModernMenuItem(
            icon: Icons.help_outline,
            title: AppLocalizations.of(context)!.helpSupport,
            subtitle: AppLocalizations.of(context)!.helpSupportDesc,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            },
          ),
          _buildModernDivider(),
          _buildModernMenuItem(
            icon: Icons.directions_bus_outlined,
            title: AppLocalizations.of(context)!.campusTransport,
            subtitle: AppLocalizations.of(context)!.campusTransportDesc,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const KampuseUlasimScreen(),
                ),
              );
            },
          ),
          _buildModernDivider(),
          _buildModernThemeToggleItem(),
          _buildModernDivider(),
          _buildModernMenuItem(
            icon: Icons.logout_outlined,
            title: AppLocalizations.of(context)!.logout,
            subtitle: AppLocalizations.of(context)!.logoutDesc,
            iconColor: const Color(0xFFEF4444),
            textColor: const Color(0xFFEF4444),
            onTap: () {
              _showModernLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  // Modern dil seçici / Modern language selector
  Widget _buildModernLanguageSelector(LanguageProvider languageProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = languageProvider.locale;
    final isTurkish = currentLocale.languageCode == 'tr';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Icon(
        Icons.language_outlined,
        color: AppConstants.primaryColor,
        size: 22,
      ),
      title: Text(
        AppLocalizations.of(context)!.language,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        AppLocalizations.of(context)!.languageDesc,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey.shade600,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isTurkish ? 'TR' : 'EN',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isDark
                  ? Colors.white.withOpacity(0.6)
                  : Colors.grey.shade600,
            ),
          ],
        ),
      ),
      onTap: () {
        _showLanguageSelectorDialog(languageProvider);
      },
    );
  }

  // Dil seçici dialog'u / Language selector dialog
  void _showLanguageSelectorDialog(LanguageProvider languageProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = languageProvider.locale;
    final isTurkish = currentLocale.languageCode == 'tr';

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
                Icons.language_outlined,
                color: AppConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.language,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                languageCode: 'tr',
                languageName: 'Türkçe',
                isSelected: isTurkish,
                onTap: () {
                  languageProvider.setLocale(const Locale('tr'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
              _buildLanguageOption(
                languageCode: 'en',
                languageName: 'English',
                isSelected: !isTurkish,
                onTap: () {
                  languageProvider.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Dil seçenek widget'ı / Language option widget
  Widget _buildLanguageOption({
    required String languageCode,
    required String languageName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppConstants.primaryColor
                : isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppConstants.primaryColor
                    : isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              languageName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppConstants.primaryColor
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const Spacer(),
            Text(
              languageCode.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Colors.white.withOpacity(0.6)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern menü öğesi / Modern menu item
  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      leading: Icon(
        icon,
        color: iconColor ?? AppConstants.primaryColor,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor ?? (isDark ? Colors.white : Colors.black87),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey.shade600,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: isDark
                ? Colors.white.withOpacity(0.4)
                : Colors.grey.shade400,
          ),
      onTap: onTap,
    );
  }

  // Modern tema değiştirme öğesi / Modern theme toggle item
  Widget _buildModernThemeToggleItem() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          leading: Icon(
            themeProvider.themeIcon,
            color: AppConstants.primaryColor,
            size: 22,
          ),
          title: Text(
            AppLocalizations.of(context)!.theme,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.themeDesc,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? Colors.white.withOpacity(0.6)
                  : Colors.grey.shade600,
            ),
          ),
          trailing: Switch(
            value: themeProvider.isDarkMode,
            onChanged: (value) async {
              await themeProvider.toggleTheme();
            },
            activeColor: AppConstants.primaryColor,
            activeTrackColor: AppConstants.primaryColor.withOpacity(0.2),
            inactiveThumbColor: isDark ? Colors.white70 : Colors.grey.shade400,
            inactiveTrackColor: isDark
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.shade200,
          ),
          onTap: () async {
            await themeProvider.toggleTheme();
          },
        );
      },
    );
  }

  // Modern ayırıcı çizgi / Modern divider
  Widget _buildModernDivider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
      indent: 66,
      endIndent: 20,
    );
  }

  // Modern çıkış yapma dialog'u / Modern logout dialog
  void _showModernLogoutDialog() {
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
                color: const Color(0xFFEF4444),
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
                  ? Colors.white.withOpacity(0.7)
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
                      ? Colors.white.withOpacity(0.6)
                      : Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Çıkış yap ve giriş ekranına yönlendir
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
}
