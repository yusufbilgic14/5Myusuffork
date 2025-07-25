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

// New imports for profile functionality
import '../services/user_profile_service.dart';
import '../models/user_profile_model.dart';
import '../widgets/dialogs/profile_data_dialog.dart';
import '../widgets/common/profile_picture_picker_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserProfileService _profileService = UserProfileService();

  // LoginScreen'deki gibi dropdown için değişkenler
  bool _isLanguageDropdownOpen = false;
  late AnimationController _languageDropdownController;
  late Animation<double> _languageDropdownAnimation;

  UserProfile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _languageDropdownController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _languageDropdownAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _languageDropdownController,
        curve: Curves.easeOutCubic,
      ),
    );
    _loadProfile();
  }

  /// Profil verilerini yükle / Load profile data
  Future<void> _loadProfile() async {
    final profile = await _profileService.getUserProfile();
    if (mounted) {
      setState(() {
        _currentProfile = profile;
      });
      
      // Show profile completion dialog if needed
      _checkProfileCompletion();
    }
  }

  /// Profil tamamlanma durumunu kontrol et / Check profile completion
  void _checkProfileCompletion() {
    if (_currentProfile != null && !_currentProfile!.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showProfileCompletionDialog();
      });
    }
  }

  /// Profil tamamlama dialog'unu göster / Show profile completion dialog
  void _showProfileCompletionDialog() {
    if (_currentProfile == null) return;

    showDialog(
      context: context,
      barrierDismissible: false, // Profil tamamlama zorunlu
      builder: (context) => ProfileDataDialog(
        currentProfile: _currentProfile,
        missingFields: _currentProfile!.missingFields,
        onProfileUpdated: () {
          _loadProfile(); // Profili yeniden yükle
        },
      ),
    );
  }

  @override
  void dispose() {
    _languageDropdownController.dispose();
    super.dispose();
  }

  void _toggleLanguageDropdown() {
    setState(() {
      _isLanguageDropdownOpen = !_isLanguageDropdownOpen;
    });
    if (_isLanguageDropdownOpen) {
      _languageDropdownController.forward();
    } else {
      _languageDropdownController.reverse();
    }
  }

  Future<void> _selectLanguage(Locale locale) async {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    await languageProvider.setLocale(locale);
    _toggleLanguageDropdown();
  }

  Widget _buildLanguageDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = Provider.of<LanguageProvider>(context).locale;
    final isTurkish = currentLocale.languageCode == 'tr';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: _toggleLanguageDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.language,
                  style: TextStyle(
                    fontSize: AppConstants.fontSizeSmall,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _isLanguageDropdownOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _languageDropdownAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _languageDropdownAnimation.value,
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: _languageDropdownAnimation.value,
                child: _isLanguageDropdownOpen
                    ? Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A3441)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLanguageOption(
                              imagePath: 'assets/images/turkey.png',
                              label: AppLocalizations.of(
                                context,
                              )!.languageTurkish,
                              isSelected: isTurkish,
                              onTap: () => _selectLanguage(const Locale('tr')),
                            ),
                            Divider(
                              height: 1,
                              color: isDark
                                  ? Colors.white12
                                  : Colors.grey.shade200,
                            ),
                            _buildLanguageOption(
                              imagePath: 'assets/images/uk.png',
                              label: AppLocalizations.of(
                                context,
                              )!.languageEnglish,
                              isSelected: !isTurkish,
                              onTap: () => _selectLanguage(const Locale('en')),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLanguageOption({
    required String imagePath,
    required String label,
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
              ? (isDark
                    ? AppConstants.primaryColor.withValues(alpha: 0.2)
                    : AppConstants.primaryColor.withValues(alpha: 0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imagePath, width: 24, height: 18, fit: BoxFit.cover),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: AppConstants.fontSizeSmall,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : AppConstants.primaryColor)
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check,
                size: 16,
                color: isDark ? Colors.white : AppConstants.primaryColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLanguageModal() {
    final currentLocale = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).locale;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              imagePath: 'assets/images/turkey.png',
              label: AppLocalizations.of(context)!.languageTurkish,
              isSelected: currentLocale.languageCode == 'tr',
              onTap: () async {
                await Provider.of<LanguageProvider>(
                  context,
                  listen: false,
                ).setLocale(const Locale('tr'));
                Navigator.pop(context);
              },
            ),
            _buildLanguageOption(
              imagePath: 'assets/images/uk.png',
              label: AppLocalizations.of(context)!.languageEnglish,
              isSelected: currentLocale.languageCode == 'en',
              onTap: () async {
                await Provider.of<LanguageProvider>(
                  context,
                  listen: false,
                ).setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showLanguagePopup(TapDownDetails details) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final currentLocale = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).locale;
    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'tr',
          child: Row(
            children: [
              Image.asset('assets/images/turkey.png', width: 24, height: 18),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.languageTurkish),
              if (currentLocale.languageCode == 'tr')
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              Image.asset('assets/images/uk.png', width: 24, height: 18),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.languageEnglish),
              if (currentLocale.languageCode == 'en')
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
    if (selected != null) {
      await Provider.of<LanguageProvider>(
        context,
        listen: false,
      ).setLocale(Locale(selected));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppThemes.getBackgroundColor(context),
      // Navy renkli AppBar / Navy colored AppBar
      appBar: ModernAppBar(
        title: AppLocalizations.of(context)!.profile,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          tooltip: 'Menü',
        ),
      ),

      // Ana sayfa drawer'ı / Main drawer
      drawer: const AppDrawerWidget(
        currentPageIndex: AppConstants.navIndexProfile,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Üst kullanıcı bilgi kartı / Top user info card
              _buildUserInfoCard(),

              const SizedBox(height: AppConstants.paddingXLarge),

              // İstatistik kartları başlığı / Stats cards title
              Text(
                AppLocalizations.of(context)!.quickStats,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeXLarge,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.getPrimaryColor(context),
                ),
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              // Yatay kaydırılabilir istatistik kartları / Horizontal scrollable stats cards
              _buildStatsCards(context),

              const SizedBox(height: AppConstants.paddingXLarge),

              // Menü öğeleri başlığı / Menu items title
              Text(
                AppLocalizations.of(context)!.accountSettings,
                textAlign: TextAlign.left, // Sola hizala
                style: TextStyle(
                  fontSize: AppConstants.fontSizeXLarge,
                  fontWeight: FontWeight.bold,
                  color: AppThemes.getPrimaryColor(context),
                ),
              ),

              const SizedBox(height: AppConstants.paddingMedium),

              // Menü öğeleri listesi / Menu items list
              _buildMenuItems(),

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

  // Kullanıcı bilgi kartı / User info card
  Widget _buildUserInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: AppThemes.getCardShadow(context),
      ),
      child: Column(
        children: [
          // Enhanced user info widget with profile picture picker
          UserInfoWidget(
            showStudentId: true,
            showProfilePicker: true,
            onProfileUpdated: () {
              // Refresh profile data when photo is updated
              _loadProfile();
            },
            currentProfile: _currentProfile,
          ),
        ],
      ),
    );
  }

  // İstatistik kartları / Stats cards
  Widget _buildStatsCards(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Get stats from current profile
    final stats = _currentProfile?.stats ?? const UserProfileStats();
    
    return SizedBox(
      height: 94,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard(
            icon: Icons.event,
            title: l10n.statsEvents,
            value: stats.eventsCount.toString(),
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.school,
            title: l10n.statsGpa,
            value: stats.gpa == 0.0 ? '-' : stats.gpa.toStringAsFixed(2),
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.feedback,
            title: l10n.statsComplaints,
            value: stats.complaintsCount.toString(),
            color: Colors.orange,
          ),
          const SizedBox(width: 12),
          _buildStatCard(
            icon: Icons.assignment,
            title: l10n.statsAssignments,
            value: stats.assignmentsCount.toString(),
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  // İstatistik kartı / Stat card
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(
        AppConstants.paddingSmall + 2,
      ), // Restored original padding
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppThemes.getCardShadow(context),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28, // Restored to 28
            height: 28, // Restored to 28
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18, // Restored to 18
            ),
          ),
          const SizedBox(height: 4), // Restored spacing
          Text(
            value,
            style: TextStyle(
              fontSize: 16, // Restored font size
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10, // Restored font size
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Menü öğeleri / Menu items
  Widget _buildMenuItems() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Container(
      decoration: BoxDecoration(
        color: AppThemes.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: AppThemes.getCardShadow(context),
      ),
      child: Column(
        children: [
          _buildDivider(),
          // Profil düzenleme / Profile settings
          _buildMenuItem(
            icon: Icons.edit,
            title: 'Profili Düzenle',
            subtitle: 'Kişisel bilgilerinizi düzenleyin',
            onTap: () {
              _showProfileCompletionDialog();
            },
          ),
          _buildDivider(),
          // Dil seçici
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppConstants.getIconColor(
                  context,
                ).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Icon(
                Icons.language,
                color: AppConstants.getIconColor(context),
                size: 20,
              ),
            ),
            title: Text(
              AppLocalizations.of(context)!.language,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppThemes.getTextColor(context),
              ),
            ),
            subtitle: Text(
              AppLocalizations.of(context)!.languageDesc,
              style: TextStyle(
                fontSize: 12,
                color: AppThemes.getSecondaryTextColor(context),
              ),
            ),
            trailing: GestureDetector(
              onTapDown: _showLanguagePopup,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: AppConstants.getIconColor(context),
                  ),
                ],
              ),
            ),
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.notifications,
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
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.help,
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
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.directions_bus,
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
          _buildDivider(),
          _buildThemeToggleItem(),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            title: AppLocalizations.of(context)!.logout,
            subtitle: AppLocalizations.of(context)!.logoutDesc,
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () {
              _showLogoutDialog();
            },
          ),
        ],
      ),
    );
  }

  // Menü öğesi / Menu item
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? AppConstants.getIconColor(context)).withValues(
            alpha: 0.1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppConstants.getIconColor(context),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppThemes.getTextColor(context),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: AppThemes.getSecondaryTextColor(context),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppConstants.getIconColor(context),
      ),
      onTap: onTap,
    );
  }

  // Tema değiştirme öğesi / Theme toggle item
  Widget _buildThemeToggleItem() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppConstants.getIconColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
            ),
            child: Icon(
              themeProvider.themeIcon,
              color: AppConstants.getIconColor(context),
              size: 20,
            ),
          ),
          title: Text(
            AppLocalizations.of(context)!.theme,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppThemes.getTextColor(context),
            ),
          ),
          subtitle: Text(
            AppLocalizations.of(context)!.themeDesc,
            style: TextStyle(
              fontSize: 12,
              color: AppThemes.getSecondaryTextColor(context),
            ),
          ),
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
    );
  }

  // Ayırıcı çizgi / Divider
  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: AppThemes.getSecondaryTextColor(context).withValues(alpha: 0.3),
      indent: 72,
      endIndent: 16,
    );
  }

  // Çıkış yapma dialog'u / Logout dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.logout,
            style: const TextStyle(color: AppConstants.primaryColor),
          ),
          content: Text(AppLocalizations.of(context)!.logoutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
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
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(AppLocalizations.of(context)!.logout),
            ),
          ],
        );
      },
    );
  }
}
