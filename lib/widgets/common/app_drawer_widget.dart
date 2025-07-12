import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../themes/app_themes.dart';
import '../../providers/theme_provider.dart';
import '../../services/navigation_service.dart';
import 'user_info_widget.dart';

/// Uygulama drawer widget'ı / App drawer widget
class AppDrawerWidget extends StatelessWidget {
  final int currentPageIndex;

  const AppDrawerWidget({super.key, required this.currentPageIndex});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppThemes.getSurfaceColor(context),
      child: Column(
        children: [
          // Drawer başlığı / Drawer header
          _buildDrawerHeader(context),

          // Menü öğeleri / Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Ana navigasyon menüleri / Main navigation menus
                _buildNavigationSection(context),

                const Divider(),

                // Ek hizmetler / Additional services
                _buildServicesSection(context),

                const Divider(),

                // Ayarlar / Settings
                _buildSettingsSection(context),
              ],
            ),
          ),

          // Alt bilgi / Footer
          _buildDrawerFooter(context),
        ],
      ),
    );
  }

  /// Drawer başlığı / Drawer header
  Widget _buildDrawerHeader(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppThemes.getPrimaryColor(context),
            AppThemes.getPrimaryColor(context).withValues(alpha: 0.8),
          ],
        ),
      ),
      child: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingMedium),
          child: UserInfoWidget(isCompact: true, showStudentId: false),
        ),
      ),
    );
  }

  /// Ana navigasyon bölümü / Main navigation section
  Widget _buildNavigationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Ana Sayfa'),
        for (final page in NavigationState.allPages)
          _buildDrawerItem(
            context,
            icon: NavigationState.getPageIcon(page),
            title: NavigationState.getPageLabel(page),
            isSelected: currentPageIndex == page.navIndex,
            onTap: () {
              Navigator.pop(context);
              if (currentPageIndex != page.navIndex) {
                NavigationService.navigateToPage(context, page);
              }
            },
          ),
      ],
    );
  }

  /// Hizmetler bölümü / Services section
  Widget _buildServicesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Hizmetler'),
        _buildDrawerItem(
          context,
          icon: Icons.mail_outline,
          title: 'Gelen Kutusu',
          onTap: () {
            Navigator.pop(context);
            NavigationService.navigateToInbox(context);
          },
        ),
        _buildDrawerItem(
          context,
          icon: Icons.feedback_outlined,
          title: 'Geri Bildirim',
          onTap: () {
            Navigator.pop(context);
            NavigationService.navigateToFeedback(context);
          },
        ),
        _buildDrawerItem(
          context,
          icon: Icons.help_outline,
          title: 'Yardım',
          onTap: () {
            Navigator.pop(context);
            _showHelpDialog(context);
          },
        ),
      ],
    );
  }

  /// Ayarlar bölümü / Settings section
  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Ayarlar'),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return _buildDrawerItem(
              context,
              icon: themeProvider.themeIcon,
              title: 'Tema: ${themeProvider.currentThemeName}',
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) async {
                  await themeProvider.toggleTheme();
                },
                activeColor: AppThemes.getPrimaryColor(context),
              ),
              onTap: () async {
                await themeProvider.toggleTheme();
              },
            );
          },
        ),
        _buildDrawerItem(
          context,
          icon: Icons.logout,
          title: 'Çıkış Yap',
          textColor: Colors.red[600],
          onTap: () => _showLogoutDialog(context),
        ),
      ],
    );
  }

  /// Bölüm başlığı / Section title
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.paddingMedium,
        AppConstants.paddingMedium,
        AppConstants.paddingMedium,
        AppConstants.paddingSmall,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppConstants.fontSizeSmall,
          fontWeight: FontWeight.w600,
          color: AppThemes.getSecondaryTextColor(context),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Drawer öğesi / Drawer item
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    bool isSelected = false,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final effectiveTextColor =
        textColor ??
        (isSelected
            ? AppThemes.getPrimaryColor(context)
            : AppThemes.getTextColor(context));

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSmall,
        vertical: 2,
      ),
      decoration: isSelected
          ? BoxDecoration(
              color: AppThemes.getPrimaryColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            )
          : null,
      child: ListTile(
        leading: Icon(icon, color: effectiveTextColor, size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: effectiveTextColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: AppConstants.fontSizeMedium,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: 4,
        ),
      ),
    );
  }

  /// Drawer alt bilgi / Drawer footer
  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppThemes.getSecondaryTextColor(
              context,
            ).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppThemes.getSecondaryTextColor(context),
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Expanded(
            child: Text(
              'Medipol Üniversitesi © 2025',
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall - 1,
                color: AppThemes.getSecondaryTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Yardım dialog'u / Help dialog
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yardım ve Destek'),
          content: const Text(
            'Bu uygulama İstanbul Medipol Üniversitesi öğrencileri için geliştirilmiştir.\n\n'
            'Teknik destek için:\n'
            'E-posta: bilgiislem@medipol.edu.tr\n'
            'Telefon: (0216) 681 5100',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }

  /// Çıkış dialog'u / Logout dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text(
            'Uygulamadan çıkış yapmak istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialog'u kapat / Close dialog
                Navigator.pop(context); // Drawer'ı kapat / Close drawer
                NavigationService.logout(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red[600]),
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }
}
